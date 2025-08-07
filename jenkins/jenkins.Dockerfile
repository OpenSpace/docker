ARG IMAGE
FROM ${IMAGE}

RUN apt install -y openjdk-17-jre
RUN wget https://dev.openspaceproject.com/jnlpJars/agent.jar -q -O /agent.jar
RUN mkdir /var/jenkins

# Our Jenkins tries to build everything with make and with ninja, so we need to install it
RUN apt install -y ninja-build

# We have to go this roundabout way as we cannot use ARG inside an ENTRYPOINT
ARG COMPUTER_NAME
ENV computer_name=$COMPUTER_NAME

ARG SECRET
ENV secret=$SECRET

# We also cannot use the array form of ENTRYPOINT as we need the shell to expand the environment variables
ENTRYPOINT java -jar /agent.jar -url https://dev.openspaceproject.com/ -secret $secret -name $computer_name -workDir /var/jenkins
