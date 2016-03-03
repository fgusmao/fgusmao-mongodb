FROM phusion/baseimage:0.9.18

MAINTAINER Andrew T. Baker <andrew@andrewtorkbaker.com>

# Set correct environment variables
ENV HOME /root

# Install MongoDB
# Add 10gen official apt source to the sources list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list

# Install MongoDB
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org
RUN mkdir -p /data/db
RUN chown -R mongodb:mongodb /data
# Bind ip to accept external connections
RUN awk '/bind_ip/{print "bind_ip = 0.0.0.0";next}1' /etc/mongod.conf > /tmp/mongod.conf
RUN cat /tmp/mongod.conf > /etc/mongod.conf 

# Create a runit entry for your app
RUN mkdir /etc/service/mongo
ADD run_mongo.sh /etc/service/mongo/run
RUN chown root /etc/service/mongo/run

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Spin-docker currently supports exposing port 22 for SSH and
# one additional application port (Mongo runs on 27017)
EXPOSE 27017

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]
