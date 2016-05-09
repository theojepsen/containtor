#!/bin/bash

if [ -z "$DIR_NICK" ]
then
    if [ $# -ne 1 ]
    then
        echo Usage: $0 DIR_NICK
        exit 1
    fi
    DIR_NICK=$1
fi

MY_IP_ADDR=$(ifconfig | grep -A 1 eth0 | tail -n 1 | sed 's/.*addr:\(.*\) Bcast.*/\1/' | xargs)

cat > /etc/torrc << MYEOF
TestingTorNetwork 1
DataDirectory  /var/lib/tor
RunAsDaemon 0
ConnLimit 60
Nickname $DIR_NICK
ShutdownWaitLength 0
PidFile /var/lib/tor/pid
Log notice file /var/lib/tor/notice.log
Log info file /var/lib/tor/info.log
ProtocolWarnings 1
SafeLogging 0
DisableDebuggerAttachment 0
DirAuthority $DIR_NICK orport=5000 no-v2 v3ident=replacefinger1 $MY_IP_ADDR:7000 replacefinger2

SocksPort 0
Address $MY_IP_ADDR
DirPort 7000
ControlPort 9051
#ControlListenAddress 0.0.0.0
#HashedControlPassword 16:EBF2E14BB84A01766064F6E0E973D82C95C7A30AB1EFBD725F39F2E535 # 1234
OrPort 5000

AuthoritativeDirectory 1
V3AuthoritativeDirectory 1
ContactInfo your@contact.info
ExitPolicy reject *:*
TestingV3AuthInitialVotingInterval 300
TestingV3AuthInitialVoteDelay 20
TestingV3AuthInitialDistDelay 20
MYEOF

rm -rf /var/lib/tor
mkdir -p /var/lib/tor/keys

tor-gencert --create-identity-key -m 12 -a $MY_IP_ADDR:7000 \
  -i /var/lib/tor/keys/authority_identity_key \
  -s /var/lib/tor/keys/authority_signing_key \
  -c /var/lib/tor/keys/authority_certificate \
  --passphrase-fd 9 9<<< 1234

tor -f /etc/torrc --list-fingerprint --orport 1 \
  --dirserver "x 127.0.0.1:1 ffffffffffffffffffffffffffffffffffffffff" \
  --datadirectory /var/lib/tor

MY_FINGER1=$(grep fingerprint /var/lib/tor/keys/authority_certificate  | cut -d' ' -f2)
MY_FINGER2=$(cat /var/lib/tor/fingerprint  | cut -d' ' -f2)

sed -i "s/replacefinger1/$MY_FINGER1/" /etc/torrc 
sed -i "s/replacefinger2/$MY_FINGER2/" /etc/torrc 
