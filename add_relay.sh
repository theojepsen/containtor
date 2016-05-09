#!/bin/bash

SCRIPT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$SCRIPT_DIR"

if [ -z "$NET_NAME" ] && [ -z "$DIR_NICK" ] && [ -z "$DIR_IP" ]
then
    if [ $# -ne 3 ]
    then
        echo Usage: "echo \"nick1,ip1 nick2,ip2\" |" $0 NET_NAME DIR_NICK DIR_IP
        exit 1
    fi
    NET_NAME=$1
    DIR_NICK=$2
    DIR_IP=$3
fi

if [ -z "$CONTAINTOR_IMAGE_NAME" ]; then
    CONTAINTOR_IMAGE_NAME=containtor
fi

FINGERS=$(docker exec $DIR_NICK grep Authority /etc/torrc | sed 's/.*v3ident=\([A-Z0-9]*\).* \([A-Z0-9]*\)/\1 \2/')

while read nodedesc
do
  node_nick=$(echo $nodedesc | cut -d',' -f1)
  node_ip=$(echo $nodedesc | cut -d',' -f2)
  echo "Adding relay: '$node_nick' '$node_ip'"

  docker run -h $node_nick --net=$NET_NAME --ip=$node_ip --name=$node_nick -v $HOME/shared:/shared -itd $CONTAINTOR_IMAGE_NAME
  docker exec $node_nick config_relay.sh $node_nick $DIR_NICK $DIR_IP $FINGERS
  echo docker exec $node_nick config_relay.sh $node_nick $DIR_NICK $DIR_IP $FINGERS
  docker exec -d $node_nick tor -f /etc/torrc
done
