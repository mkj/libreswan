/testing/guestbin/swan-prep
ipsec setup start
/testing/pluto/bin/wait-until-pluto-started
ipsec auto --add modecfg-road-eastnet-psk
echo initdone
