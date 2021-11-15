FROM ubuntu:20.04

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y python3.9
RUN apt-get install -y python3-pip

# ##### Binder doc #####

RUN python3.9 -m pip install --no-cache-dir notebook

ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# # Make sure the contents of our repo are in ${HOME}
# COPY . ${HOME}
USER root
# RUN chown -R ${NB_UID} ${HOME}
# USER ${NB_USER}

######################

# Install tools
RUN python3.9 -m pip install --no-cache-dir notebook pymongo pandas xmltodict elasticsearch
RUN apt-get install -y htop curl
RUN apt-get update
RUN apt-get install -y default-jre default-jdk

# Install elasticsearch
RUN apt-get install -y wget
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.2-linux-x86_64.tar.gz
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.15.2-linux-x86_64.tar.gz.sha512
RUN shasum -a 512 -c elasticsearch-7.15.2-linux-x86_64.tar.gz.sha512 
RUN tar -xzf elasticsearch-7.15.2-linux-x86_64.tar.gz
RUN cd elasticsearch-7.15.2/ 
RUN mv elasticsearch-7.15.2/ /home/${NB_USER}/

ENV ES_JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV ES_JAVA_OPTS="-Xms256m -Xmx256m"

WORKDIR /home/${NB_USER}
# COPY ./start.sh .
# COPY ./data ./data/
COPY ./main.ipynb .
COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}
# RUN chown -R ${NB_UID} /data/db

USER ${NB_USER}
