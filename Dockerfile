# base-image for node on any machine using a template variable
FROM balenalib/beaglebone-black-debian-node:stretch-build

# Defines our working directory in container
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app

## Install nodeRed
RUN install_packages wget apt-transport-https
RUN install_packages make gcc g++ python vim wget&& \
    JOBS=MAX npm install -g node-red node-red-contrib-resinio --production --silent && \
  npm cache clean --force && rm -rf /tmp/*

# Install mosquitto
RUN wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key && \
    apt-key add mosquitto-repo.gpg.key && \ 
    rm mosquitto-repo.gpg.key && \
    cd /etc/apt/sources.list.d/ && \ 
    wget http://repo.mosquitto.org/debian/mosquitto-stretch.list && \
    apt-get update && apt-get install -yq \
    mosquitto mosquitto-clients && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# This will copy all files in our root to the working  directory in the container
COPY ./app ./

## Configure mosquitto
RUN /etc/init.d/mosquitto stop && \
    cp ./mosquitto.conf /etc/mosquitto/conf.d/ && \
    touch /etc/mosquitto/conf.d/passwd && \
    mosquitto_passwd -b /etc/mosquitto/conf.d/passwd root NEONdev && \
    /etc/init.d/mosquitto start
    

# This will copy all files in our root to the working  directory in the container
COPY ./app ./

# Enable udevd so that plugged dynamic hardware devices show up in our container.
ENV UDEV=1

# server.js will run when container starts up on the device
CMD ["bash", "/usr/src/app/start.sh"]
