FROM centos:6

MAINTAINER Sara Vallero <svallero@to.infn.it>

# Install ruby 2.3
RUN   set -ex \
      && yum -y install https://github.com/feedforce/ruby-rpm/releases/download/2.3.3/ruby-2.3.3-1.el6.x86_64.rpm \
      && yum -y groupinstall 'Tool di sviluppo' \
      && yum -y install zlib-devel mysql-devel sqlite-devel libcurl-devel \
      && yum clean all

RUN   gem install json mysql rack sequel thin uuidtools sqlite3-ruby sinatra nokogiri --no-ri --no-rdoc  

RUN   set -ex \
      && yum -y install genisoimage log4cpp numpy xmlrpc-c \
      yum clean all

# Install rOCCI
RUN   gem install bundler --no-ri --no-rdoc 
RUN   gem install rack --no-ri --no-rdoc
RUN   gem install rake --no-ri --no-rdoc
RUN   gem install passenger --no-ri --no-rdoc

RUN   set -ex \
      && yum -y install httpd httpd-devel mod_ssl memcached mod_security policycoreutils policycoreutils-python \
      && yum clean all 

RUN   passenger-install-apache2-module -a 

COPY  files/rocci-server.repo /etc/yum.repos.d/rocci-server.repo 

COPY  files/occi-server-1.1.9+20160622122112-1.el6.x86_64.rpm occi-server-1.1.9.rpm
 
RUN   rpm -hiv --nodeps occi-server-1.1.9.rpm

COPY  files/passenger.conf /etc/httpd/conf.d/passenger.conf

RUN   echo Listen 11443 >> /etc/httpd/conf/httpd.conf 

# Install CA policy
RUN   mkdir /etc/grid-security/

COPY  files/EGI-trustanchors.repo /etc/yum.repos.d/EGI-trustanchors.repo

RUN   set -ex \
      && yum install -y ca-policy-egi-core \
      && yum clean all

# SSl configuration for rOCCI
COPY  files/occi-ssl.conf  /etc/httpd/conf.d/occi-ssl.conf

# Start rOCCI server
#RUN   set -ex \
#      && yum install -y openssh-server \
#      && yum clean all

#RUN   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
#RUN   sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config 

COPY   files/hostcert.pem /etc/grid-security/hostcert.pem
COPY   files/hostkey.pem /etc/grid-security/hostkey.pem

EXPOSE 11443

# Supervisor
RUN   set -ex \
      && yum install -y epel-release \
      && yum install -y python-pip python-meld3 \
      && yum clean all
 
RUN   pip install supervisor supervisor-stdout

COPY  files/supervisor.conf /etc/supervisor/conf.d/supervisor.conf


ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/conf.d/supervisor.conf"]
