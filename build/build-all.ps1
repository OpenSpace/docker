#Requires -Version 5.1
<#
.SYNOPSIS
    Rebuilds every OpenSpace build container from scratch and then runs the OpenSpace
    build in each of them, one after another, in its own terminal.

.DESCRIPTION
    1. Removes the openspace-* containers and images.
    2. Builds every *.Dockerfile in this folder as "openspace-<dockerfile base name>".
    3. Opens a new terminal per image running that image interactively.
    4. Runs ./build.sh <branch> in each of those terminals.

    Steps 3 and 4 happen sequentially: the next image is only started once the previous
    one has finished building, so several builds never compete for the same machine.
    Every terminal is left open afterwards, with its container still running, so that the
    output stays readable and the vcpkg logs can be inspected from inside the container.

    Every image shares one Docker volume for the vcpkg binary cache but writes into its
    own subfolder of it, so the distro/compiler combinations never read each other's
    binaries. The volume is deliberately NOT removed in step 1.

.EXAMPLE
    .\build-all.ps1
    .\build-all.ps1 -Branch master -Force
    .\build-all.ps1 -DryRun
#>
[CmdletBinding()]
param(
    # Branch of OpenSpace to build, passed straight through to build.sh.
    [string] $Branch = 'feature/vcpkg',

    # Docker volume holding the vcpkg binary caches.
    [string] $Volume = 'vcpkg-cache',

    # Where that volume is mounted inside the containers.
    [string] $CacheMount = '/mnt/vcpkg-cache',

    # Skip the confirmation prompt in front of the removal step.
    [switch] $Force,

    # Print what would happen without removing, building or launching anything.
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }

