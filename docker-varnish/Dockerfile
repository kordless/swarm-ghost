FROM ubuntu:trusty
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Update the package repository and install applications
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install gettext && \
    apt-get -y install varnish=3.0.5-2 && \
    apt-get -y clean

# The size of the cache eg 100M = 100 Megabytes or 1G = 1 Gigabyte
ENV VARNISH_STORAGE_AMOUNT 100M

# Idle timeout for persistent sessions
ENV VARNISH_SESS_TIMEOUT 20

# Varnish Management Console Port
ENV VARNISH_CONSOLE_PORT 2000

# The default configuration template will be copied to the config folder, in
# script start.sh, if it doesn't exist. Note: the template is a VCL file which
# allows environmental variables.
RUN mkdir /etc/varnish/config
RUN rm /etc/varnish/default.vcl # Installed by default and not used.
ADD config.vcl /etc/varnish/config/config.vcl

# The port on which Varnish will listen.
ENV VARNISH_PORT 80
EXPOSE 80

# We can specify our own config.template via this volume.
VOLUME ["/etc/varnish/config"]

ADD start.sh /start.sh
CMD ["/start.sh"]