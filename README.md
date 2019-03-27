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

The easiest way of installing is to get it from Sipwise repository:
```bash
echo 'deb http://deb.sipwise.com/spce/mr7.1.1/ stretch main' > /etc/apt/sources.list.d/sipwise.list
echo 'deb-src http://deb.sipwise.com/spce/mr7.1.1/ stretch main' >> /etc/apt/sources.list.d/sipwise.list
apt-get update
apt-get install -y --allow-unauthenticated ngcp-keyring
apt-get update
apt-get install -y ngcp-rtpengine
```

After you have successfully installed RTPEngine, copy the configuration from this repository.
```bash
cd Skype-Kamailio-PSTN-gateway
cp etc/default/ngcp-rtpengine-daemon /etc/default/
cp etc/rtpengine/rtpengine.conf /etc/rtpengine/
/etc/init.d/ngcp-rtpengine-daemon restart
```

## Install IPTables firewall (optional)
RTPEngine handles the chain for itself, but make sure to not block the RTP-ports it is using. Take a look in iptables.sh for details, and apply it by doing the following. This will persist after reboot. You can run the iptables.sh script at any time after it is set up.
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
/etc/init.d/kamailio restart
```

## Setup domain and number handling in Kamailio
Insert the `kamailio.sql` into mysql using something like:
```bash
mysql -u root -p < kamailio.sql
```


Take a look in `kamailio.sql` for examples of numbers/domains/mediation servers/proxies.

To add a mediation server:
1. `INSERT` the mediation server into `address` table with `grp` field set to something in the range 300 -> 399
	- Note: If you have a Skype for Business site/pool with several mediation servers, add them with the same `grp` field
2. `INSERT` the number series belonging to the mediation server (pool/site) into `carrierroute` table with `rewrite_host` set to the skype-sip-domain the number series belongs to
3. `INSERT` the mediation server into `dispatcher` table with `setid` field set to same number chosen for the `grp` field in the `address` table
4. `INSERT` the SIP domain of the number series into `domain_lookup` table with `groupid` field set to same number chosen for the `grp` field in the `address` table


By default, outbound calls from Skype for Business are dispatched to dispatcher group 200. Take a look in `kamailio.sql` for examples on adding a proxy.

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
