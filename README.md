# Skype for Business/Lync PSTN gateway with Kamailio
How to setup Kamailio + RTPEngine to enable PSTN calling from Skype for Business/Lync. This configuration currently only supports SIP over TCP and unencrypted RTP. It is able to handle multiple domains from multiple mediation servers.

This setup is for Debian 9 Stretch.

## Architecture
This setup handles the green boxes in the diagram only.

![Skype for Business - PSTN architecture](https://raw.githubusercontent.com/havfo/Skype-Kamailio-PSTN-gateway/master/images/skype-kamailio-pstn.png "Skype for Business - PSTN architecture")

## Get configuration files
All files needed to setup all components on Debian 9 Stretch.
```bash
git clone https://github.com/havfo/Skype-Kamailio-PSTN-gateway.git
cd Skype-Kamailio-PSTN-gateway
find . -type f -print0 | xargs -0 sed -i 's/XXXX-XXXX/PUT-FQDN-OF-YOUR-SIP-SERVER-HERE/g'
find . -type f -print0 | xargs -0 sed -i 's/XXX-XXX/PUT-IP-OF-YOUR-SIP-SERVER-HERE/g'
```

## Install RTPEngine
This will do the RTP handling.
```bash
apt-get install build-essential dpkg-dev debhelper iptables-dev libcurl4-openssl-dev libglib2.0-dev libhiredis-dev libpcre3-dev libssl-dev markdown zlib1g-dev libxmlrpc-core-c3-dev dkms linux-headers-`uname -r` default-libmysqlclient-dev libavcodec-dev libavfilter-dev libavformat-dev libavresample-dev libavutil-dev libevent-dev libjson-glib-dev libpcap-dev
git clone https://github.com/sipwise/rtpengine.git
cd rtpengine
./debian/flavors/no_ngcp
dpkg-buildpackage
cd ..
dpkg -i ngcp-rtpengine-daemon_*.deb ngcp-rtpengine-iptables_*.deb ngcp-rtpengine-kernel-dkms_*.deb
cd Skype-Kamailio-PSTN-gateway
cp etc/default/ngcp-rtpengine-daemon /etc/default/
cp etc/rtpengine/rtpengine.conf /etc/rtpengine/
/etc/init.d/ngcp-rtpengine-daemon restart
```

## Install IPTables firewall
This is required by RTPEngine for setting up the IPTables chain, and will persist after reboot. You can run the iptables.sh script at any time after it is set up.
```bash
cd Skype-Kamailio-PSTN-gateway
chmod +x iptables.sh
cp etc/network/if-up.d/iptables /etc/network/if-up.d/
chmod +x /etc/network/if-up.d/iptables
touch /etc/iptables/firewall.conf
touch /etc/iptables/firewall6.conf
./iptables.sh
```

## Install Kamailio
```bash
apt-get install kamailio kamailio-mysql-modules kamailio-tls-modules mysql-server
cd Skype-Kamailio-PSTN-gateway
cp etc/kamailio/* /etc/kamailio/
kamdbctl create
```
Select yes (Y) to all options.

```bash
mysql -u root -p < kamailio.sql
/etc/init.d/kamailio restart
```

## Skype for Business configuration
1. Configure PSTN GW in topology builder using TCP and port 5065
2. Configure trunk in Skype for Business/Lync Control Panel > Voice Routing > Trunk Configuration
	- Change "Encryption support level:" to Disabled
	- Change "Refer support:" to None
	- Make sure "Enable media bypass" is unchecked
	- Make sure "Centralized media processing" is checked
	- Make sure "Enable RTP latching" is unchecked
	- Make sure "Enable forward call history" is checked
	- Make sure "Enable forward P-Asserted-Identity data" is checked
	- Make sure "Enable outbound routing failover timer" is checked
3. Configure voice route in Skype for Business/Lync Control Panel > Voice Routing > Voice Policy/Route/PSTN Usage
	- The voice route supports all types of forwarding/delegation/park and so on


## Testing
Call in/out to/from a Skype for Business user and make sure you use full E164 number format in your dial-plans.
