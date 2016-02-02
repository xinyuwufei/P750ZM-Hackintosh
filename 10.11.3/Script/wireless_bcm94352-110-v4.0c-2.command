#!/bin/sh
# Maintained by: toleda for: github.com/toleda/wireless_half-mini
gFile="wireless_bcm94352-110.command_v4.0c"
# Credit: Skvo, dokterdok, the-darkvoid, Sebinouse
#
# Edits IO80211Family.kext/AirPortBrcm4360 binary for BCM94352/5 GHz band 
# and Card Type/Airport Extreme.  Edits IOBluetoothFamily binary for
# Handoff and Hotspot. Additional dsdt/ssdt/kext edits may be required 
# to enable Airport WiFi and Bluetooth.
#
# Requirements
# 1. 10.10+/Initial 10.11
# 2. BCM94352 and compatibles
# 3. IO80211Family.kext_v7.0 or newer
# 4. IOBluetoothFamily.kext_v4.3 or newer
#
# Installation
# 1. Downloads/wireless_bcm94352-110_patch.command
# 2. Double click wireless_bcm94352-110_patch.command
# 3. Select patch option
# 4. Enter password at prompt
#
# Versions
# v1: BT4LE Handoff, 4352 5 GHz (FCC or ROW), supports 10.10, 10.10.1
# v2: BT4LE Handoff, 4352 5 GHz (FCC or ROW), supports above, 10.10.2
# v3: BT4LE Handoff, 4352 5 GHz (US or supported CC, XT removed), supports above, 10.10.3+
# v4: BT4LE Handoff, initial 10.11 support
# v4a: Typo
# v4b: Typo/line 249, credit Issue #2
# v4c: El Capitan cp -XR fix
#
echo " "
echo "Agreement"
echo "The wireless_bcm94352-110_patch is for personal use only.  Do not"
echo "distribute the patch or the resulting patched IO80211Family.kext" 
echo "or IOBluetoothFamily.kext for any reason without permission. The" 
echo "wireless_bcm94352-110_patch is provided as is and without any kind"
echo "of warranty."
echo " "

# set initial variables
gExtensionsDirectory=/System/Library/Extensions
g80211ContentsDirectory=$gExtensionsDirectory/IO80211Family.kext/Contents
gAirPortBrcm4360binaryDirectory=$g80211ContentsDirectory/PlugIns/AirPortBrcm4360.kext/Contents/MacOS
gccascii=US
gcchex=5553
gSysVer=`sw_vers -productVersion`
gDebug=0
echo "$gFile"

# 4352 5 GHz patch
# credit: the-darkvoid/10.10+
pipe="|"
gFind="4183fcff742c48"
gRplc="66c7065553eb2b"

# verify system version
case ${gSysVer} in

10.11* ) gSysName="El Capitan"
gSysFolder=/kexts/10.11
;;
10.10* ) gSysName="Yosemite"
gSysFolder=/kexts/10.10
;;
10.9* ) gSysName="Mavericks"
gSysFolder=/kexts/10.9
;;
10.8* ) gSysName="Mountain Lion"
gSysFolder=/kexts/10.8
;;

* )
echo "OS X Version: $gSysVer is not supported"
echo "No system files were changed"
echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
exit 1
;;

esac

# debug
if [ $gDebug = 1 ]; then
    echo "Debug Mode"
    echo "System version: $gSysVer supported"
    echo "Desktop/IOBluetoothFamily.kext-$gSysVer available?"
    echo "Desktop/IO80211Family.kext-$gSysVer available?"
    while true
        do
        read -p "Proceed (y/n): " choice7
        case "$choice7" in
            [yY]* ) break;;
            [nN]* ) echo "No system files were changed"
            	    exit 1;;
            * ) echo "Try again..."
        ;;
        esac
    done
fi

case ${gSysVer} in

10.11* )
    echo echo "Verify boot flag/argument: rootless=0"
    ;;

10.10* )
    echo "Verify boot flag/argument: kext-dev-mode=1"
    ;;

esac

echo " "
echo "Patch Options:"
echo "1 - Handoff only"
echo "2 - Handoff/BCM94352/US-FCC"
echo "3 - Handoff/BCM94352/Country Code"
echo "0 - Exit script"

