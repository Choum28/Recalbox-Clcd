#!/usr/bin/env bash

# Author       : paradadf
# Creation date: 09/05/2018

echo "Installation script for Recalbox-CLCD"

PS3='Please enter your choice: '
options=("Install" "Uninstall" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo "Installing Recalbox-CLCD now!"
			
			# Make Partitions rw
				mount -o remount,rw /
				mount -o remount,rw /boot
			# Enable I2C Interface
				grep -q -F 'i2c-bcm2708' /etc/modules.conf || echo 'i2c-bcm2708' >> /etc/modules.conf
				grep -q -F 'i2c-dev' /etc/modules.conf || echo 'i2c-dev' >> /etc/modules.conf
			# Activate I2C Interface
				grep -q -F '#Activate I2C' /boot/config.txt || echo '#Activate I2C' >> /boot/config.txt
				grep -q -F 'dtparam=i2c1=on' /boot/config.txt || echo 'dtparam=i2c1=on' >> /boot/config.txt
				grep -q -F 'dtparam=i2c_arm=on' /boot/config.txt || echo 'dtparam=i2c_arm=on' >> /boot/config.txt
			# Activate I2C Bus
				grep -q -F 'bcm2708.vc_i2c_override=1' /boot/cmdline.txt || sed -i ' 1 s/.*/& bcm2708.vc_i2c_override=1/' /boot/cmdline.txt
				
			# Check I2C Address (reboot if needed)
				if [[ $(i2cdetect -l) == "" ]]; then
					echo 'System is going down for reboot! Re-run installation afterwards!'
					while true; do echo -n .; sleep 1; done & 
					sleep 5
					kill $!; trap 'kill $!' SIGTERM
					echo ' shutting down now!'
					shutdown -r now
					exit 1
				else
					i2c_detect=$(i2cdetect -y 1 | grep '\-\-' | cut -d: -f2 | grep [0-9a-fA-F] | awk '{ i = 1; while (i <= NF) { if($i != "--") print $i; i++} }')
					i2c_address="0x${i2c_detect}"
				fi
				
			# Make Partition rw
				mount -o remount,rw /
			# Download scripts
				baseURL=https://raw.githubusercontent.com/Choum28/Recalbox-Clcd/master/clcd
				wget -q --show-progress -N -P /recalbox/scripts/clcd/ $baseURL/I2C_LCD_driver.py && chmod u+x /recalbox/scripts/clcd/I2C_LCD_driver.py
				wget -q --show-progress -N -P /recalbox/scripts/clcd/ $baseURL/lcdScroll.py && chmod u+x /recalbox/scripts/clcd/lcdScroll.py
				wget -q --show-progress -N -P /recalbox/scripts/clcd/ $baseURL/recalbox_clcd.lang && chmod u+x /recalbox/scripts/clcd/recalbox_clcd.lang
				wget -q --show-progress -N -P /recalbox/scripts/clcd/ $baseURL/recalbox_clcd.py && chmod u+x /recalbox/scripts/clcd/recalbox_clcd.py
				wget -q --show-progress -N -P /recalbox/scripts/clcd/ $baseURL/recalbox_clcd_off.py && chmod u+x /recalbox/scripts/clcd/recalbox_clcd_off.py
				wget -q --show-progress -N -P /etc/init.d/ ${baseURL::-5}/S97LCDInfoText && chmod u+x /etc/init.d/S97LCDInfoText
			# Add correct I2C Address
				sed -i "s/^ADDRESS =.*/ADDRESS = $i2c_address/" /recalbox/scripts/clcd/I2C_LCD_driver.py
			# Start Recalbox-CLCD
				/etc/init.d/S97LCDInfoText start
			# Make Partitions ro
				mount -o remount,ro /
				mount -o remount,ro /boot
				break
            ;;
        "Uninstall")
            echo "Uninstalling Recalbox-CLCD now!"
			
			# Make Partitions rw
				mount -o remount,rw /
				mount -o remount,rw /boot
			# Stop Recalbox-CLCD
				/etc/init.d/S97LCDInfoText stop & sleep 0.5
			# Disable I2C Interface
				sed -i '/i2c-bcm2708/d' /etc/modules.conf
				sed -i '/i2c-dev/d' /etc/modules.conf
				sed -i '/#Activate I2C/d' /boot/config.txt
				sed -i '/dtparam=i2c1=on/d' /boot/config.txt
				sed -i '/dtparam=i2c_arm=on/d' /boot/config.txt
				sed -i 's/\<bcm2708.vc_i2c_override=1\>//g' /boot/cmdline.txt
			# Delete scripts
				rm -r /recalbox/scripts/clcd/ & rm /etc/init.d/S97LCDInfoText
			# Make Partitions ro
				mount -o remount,ro /
				mount -o remount,ro /boot
				break
            ;;
        "Quit")
            break
            ;;
        *) echo Invalid option;;
    esac
done
