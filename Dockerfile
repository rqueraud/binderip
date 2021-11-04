FROM ubuntu:20.04

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y python3.9
RUN apt-get install -y python3-pip

# Install mongodb
RUN apt-get install -y wget gnupg
RUN wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list
RUN apt-get update
RUN apt-get install -y mongodb-org
RUN ps --no-headers -o comm 1
RUN mkdir /data/db -p

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
RUN python3.9 -m pip install --no-cache-dir notebook pymongo pandas xmltodict
RUN apt-get install -y htop

WORKDIR /home/${NB_USER}
COPY ./start.sh .
# COPY ./data ./data/
COPY ./main.ipynb .
RUN chown -R ${NB_UID} ${HOME}

# Start mongodb
# RUN nohup bash -c "scripts/init.sh &"

# USER ${NB_USER}
ENTRYPOINT [ "bash", "start.sh"]