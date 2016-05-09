FROM phusion/baseimage

COPY ./scripts/config_* /bin/
COPY ./scripts/install_dependencies.sh /tmp/

CMD ["/sbin/my_init"]

RUN sh /tmp/install_dependencies.sh

RUN mkdir -p /etc/my_init.d
ADD ./scripts/start_tor.sh /etc/my_init.d/start_tor.sh

# Copy custom tor binary
#COPY ./bin/tor* /bin/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
