FROM ubuntu:14.04

ARG RS_VERSION
ENV RS_VERSION $RS_VERSION
RUN echo "rabbitmq-server version = ${RS_VERSION}"

RUN sed -i 's/archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list
RUN apt-get update && apt-get install -y wget 
RUN echo "deb http://binaries.erlang-solutions.com/debian precise contrib" >> /etc/apt/sources.list
RUN wget -O - http://binaries.erlang-solutions.com/debian/erlang_solutions.asc | sudo apt-key add -
RUN apt-get update && apt-get install -y erlang socat
RUN apt-get install -y erlang-nox 

WORKDIR /usr/src

RUN wget http://www.rabbitmq.com/releases/rabbitmq-server/v${RS_VERSION}/rabbitmq-server_${RS_VERSION}-1_all.deb \
	&& dpkg -i rabbitmq-server_${RS_VERSION}-1_all.deb

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure rabbitmq
RUN echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config && \
    service rabbitmq-server start && \
    rabbitmq-plugins enable rabbitmq_management && \
    service rabbitmq-server stop

# runtime configuration
ENTRYPOINT service rabbitmq-server start && while true; do sleep 1d; done

# expose ports
EXPOSE 5672
EXPOSE 15672