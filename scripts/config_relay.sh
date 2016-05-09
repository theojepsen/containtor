#!/bin/bash
if [ "$#" -ne 5 ]
then
  echo "Usage: $0  RELAY_NICKNAME  DIR_NICKNAME  DIR_IP  DIR_FINGER1  DIR_FINGER2" >&2
  exit 1
fi

MY_NICKNAME=$1
DIR_NICKNAME=$2
DIR_IP=$3
DIR_FINGER1=$4
DIR_FINGER2=$5
MY_IP_ADDR=$(ifconfig | grep -A 1 eth0 | tail -n 1 | sed 's/.*addr:\(.*\) Bcast.*/\1/' | xargs)

cat > /etc/torrc << MYEOF
TestingTorNetwork 1
DataDirectory /var/lib/tor
RunAsDaemon 0
ConnLimit 60
Nickname $MY_NICKNAME
ShutdownWaitLength 0
PidFile /var/lib/tor/pid
Log notice file /var/lib/tor/notice.log
Log info file /var/lib/tor/info.log
ProtocolWarnings 1
SafeLogging 0
DisableDebuggerAttachment 0
DirAuthority $DIR_NICKNAME orport=5000 no-v2 v3ident=$DIR_FINGER1 $DIR_IP:7000 $DIR_FINGER2

SocksPort 0
Address $MY_IP_ADDR
ControlPort 9051
OrPort 5000
#ControlListenAddress 0.0.0.0
#HashedControlPassword 16:EBF2E14BB84A01766064F6E0E973D82C95C7A30AB1EFBD725F39F2E535 # 1234

# An exit policy that allows exiting to IPv4 LAN
ExitPolicy accept 0.0.0.0/32:*

ContactInfo your@contact.info
MYEOF

# Add tools and scripts to PATH
echo "export PATH=/shared/bin:\$PATH" >> /root/.bashrc

rm -rf /var/lib/tor
mkdir -p /var/lib/tor/keys
tor -f /etc/torrc --list-fingerprint --orport 1 \
  --dirserver "x 127.0.0.1:1 ffffffffffffffffffffffffffffffffffffffff" \
  --datadirectory /var/lib/tor
