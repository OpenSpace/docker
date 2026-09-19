ARG IMAGE
FROM ${IMAGE}

RUN apt-get update && apt-get install -y wget openjdk-25-jre && rm -rf /var/lib/apt/lists/*
RUN wget https://dev.openspaceproject.com/jnlpJars/agent.jar -q -O /agent.jar
RUN mkdir /var/jenkins

# We have to go this roundabout way as we cannot use ARG inside an ENTRYPOINT
ARG COMPUTER_NAME
ENV computer_name=$COMPUTER_NAME

ARG SECRET
ENV secret=$SECRET

# Set the vcpkg cache folder which is defined on the Jenkins machines
ENV VCPKG_DEFAULT_BINARY_CACHE=/mnt/vcpkg-cache

# We also cannot use the array form of ENTRYPOINT as we need the shell to expand the environment variables
ENTRYPOINT java -jar /agent.jar -url https://dev.openspaceproject.com/ -secret $secret -name $computer_name -workDir /var/jenkins
