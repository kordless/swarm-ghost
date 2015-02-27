FROM dockerfile/ghost

RUN apt-get update

RUN apt-get install -y mysql-client

RUN cd /ghost \
    && npm install mysql \
    && npm install --production

ENV NODE_ENV production

VOLUME ["/data", "/ghost-override"]

WORKDIR /ghost

# copy and run the tmp.sh patch file
COPY tmp.sh tmp.sh
RUN /ghost/tmp.sh

CMD ["bash", "/ghost-start"]

EXPOSE 2368
