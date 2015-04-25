#!/bin/bash

# folder and config
VARNISH_FOLDER=/etc/varnish
CONFIG_FOLDER=${VARNISH_FOLDER}/config
CONFIG_FILE=${CONFIG_FOLDER}/config.vcl

# patch the config file with the appropriate variables
echo "Patching BACKEND_IP: " $GHOST_PORT_2368_TCP_ADDR
echo "Patching BACKEND_PORT: " $GHOST_PORT_2368_TCP_PORT
sed -e "s,%BACKEND_IP%,$GHOST_PORT_2368_TCP_ADDR,g;" -i $CONFIG_FILE
sed -e "s,%BACKEND_PORT%,$GHOST_PORT_2368_TCP_PORT,g;" -i $CONFIG_FILE

# start varnish
echo "Starting varnish"
varnishd -f $CONFIG_FILE -s malloc,$VARNISH_STORAGE_AMOUNT \
   	-a 0.0.0.0:$VARNISH_PORT -p sess_timeout=$VARNISH_SESS_TIMEOUT \
   	-T localhost:$VARNISH_CONSOLE_PORT

# start the log
echo "Starting varnishlog"
varnishlog