while true
    do
    read -p "Select Patch (1, 2, 3 or 0): " choice1
    case "$choice1" in
        1* ) break;;
        2* ) break;;
        3* ) break;;
        0* ) echo "No system files were changed"
            exit 1
            ;;
        * ) echo "Try again...";;
    esac
done

if [ $choice1 = 3 ]; then
# 4352 country code
# credit: Sebinouse
    echo "Note, script does not validate WiFi Country Code; XT is not a County Code"
    while true
    do
        read -p "Enter Country Code (i.e., DE, FR, GB, etc.): " choice2
        ccvalid=y
        chars=`echo $choice2 | wc -m`

    # debug
    if [ $gDebug = 1 ]; then
        echo $choice2
        echo $chars
    fi

    if [ $chars != 3 ]; then
        ccvalid=n
        echo "2 letters only"
    fi

    if [[ ${choice2:0:1} = [0-9] ]]; then
        ccvalid=n
        echo 'No numbers'
    fi

    if [[ ${choice2:1:1} = [0-9] ]]; then
        ccvalid=n
        echo 'No numbers'
    fi

    case "$ccvalid" in
        y* ) break;;
        * ) echo "Try again...";;
    esac
    done

    gccascii=`echo $choice2 | tr '[a-z]' '[A-Z]'`
    cchexx=$(xxd -pu <<< "$gccascii")
    gcchex=${cchexx:0:4}

    # debug
    if [ $gDebug = 1 ]; then
        echo "Country Code success"
        echo "$gccascii"
        echo "$gcchex"
    fi

    gRplc=${gRplc:0:6}${gcchex:0:4}${gRplc:10:4}

    # debug
    if [ $gDebug = 1 ]; then
        echo "Country Code patch"
        echo "$gRplc"
    fi
fi # $choice1 = 3

# backup S/L/E/IOBluetoothFamily.kext
if [ $gDebug = 0 ]; then
# if [ $gDebug = 1 ]; then
    if [ -e "/Users/$(whoami)/Desktop/IOBluetoothFamily-$gSysVer.kext" ]; then
        sudo rm -R Desktop/IOBluetoothFamily-$gSysVer.kext
    fi
    sudo cp -XR /System/Library/Extensions/IOBluetoothFamily.kext Desktop/IOBluetoothFamily-$gSysVer.kext
    echo " "
    echo "Copy S/L/E/IOBluetoothFamily.kext to Desktop/IOBluetoothFamily-$gSysVer.kext"

    else
    if [ -e "/Users/$(whoami)/Desktop/IOBluetoothFamily.kext" ]; then
    sudo rm -R /System/Library/Extensions/IOBluetoothFamily.kext
    sudo cp -XR Desktop/IOBluetoothFamily.kext /System/Library/Extensions/IOBluetoothFamily.kext
    else
    echo "Desktop/IOBluetoothFamily.kext not available"
    exit 1
    fi
fi

case ${gSysVer} in

10.10* )
# 10.10 handoff (choice1 = 1, 2 or 3)
# credit; doktordok
# find: 4885C0745C0FB748
# rplc: 41BE0F000000EB59

    if [ $gDebug = 0 ]; then
    sudo perl -pi -e 's|\x48\x85\xC0\x74\x5C\x0F\xB7\x48|\x41\xBE\x0F\x00\x00\x00\xEB\x59|g' /System/Library/Extensions/IOBluetoothFamily.kext/Contents/MacOS/IOBluetoothFamily
    fi
    ;;

10.11* )
# 10.11 handoff (choice1 = 1, 2 or 3)
# credit; isai9093
# find: 4885ff7447488b07
# rplc: 41be0f000000eb4

if [ $gDebug = 0 ]; then
    sudo perl -pi -e 's|\x48\x85\xFF\x74\x47\x48\x8B\x07|\x41\xBE\x0F\x00\x00\x00\xEB\x44|g' /System/Library/Extensions/IOBluetoothFamily.kext/Contents/MacOS/IOBluetoothFamily
    fi
    ;;

* )
    echo "OS X Version: $gSysVer is not supported"
    echo "No system files were changed"
    echo "To save a Copy to this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
    ;;

esac

# debug
if [ $gDebug = 1 ]; then
    echo "Patch Handoff: IOBluetoothFamily binary"
fi

# 4352 wifi (choice1 = 2 or 3)
# backup S/L/E/IO80211Family.kext

if [ $choice1 != 1 ]; then

