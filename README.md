# ContainTor
Emulate a Tor network with Docker

## Quickstart
Edit the network parameters in `setup_network.sh`, then run:

    ./setup_network.sh

You can then make a HTTP request from the client through Tor:

    docker exec -ti torclient1 curl --socks5-hostname 127.0.0.1:9011 google.com

To check the status of the Tor daemons, use `arm`:

    docker exec -ti torclient1 arm

## More configuration
There are more options to set in `setup_network.sh`. No special characters
(including underscores) in node nicknames, please.

## Adding more nodes

### `./add_relay.sh`
Add another relay node to an existing ContainTor network. E.g.

     echo "torrelay4,10.2.0.4" | ./add_relay.sh tornet tordirectory 10.9.0.1

### `./add_client.sh`
Add another client node to an existing ContainTor network. E.g.

    echo "torclient2,10.1.0.2" | ./add_client.sh tornet tordirectory 10.9.0.1

## Troubleshooting
It can take some time for the Tor nodes to find each other. It can help to
restart them:

    docker restart torclient1
