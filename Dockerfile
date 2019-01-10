# base-image for node on any machine using a template variable
FROM balenalib/%%BALENA_MACHINE_NAME%%-debian-node:-build

# Defines our working directory in container
RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app

#Install nodeRed
RUN install_packages make gcc g++ python vim && \
    JOBS=MAX npm install -g node-red node-red-contrib-resinio --production --silent && \
  npm cache clean --force && rm -rf /tmp/*

# This will copy all files in our root to the working  directory in the container
COPY ./app ./

# Enable udevd so that plugged dynamic hardware devices show up in our container.
ENV UDEV=1

# server.js will run when container starts up on the device
CMD ["bash", "/usr/src/app/start.sh"]