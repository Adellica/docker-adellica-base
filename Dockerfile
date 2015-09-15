FROM phusion/baseimage:0.9.17

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get install -y wget
RUN apt-get install -y build-essential

RUN wget http://code.call-cc.org/releases/4.9.0/chicken-4.9.0.1.tar.gz && \
   tar xf chicken-4.9.0.1.tar.gz && \
   cd chicken-4.9.0.1 && \
   sudo make PLATFORM=linux install && \
   cd ../ && \
   rm -r chicken-4.9.0.1 chicken-4.9.0.1.tar.gz

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
