#!/usr/bin/sh
# This script enable usb hid gadget, need sudo permission
# 0x409 ini the script is language code for LANG_ENGLISH

#check sudo
if test "$(id -u)" != "0";then
	echo "Please retry with sudo."
	exit
else
	echo "running under sudo..."
fi
cd $(dirname $0)
shellDir=$(pwd)
##############################[ User Settings begin]##########################################################
# Gadget Setting
configfsDir="/sys/kernel/config"         #dir to the mount point of configfs, run `mount -l |grep configfs` if you don't know
usb_gadgetDir="${configfsDir}/usb_gadget"
gadgetName="my_gadget" #set as you like
idVendor=0x0525 # don't change unless you have a id of you own
idProduct=0xa4ac # don't change unless you have a id of you own
UDC=$(ls /sys/class/udc) # edit this line if `ls /sys/class/udc` output more than one results.

#device info
serialNumber="0001"           #set as you like
manufacturer="du33169"     #set as you like
product="simKM"       #set as you like

#configuration
configName="KM.1"   #format: <name>.<number>, number of different configurations should be different
configDesc="config for simKM" # set as you like
MaxPower="120"      #mA, no more than 500mA


#function 1
f1Type="hid" #don't change
f1Name="kbd" #set as you like
f1protocol=1 # 1 for keyboard
f1subclass=0
f1reportDescBinPath="${shellDir}/kybd-descriptor.bin" # or path to your own descriptor
f1reportLength=8


#function 2
f2Type="hid" #don't change
f2Name="ms" #set as you like
f2protocol=2 # 2 for mouse
f2subclass=0
f2reportDescBinPath="${shellDir}/mouse-descriptor.bin" # or path to your own descriptor
f2reportLength=3

##############################[ User Settings end]##########################################################
main()
{
	#main process
	gadget_setup
	##############################[ User Settings begin]##########################################################
	function_setup $f1Type $f1Name $f1protocol $f1subclass $f1reportLength $f1reportDescBinPath
	function_setup $f2Type $f2Name $f2protocol $f2subclass $f2reportLength $f2reportDescBinPath
	# append new lines here if you have more functions 
	##############################[ User Settings end]##########################################################
	
	echo $UDC  >UDC #enable gadget
	#check devices
	for hidg in $(ls /dev/hid*);do
		echo $hidg
		chmod 666 $hidg
	done

}
gadget_setup()
{
	echo "setting up gadget..."
	# entering our gadget directory
	cd ${usb_gadgetDir}
	mkdir ${gadgetName}
	cd ${gadgetName} 
	echo "current working in $(pwd)"

	# strings setting
	echo ${idVendor} > idVendor
	echo ${idProduct} > idProduct

	mkdir strings/0x409
	echo ${serialNumber} > strings/0x409/serialnumber
	echo ${manufacturer} > strings/0x409/manufacturer
	echo ${product}      > strings/0x409/product

	# config setting
	mkdir configs/${configName}
	mkdir configs/${configName}/strings/0x409 -p
	echo ${configDesc} > configs/${configName}/strings/0x409/configuration
	echo ${MaxPower} > configs/${configName}/MaxPower

	echo "gadget setup finished"
}

function_setup() #Type $Name $protocol $subclass $reportLength $reportDescBinPath
{
	echo "setting up function..."
	cd ${usb_gadgetDir}/${gadgetName} #note: in function the pwd will be reset
	echo "current working in $(pwd)"
	#should be gadget path when called
	functionType=${1} # only allowed type
	functionName=${2} # any filename
	functionId="${functionType}.${functionName}"
	protocol=${3}
	subclass=${4}
	reportLength=${5}
	reportDesc=${6}

	mkdir functions/${functionId}
	echo ${protocol} > functions/${functionId}/protocol
	echo ${subclass} > functions/${functionId}/subclass
	echo ${reportLength} > functions/${functionId}/report_length
	cat ${reportDesc} > functions/${functionId}/report_desc
	#note here is cat

	#enable function in current config
	ln -s functions/${functionId} configs/${configName}
	echo "function setup finished"
}

main




