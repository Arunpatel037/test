FROM ubuntu
RUN apt-get update
RUN apt-get install wget curl -y
RUN echo "deb http://www.rabbitmq.com/debian/ testing main" | tee -a /etc/apt/sources.list.d/rabbitmq.list

RUN curl -L -o ~/rabbitmq-signing-key-public.asc http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
RUN apt-key add ~/rabbitmq-signing-key-public.asc
RUN apt-get update &&  apt-get install  rabbitmq-server --allow-unauthenticated -y 
#RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm 

RUN apt-get  install -y redis-server

RUN apt-get install -y socat 
RUN  mkdir /etc/rabbitmq/ssl 
ADD server_cert.pem /etc/rabbitmq/ssl/cert.pem 
ADD    server_key.pem /etc/rabbitmq/ssl/key.pem 
ADD   ./testca/cacert.pem /etc/rabbitmq/ssl
ADD rabbitmq.config /etc/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_management

ADD sensu.repo /etc/yum.repos.d
RUN wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- |apt-key add -
RUN echo "deb     http://repositories.sensuapp.org/apt sensu main" |  tee /etc/apt/sources.list.d/sensu.list
RUN apt-get update

RUN apt-get install -y sensu
ADD config.json /etc/sensu/
RUN mkdir -p /etc/sensu/ssl 
ADD client_cert.pem /etc/sensu/ssl/cert.pem 
ADD client_key.pem /etc/sensu/ssl/key.pem

RUN apt-get install -y uchiwa
ADD uchiwa.json /etc/sensu/
RUN apt-get install ssh -y


#ADD supervisord.conf /etc/supervisord.conf
#ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN service ssh  start && service ssh stop

EXPOSE 22 3000 4567 5671 15672



