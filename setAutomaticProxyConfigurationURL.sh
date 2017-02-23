#!/bin/sh
####################################################################################################
#
# More information: https://macmule.com/2014/12/07/how-to-change-the-automatic-proxy-configuration-url-in-system-preferences-via-a-script/
#
# GitRepo: https://github.com/macmule/setAutomaticProxyConfigurationURL
#
# License: http://macmule.com/license/
#
####################################################################################################
echo '####################################################################################'

# HARDCODED VALUES ARE SET HERE
autoProxyURL=""
lanternPac='http://127.0.0.1:16823/proxy_on.pac'

# CHECK TO SEE IF A VALUE WAS PASSED FOR $4, AND IF SO, ASSIGN IT
if [ "$1" != "" ] && [ "$autoProxyURL" == "" ]; then
	autoProxyURL=$1
fi

# Detects all network hardware & creates services for all installed network hardware
/usr/sbin/networksetup -detectnewhardware

IFS=$'\n'

	#Loops through the list of network services
	for i in $(networksetup -listallnetworkservices | tail +2 );
	do
	
		# Get a list of all services beginning 'Ether' 'Air' or 'VPN' or 'Wi-Fi'
		# If your service names are different to the below, you'll need to change the criteria
        proxyState=`networksetup -getautoproxyurl "$i" | tail -1 | cut -c 10-`
        #echo `date +"%l:%M:%S %p"`  "$i proxystate: $proxyState ."
        if [[ $proxyState =~ "Yes" ]]; then
            PacUrl=`/usr/sbin/networksetup -getautoproxyurl "$i" | head -1 | cut -c 6-`
        else
            PacUrl=""
        fi
        #echo `date +"%l:%M:%S %p"`  "$i proxystate: $PacUrl ."

        if [[ -z $PacUrl ]]; then
            #echo `date +"%l:%M:%S %p"`  "$i pac not set!"
            if [[ "$i" =~ 'Wi-Fi' ]] ; then
                ssid=`/usr/sbin/networksetup -getairportnetwork en0 | cut -c 24-`
                #set dns
                /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                case "$ssid" in
                    15wxap) 
                        /usr/sbin/networksetup -setdnsservers $i "192.168.3.99"
                        autoProxyURL='http://192.168.3.99/in.pac' ;;
                    508) 
                        /usr/sbin/networksetup -setdnsservers $i "192.168.3.99"
                        autoProxyURL='http://192.168.3.99/in.pac' ;;
                    dd-wrt) 
                        /usr/sbin/networksetup -setdnsservers $i "192.168.3.99"
                        autoProxyURL='http://192.168.3.99/in.pac' ;;
                    TheUnitedNations) 
                        /usr/sbin/networksetup -setdnsservers $i "Empty"
                        autoProxyURL='http://10.20.30.40/in.pac' ;;
                    TheUnitedNations5g) 
                        /usr/sbin/networksetup -setdnsservers $i "Empty"
                        autoProxyURL='http://10.20.30.40/in.pac' ;;
                    xnai) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                    "Isulew's Iphone") 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                    FAST_FF7E) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                    Guest) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://ddns.nznd.org:8800/out.pac' ;;
                    *) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                esac
                autoProxyURLLocal=`/usr/sbin/networksetup -getautoproxyurl "$i" | head -1 | cut -c 6-`
                autoProxyIP=`echo "$autoProxyURL" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
                if [[ -z $autoProxyIP ]] ; then
                    autoProxyIP=`nslookup ddns.nznd.org | grep "Address: " | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
                    autoProxyURLLocal=$autoProxyIP
                fi
                echo `date +"%l:%M:%S %p"`  "$i Proxy IP is $autoProxyIP"
            
                # echo `date +"%l:%M:%S %p"` 's the name of any matching services & the autoproxyURL's set
                echo `date +"%l:%M:%S %p"`  "$i Proxy set to $autoProxyURLLocal"
            
                # If the value returned of $autoProxyURLLocal does not match the value of $autoProxyURL for the interface $i, change it.
                if [[ $autoProxyURLLocal != $autoProxyURL ]]; then
                    /usr/sbin/networksetup -setautoproxyurl $i $autoProxyURL
                    echo `date +"%l:%M:%S %p"`  "Set auto proxy for $i to $autoProxyURL"
                    sed -i '' "12s/.*/${autoProxyIP}   self-proxy/g" /private/etc/hosts
                    echo `date +"%l:%M:%S %p"`  "Edit private hosts to $autoProxyIP"
                fi

                # Enable auto proxy once set
                /usr/sbin/networksetup -setautoproxystate "$i" on
                echo `date +"%l:%M:%S %p"`  "Turned on auto proxy for $i" 
            fi
        else
            #echo `date +"%l:%M:%S %p"`  "$i pac is $PacUrl"
            if [[ "$i" =~ 'Wi-Fi' ]] ; then
                ssid=`/usr/sbin/networksetup -getairportnetwork en0 | cut -c 24-`
                /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                case "$ssid" in
                    15wxap) 
                        /usr/sbin/networksetup -setdnsservers $i "192.168.3.99"
                        autoProxyURL='http://192.168.3.99/in.pac' ;;
                    508) 
                        /usr/sbin/networksetup -setdnsservers $i "192.168.3.99"
                        autoProxyURL='http://192.168.3.99/in.pac' ;;
                    dd-wrt) 
                        /usr/sbin/networksetup -setdnsservers $i "192.168.3.99"
                        autoProxyURL='http://192.168.3.99/in.pac' ;;
                    TheUnitedNations) 
                        /usr/sbin/networksetup -setdnsservers $i "Empty"
                        autoProxyURL='http://10.20.30.40/in.pac' ;;
                    TheUnitedNations5g) 
                        /usr/sbin/networksetup -setdnsservers $i "Empty"
                        autoProxyURL='http://10.20.30.40/in.pac' ;;
                    xnai) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                    "Isulew's Iphone") 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                    FAST_FF7E) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                    Guest) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://ddns.nznd.org:8800/out.pac' ;;
                    *) 
                        /usr/sbin/networksetup -setdnsservers $i "127.0.0.1"
                        autoProxyURL='http://127.0.0.1:8070/proxy.pac' ;;
                esac
                autoProxyURLLocal=`/usr/sbin/networksetup -getautoproxyurl "$i" | head -1 | cut -c 6-`
                autoProxyIP=`echo "$autoProxyURL" | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
                if [[ -z $autoProxyIP ]] ; then
                    autoProxyIP=`nslookup ddns.nznd.org | grep "Address: " | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"`
                    autoProxyURLLocal=$autoProxyIP
                fi
                echo `date +"%l:%M:%S %p"`  "$i Proxy IP is $autoProxyIP"

                # echo 's the name of any matching services & the autoproxyURL's set
                echo `date +"%l:%M:%S %p"`  "$i Proxy set to $autoProxyURLLocal"

                # If the value returned of $autoProxyURLLocal does not match the value of $autoProxyURL for the interface $i, change it.
                if [[ $autoProxyURLLocal != $autoProxyURL ]]; then
                    /usr/sbin/networksetup -setautoproxyurl $i $autoProxyURL
                    echo `date +"%l:%M:%S %p"`  "Set auto proxy for $i to $autoProxyURL"
                    sed -i '' "12s/.*/${autoProxyIP}   self-proxy/g" /private/etc/hosts
                    echo `date +"%l:%M:%S %p"`  "Edit private hosts to $autoProxyIP"
                fi

                # Enable auto proxy once set
                /usr/sbin/networksetup -setautoproxystate "$i" on
                echo `date +"%l:%M:%S %p"`  "Turned on auto proxy for $i" 
            else
                if [[ $PacUrl =~ $lanternPac ]]; then
                    /usr/sbin/networksetup -setautoproxystate "$i" off
                    echo `date +"%l:%M:%S %p"`  "Turned off auto proxy for $i" 
                fi
            fi
        fi
	done

unset IFS

# echo that we're done
echo `date +"%l:%M:%S %p"`  "Auto proxy present, correct & enabled for all targeted interfaces"