if [ $gDebug = 0 ]; then
# if [ $gDebug = 1 ]; then
    if [ -e "/Users/$(whoami)/Desktop/IO80211Family-$gSysVer.kext" ]; then
        sudo rm -R Desktop/IO80211Family-$gSysVer.kext
    fi
    sudo cp -XR /System/Library/Extensions/IO80211Family.kext Desktop/IO80211Family-$gSysVer.kext
    echo "Copy S/L/E/IO80211Family.kext to Desktop/IO80211Family-$gSysVer.kext"

    else
    if [ -e "/Users/$(whoami)/Desktop/IO80211Family.kext" ]; then
        sudo rm -R /System/Library/Extensions/IO80211Family.kext
        sudo cp -R Desktop/IO80211Family.kext /System/Library/Extensions/IO80211Family.kext
        else
        echo "Desktop/IO80211Family.kext.kext not available"
        exit 1
    fi
fi

# 4352 airport
# credit: Skvo
# find: 6B100000750d
# rplc: 6B1000009090

if [ $gDebug = 0 ]; then
    sudo perl -pi -e 's|\x6B\x10\x00\x00\x75\x0d|\x6B\x10\x00\x00\x90\x90|g' /System/Library/Extensions/IO80211Family.kext/Contents/PlugIns/AirPortBrcm4360.kext/Contents/MacOS/AirPortBrcm4360
fi

# debug
if [ $gDebug = 1 ]; then
    patch=Airport
    echo "Patch 4352/$patch: AirPortBrcm4360 binary"
fi

# 4352 5 GHz patch
# credit: the-darkvoid/10.10+

case ${gSysVer} in

10.10*|10.11* )

    patch=$gFind$pipe$gRplc
    sudo xxd -ps $gAirPortBrcm4360binaryDirectory/AirPortBrcm4360 | tr -d '\n' > /tmp/AirPortBrcm4360.txt
    sudo /usr/bin/perl -pi -e 's|'$patch'|g' /tmp/AirPortBrcm4360.txt
    sudo xxd -r -p /tmp/AirPortBrcm4360.txt $gAirPortBrcm4360binaryDirectory/AirPortBrcm4360
    sudo rm -R /tmp/AirPortBrcm4360.txt

    # debug
    if [ $gDebug = 1 ]; then
        echo "patch success"
        echo "patch = $patch"
    fi

;;

* ) echo "OS X Version: $gSysVer is not supported"
    echo "No system files were changed"
    echo "To save a Copy to this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
;;
esac

# debug
if [ $gDebug = 1 ]; then
    echo "Patch 4352/$patch: AirPortBrcm4360 binary"
fi

fi # $choice1 != 1

# exit if error
if [ "$?" != "0" ]; then
    echo "Error occurred, see message above"
    echo "Restore Desktop/IO80211Family-$gSysVer.kext and IOBluetoothFamily-$gSysVer.kext"
    echo "To save a copy of this Terminal session: Terminal/Shell/Export Text As ..."
    exit 1
fi


# Fix permissions and rebuild cache
case ${gSysVer} in

10.10*|10.11* )
    echo "Fix permissions ..."
    sudo chown -R root:wheel /System/Library/Extensions/IO80211Family.kext
    sudo chown -R root:wheel /System/Library/Extensions/IOBluetoothFamily.kext
    echo "Kernel cache..."
    sudo touch $gExtensionsDirectory
    sudo kextcache -Boot -U /
    ;;

10.8*|10.9* )
    echo "Fix permissions ..."
    sudo chown -R root:wheel /System/Library/Extensions/IO80211Family.kext
    sudo chown -R root:wheel /System/Library/Extensions/IOBluetoothFamily.kext
    echo "Kernel cache..."
    sudo touch $gExtensionsDirectory
    echo "Allow a few minutes for kernel cache rebuild."
    ;;

esac

# exit if error
# if [ "$?" != "0" ]; then
# echo Error: Maintenance failure
# echo "Verify Permissions"
# echo "Rebuild Kernel Cache"
# echo "Verify S/L/E/IO80211Family.kext and/or"
# echo "Verify S/L/E/IOBluetoothFamily.kext"
# echo "To save a Copy of this Terminal session: Terminal/Shell/Export Text As ..."
# exit 1
# fi

echo " "
echo "To save a copy of this Terminal session: Terminal/Shell/Export Text As ..."
echo "Finished, restart required."
exit 0