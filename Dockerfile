FROM    ubuntu:18.04
# Based on:
#  - https://github.com/webdetails/cbf2/blob/master/dockerfiles
#  - https://hub.docker.com/r/picoded/ubuntu-openjdk-8-jdk/dockerfile

# Install primary dependencies
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
	apt-get clean && apt-get update && \
  apt-get install -y locales && \
  locale-gen en_US.UTF-8 && \
  apt-get install -y software-properties-common unzip git lftp sudo zip curl wget && \
  sudo apt-get install -y postgresql-client && \
	sudo apt install -y openjdk-8-jdk && \
  sudo apt install -y python2.7 python-pip && \
  pip install elementpath && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer && \
	echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
	rm -rf /tmp/*

# Set the locale
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 
RUN update-locale LANG=en_US.UTF-8 LC_MESSAGES=POSIX && \
    echo Building core image

# Fix certificate issues, found as of 
# https://bugs.launchpad.net/ubuntu/+source/ca-certificates-java/+bug/983302
RUN apt-get install -y ca-certificates-java && \
	apt-get clean && \
	update-ca-certificates -f && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /var/cache/oracle-jdk8-installer;

# Making the right java available
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Configs directories and users for pentaho 
RUN mkdir /pentaho && \
  mkdir /home/pentaho && \
  groupadd -r pentaho && \
  useradd -r -g pentaho -p $(perl -e'print crypt("pentaho", "aa")' ) -G sudo pentaho && \ 
  chown -R pentaho.pentaho /pentaho && \ 
  chown -R pentaho.pentaho /home/pentaho

WORKDIR /pentaho
USER pentaho
ARG PENTAHO_DOWNLOAD_URL=https://sourceforge.net/projects/pentaho/files/Pentaho%208.2/server/pentaho-server-ce-8.2.0.0-342.zip/download

# Downloads pentaho
RUN wget -q -O pentaho.zip ${PENTAHO_DOWNLOAD_URL} && \
  unzip -qq pentaho.zip && \
  rm -rf pentaho.zip

RUN rm /pentaho/pentaho-server/promptuser.sh; \
  rm -rf /pentaho/pentaho-server/pentaho-solutions/system/default-content/*.zip ; \
  touch /pentaho/pentaho-server/tomcat/logs/catalina.out ; \
  touch /pentaho/pentaho-server/tomcat/logs/pentaho.log ; \
  sed -i -e 's/\(exec ".*"\) start/\1 run/' /pentaho/pentaho-server/tomcat/bin/startup.sh; 

WORKDIR /pentaho/pentaho-server

# Adds connections config files
ADD --chown=pentaho:pentaho patch-start.sh env-vars.sh set-connections.py init-postgresql.sh run.sh ./

# changes context.xml and repository.xml
RUN python set-connections.py && rm set-connections.py

# Changes start-pentaho.sh to inject env vars to jvm
RUN sh patch-start.sh && rm patch-start.sh

WORKDIR /pentaho/pentaho-server
ENTRYPOINT ["bash", "run.sh"]
