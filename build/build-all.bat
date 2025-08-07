@echo off
REM Build all containers in this folder. The tag is "openspace-" followed by the name of
REM the Dockerfile without the file extension
for %%f in (*.Dockerfile) do (
  echo "Building %%f"
  start "" docker build --tag openspace-%%~nf --file %%f .
)
