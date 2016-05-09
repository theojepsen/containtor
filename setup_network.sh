#!/bin/bash

# export, so it can be found by other nested scripts
export NET_NAME=tornet
export NET_SUBNET="10.0.0.0/8"
export NET_GATEWAY=10.0.0.1

export DIR_NICK=tordirectory
export DIR_IP=10.9.0.1

export CLIENT_NICK_PREFIX=torclient
export RELAY_NICK_PREFIX=torrelay
export RELAY_COUNT=3
export CLIENT_COUNT=1

# The name of the ContainTor container image
export CONTAINTOR_IMAGE_NAME=containtor



SCRIPT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd "$SCRIPT_DIR"

# First, setup the docker bridge network, if it doesn't already exist
docker network ls | grep $NET_NAME
if [ $? -ne 0 ]
then
    docker network create --driver bridge --subnet "$NET_SUBNET" --gateway $NET_GATEWAY $NET_NAME
fi

# If the image doesn't exist, build it
docker images | grep -E "^$CONTAINTOR_IMAGE_NAME" > /dev/null
if [ $? -ne 0 ]
then
    docker build -t $CONTAINTOR_IMAGE_NAME .
fi

# Start the directory container
docker run -h $DIR_NICK --net=$NET_NAME --ip=$DIR_IP --name=$DIR_NICK -v $HOME/shared:/shared -itd $CONTAINTOR_IMAGE_NAME
docker exec -ti $DIR_NICK config_directory.sh $DIR_NICK
FINGERS=$(docker exec $DIR_NICK grep Authority /etc/torrc | sed 's/.*v3ident=\([A-Z0-9]*\).* \([A-Z0-9]*\)/\1 \2/')
docker exec -d $DIR_NICK tor -f /etc/torrc


for i in $(seq $RELAY_COUNT)
do
    relay_nick="$RELAY_NICK_PREFIX""$i"
    relay_ip="$(echo $NET_SUBNET | cut -d'.' -f1)"".2.0.$i"
    echo $relay_nick,$relay_ip | ./add_relay.sh
done

for i in $(seq $CLIENT_COUNT)
do
    client_nick="$CLIENT_NICK_PREFIX""$i"
    client_ip="$(echo $NET_SUBNET | cut -d'.' -f1)"".1.0.$i"
    echo $client_nick,$client_ip | ./add_client.sh
done
