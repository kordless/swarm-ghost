# Pull base image.
FROM dockerfile/ubuntu

# aptitude update and install
RUN apt-get update
RUN apt-get install -y mysql-client mysql-client-5.5 python-pip
RUN	apt-get clean
RUN	rm -rf /var/lib/apt/lists/*

# install aws cli client
RUN pip install awscli

# Install Node.js
RUN \
  cd /tmp && \
  wget http://nodejs.org/dist/v0.10.36/node-v0.10.36.tar.gz && \
  tar xvzf node-v0.10.36.tar.gz && \
  rm -f node-v0.10.36.tar.gz && \
  cd node-v* && \
  ./configure && \
  CXX="g++ -Wno-unused-local-typedefs" make && \
  CXX="g++ -Wno-unused-local-typedefs" make install && \
  cd /tmp && \
  rm -rf /tmp/node-v* && \
  npm install -g npm && \
  echo -e '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# install ghost
RUN \
  cd /tmp && \
  wget https://ghost.org/zip/ghost-latest.zip && \
  unzip ghost-latest.zip -d /ghost && \
  rm -f ghost-latest.zip && \
  cd /ghost && \
  npm install mysql &&\
  npm install --production &&\
  useradd ghost --home /ghost

# set env, volume and working directory
ENV NODE_ENV production
VOLUME ["/data", "/ghost-override"]
WORKDIR /ghost

# copy over start script
COPY start.sh start.sh

# copy ghost files
COPY ghost-files/* /ghost-override/

# crontab and script for backup
COPY backup.sh backup.sh
COPY cron.conf cron.conf

# start ghost
# CMD ["bash", "/ghost/start.sh"]

# if you need to debug...comment out line above and uncomment this
CMD ["bash"] 

# listen on this port
EXPOSE 2368