function Write-Step {
    param([string] $Message)
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Get-ShellPath {
    foreach ($candidate in 'pwsh', 'powershell') {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    throw 'Neither pwsh nor powershell could be found on PATH.'
}

# Blocks until the build running inside $Tag has written $StatusFile, and reports what it
# found there. The container deliberately outlives its build, so its state can only tell
# us that something went wrong, never that the build is done - the status file does that.
function Wait-Build {
    param(
        [string] $Tag,
        [string] $StatusFile,
        [int]    $PollSeconds = 5
    )

    # A missing status file makes `docker exec cat` exit non-zero, which is the expected
    # state for as long as the build runs and must not become a terminating error.
    $ErrorActionPreference = 'Continue'

    $started = Get-Date
    $elapsed = { '{0:hh\:mm\:ss}' -f ((Get-Date) - $started) }

    # `docker run` needs a moment before the container can be inspected at all, so its
    # absence only counts as a failure once this grace period has passed.
    $deadline = (Get-Date).AddSeconds(120)
    while ($true) {
        $null = docker inspect --format '{{.State.Running}}' $Tag 2>$null
        if ($LASTEXITCODE -eq 0) { break }
        if ((Get-Date) -ge $deadline) {
            return [pscustomobject] @{ Status = 'never started'; Elapsed = (& $elapsed) }
        }
        Start-Sleep -Seconds 2
    }

    while ($true) {
        $status = docker exec $Tag cat $StatusFile 2>$null
        if ($LASTEXITCODE -eq 0 -and $status) {
            Write-Host ''
            return [pscustomobject] @{ Status = "$status".Trim(); Elapsed = (& $elapsed) }
        }

        $state = docker inspect --format '{{.State.Running}}' $Tag 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host ''
            return [pscustomobject] @{ Status = 'container removed'; Elapsed = (& $elapsed) }
        }
        if ("$state".Trim() -ne 'true') {
            Write-Host ''
            return [pscustomobject] @{ Status = 'container stopped'; Elapsed = (& $elapsed) }
        }

        Write-Host "`r    building, $(& $elapsed) elapsed (Ctrl+C to stop waiting)" -NoNewline -ForegroundColor DarkGray
        Start-Sleep -Seconds $PollSeconds
    }
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'docker was not found on PATH.'
}

# ---------------------------------------------------------------------------- 1. clean
$containers = @(docker ps --all --quiet --filter "name=^openspace-")
$images     = @(docker images --quiet --filter "reference=openspace-*" | Sort-Object -Unique)

Write-Step "Removing $($containers.Count) openspace-* container(s) and $($images.Count) image(s)"
Write-Host "    The '$Volume' volume is left alone, so the vcpkg cache survives." -ForegroundColor DarkGray

if ($containers.Count -or $images.Count) {
    if (-not $Force -and -not $DryRun) {
        Write-Host '    Only openspace-* is removed; every other container and image is left alone.' -ForegroundColor Yellow
        if ((Read-Host '    Continue? [y/N]') -notmatch '^(y|yes)$') {
            Write-Host 'Aborted.' -ForegroundColor Yellow
            return
        }
    }

    if ($DryRun) {
        if ($containers.Count) { Write-Host "    docker rm --force <$($containers.Count) containers>" }
        if ($images.Count)     { Write-Host "    docker rmi --force <$($images.Count) images>" }
    }
    else {
        if ($containers.Count) { docker rm  --force @containers | Out-Null }
        if ($images.Count)     { docker rmi --force @images     | Out-Null }
    }
}
else {
    Write-Host '    Nothing to remove.' -ForegroundColor DarkGray
}

# ---------------------------------------------------------------------------- 2. build
$dockerfiles = @(Get-ChildItem -Path $root -Filter '*.Dockerfile' | Sort-Object Name)
if (-not $dockerfiles.Count) {
    throw "No *.Dockerfile found in $root"
}

$built  = [System.Collections.Generic.List[string]]::new()
$failed = [System.Collections.Generic.List[string]]::new()

foreach ($dockerfile in $dockerfiles) {
    $name = $dockerfile.BaseName
    $tag  = "openspace-$name"

    Write-Step "Building $tag"
    if ($DryRun) {
        Write-Host "    docker build --tag $tag --file .\$($dockerfile.Name) ."
        $built.Add($name)
        continue
    }

    docker build --tag $tag --file $dockerfile.FullName $root
    if ($LASTEXITCODE -eq 0) {
        $built.Add($name)
    }
    else {
        $failed.Add($name)
        Write-Host "    Build failed for $tag" -ForegroundColor Red
    }
}

# ------------------------------------------------------------------------ 3. + 4. run
$shell = Get-ShellPath

# Written inside the container once build.sh is done. Polling for it is what makes the
# images run one after another, given that the containers stay alive afterwards.
$statusFile = '/tmp/openspace-build.status'

$results = [ordered] @{}

foreach ($name in $built) {
    $tag      = "openspace-$name"
    $cacheDir = "$CacheMount/$name"

    # mkdir first: vcpkg refuses to start when VCPKG_DEFAULT_BINARY_CACHE does not exist.
    # `exec bash` at the end keeps the container, and with it the terminal, alive after
    # the build so that the output stays on screen and the logs remain reachable.
    $inner   = "mkdir -p $cacheDir && ./build.sh $Branch && " +
               "echo ok > $statusFile || echo failed > $statusFile; exec bash"
    # Single quotes around $inner so that the bash snippet reaches docker untouched by the
    # PowerShell in the new window.
    $command = "docker run -it -v ${Volume}:${CacheMount} " +
               "-e VCPKG_DEFAULT_BINARY_CACHE=$cacheDir " +
               "--name $tag $tag bash -c '$inner'"

    Write-Step "Starting $tag"
    if ($DryRun) {
        Write-Host "    $command"
        $results[$name] = [pscustomobject] @{ Status = 'dry run'; Elapsed = '00:00:00' }
        continue
    }

    # -EncodedCommand avoids a second round of quote mangling on the way to the new window.
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))
    Start-Process -FilePath $shell -ArgumentList '-NoExit', '-EncodedCommand', $encoded

    $results[$name] = Wait-Build -Tag $tag -StatusFile $statusFile

    $result = $results[$name]
    $color  = if ($result.Status -eq 'ok') { 'Green' } else { 'Red' }
    Write-Host "    $($result.Status) after $($result.Elapsed)" -ForegroundColor $color
    Write-Host "    Leaving the terminal for $tag open for inspection." -ForegroundColor DarkGray
}

# -------------------------------------------------------------------------- summary
Write-Step 'Summary'
Write-Host "    Ran: $($built.Count)"

$broken = 0
foreach ($name in $built) {
    $result = $results[$name]
    $ok     = $result.Status -in @('ok', 'dry run')
    if (-not $ok) { $broken++ }
    $color  = if ($ok) { 'Green' } else { 'Red' }
    Write-Host ("      {0,-32} {1} ({2})" -f "openspace-$name", $result.Status, $result.Elapsed) -ForegroundColor $color
}

if ($failed.Count) {
    Write-Host "    Failed to build:  $($failed.Count)"
    foreach ($name in $failed) { Write-Host "      openspace-$name" -ForegroundColor Red }
}

if ($failed.Count -or $broken) { exit 1 }
