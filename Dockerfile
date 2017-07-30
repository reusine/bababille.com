FROM debian:stable-slim

RUN apt-get update

# Install Python.
RUN apt-get install -y python python-dev python-pip
# Install Nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && apt-get install -y nodejs
# Install Ruby
RUN apt-get install -y ruby-full
