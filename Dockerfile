#use latest armv7hf compatible raspbian OS version from group resin.io as base image 
FROM resin/armv7hf-debian:stretch 

#enable building ARM container on x86 machinery on the web (comment out next line if built on Raspberry) 
RUN [ "cross-build-start" ] 

#labeling 
LABEL maintainer="safetynet.ais@gmail.com"  \
version="V0.8.0" \ 
description="Raspbian(stretch) with SSH as user pi,python3 opc server"

#version
ENV HILSCHERNETPI_OPC_PYTHON_VERSION 0.1.0

#copy files
COPY "./init.d/*" /etc/init.d/
COPY "./driver/*" ".firmware/*" /tmp/

#do installation
RUN apt-get update \
	&& apt-get install -y openssh-server \
	&& mkdir /var/run/sshd \
 	&& sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    	&& sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
	&& useradd --create-home --shell /bin/bash pi \ 
	&& echo 'pi:raspberry' | chpasswd \ 
	&& adduser pi sudo \ 
	&& apt-get install -y  \
		nano\
		git \
		python3 \
		python3-dev \
		python3-pip \
		libxml2-dev \
		libxmlsec1-dev \
		libffi-dev \
		gcc \ 

#install the python packages
&& pip3 install setuputils --upgrade \
&& pip3 install wheel \
&& pip3 install wheel --upgrade \
&& pip3 install cryptography \
&& pip3 install lxml \
&& pip3 install pytz \
&& pip3 install opcua \
&& pip3 install pyshark \

#install netX driver and netX ethernet supporting firmware
&& dpkg -i /tmp/netx-docker-pi-drv-1.1.3.deb \ 
&& dpkg -i /tmp/netx-docker-pi-pns-eth-3.12.0.8.deb \ 
#compile netX network daemon 
&& gcc /tmp/cifx0daemon.c -o /opt/cifx/cifx0daemon -I/usr/include/cifx -Iincludes/ -lcifx -pthread \ 

#set the entrypoint 
ENTRYPOINT ["/etc/init.d/entrypoint.sh"]
#set STOPSGINAL 
STOPSIGNAL SIGTERM 
#stop processing ARM emulation (comment out next line if not built as automated build on docker hub) 
RUN [ "cross-build-end" ]
