FROM phusion/baseimage:0.9.17

ENV DEBIAN_FRONTEND noninteractive

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y wget
RUN apt-get install -y build-essential

# install chicken core
RUN wget http://code.call-cc.org/releases/4.9.0/chicken-4.9.0.1.tar.gz && \
   tar xf chicken-4.9.0.1.tar.gz && \
   cd chicken-4.9.0.1 && \
   sudo make PLATFORM=linux install && \
   cd ../ && \
   rm -r chicken-4.9.0.1 chicken-4.9.0.1.tar.gz


# install common eggs
RUN chicken-install -s \
                    nrepl spiffy matchable intarweb uri-common medea \
                    clojurian filepath test crypt

# install chicken openssl
RUN apt-get install -y libssl-dev
RUN chicken-install -s openssl


# install nanomsg
RUN mkdir -p /tmp/nanomsg && cd /tmp/nanomsg && \
    wget http://download.nanomsg.org/nanomsg-0.5-beta.tar.gz && \
    tar xf nanomsg-0.5-beta.tar.gz && \
    cd nanomsg-0.5-beta && \
    ./configure && \
    make install && \
    rm -r /tmp/nanomsg

RUN chicken-install -s nanomsg

RUN apt-get install -y git-core
# Clean up APT when done.
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
