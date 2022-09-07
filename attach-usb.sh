#!/bin/bash

print_help(){
    echo "usage:"
    echo "  attach-usb.sh -d <kvm domain> -v <vid> -p <pid> -m <method> -i"
    echo "      required [-d,-v,-p]"
    echo "      optional [-m, -i (interactive)]"
    echo "  methods:"
    echo "      'attach' - reattaches device (default)"
    echo "      'detach' - detaches device"
    echo "  example:"
    echo "      attach-usb.sh -d win10 -v 12ab -p 34bc -m detach -i"
}

generate_xml(){
    detach_fname="./detach-usb-$1.xml"
    fname="./attach-usb-$1.xml"
    
    # idk how to get available domain ports
    port=$( expr $1 + 5 )

    echo "<hostdev mode=\"subsystem\" type=\"usb\" managed=\"yes\">" > $detach_fname #remove old xml
    echo "  <source>" >> $detach_fname
    echo "    <vendor id=\"0x$vid\"/>" >> $detach_fname
    echo "    <product id=\"0x$pid\"/>" >> $detach_fname
    echo "    <address bus=\"$2\" device=\"$3\"/>" >> $detach_fname
    echo "  </source>" >> $detach_fname
    cp $detach_fname $fname
    echo "</hostdev>" >> $detach_fname

    echo "  <address type=\"usb\" bus=\"0\" port=\"$port\"/>" >> $fname
    echo "</hostdev>" >> $fname
}

method="attach"

while getopts d:v:p:m:i flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
        v) vid=${OPTARG};;
        p) pid=${OPTARG};;
        m) 
            t=${OPTARG}
            if [ $t == "detach" ] || [ $t == "attach" ]; then
                method=$t
            else
                echo "unknown method $t"
                print_help
                exit 1
            fi
        ;;
        i) interactive=1
    esac
done

if [ -z "$domain" ] || [ -z "$vid" ] || [ -z "$pid" ]; then
    print_help
    exit 1
fi

array=($(lsusb | grep $vid:$pid))
buses=()
devices=()

# parse pid and vid

for i in ${!array[*]}
do
    if [ "${array[$i]}" == "Bus" ]; then
        tmp=$(( 10#${array[$i+1]} ))
        buses+=($tmp)
        echo "bus[${#buses[@]}] ${buses[-1]}"
    fi
    
    if [ "${array[$i]}" == "Device" ]; then
        tmp=$(( 10#$(echo ${array[$i+1]} | rev | cut -c2- | rev) ))
        devices+=($tmp)
        echo "device[${#devices[@]}] ${devices[-1]}"
    fi
done

devices_num=${#buses[@]}

if (( $devices_num == 0 )); then
    echo "Device $vid:$pid not found"
    exit 1
fi

if [ -x $interactive ]; then
    for i in ${!devices[*]}
    do
        generate_xml $i ${buses[$i]} ${devices[$i]}
        virsh detach-device --domain $domain --file "./detach-usb-$i.xml"
        if [ $method == "attach" ]; then
            virsh attach-device --domain $domain --file  "./attach-usb-$i.xml"
        fi
    done
else
    for i in ${!devices[*]}
    do
        read -p "Procceed with $vid:$pid on bus=${buses[$i]} device=${devices[$i]} [Y/n]?" yn
        case $yn in
            [Yy]* ) 
                generate_xml $i ${buses[$i]} ${devices[$i]}
                virsh detach-device --domain $domain --file "./detach-usb-$i.xml"
                if [ $method == "attach" ]; then
                    virsh attach-device --domain $domain --file "./attach-usb-$i.xml"
                fi
            ;;
            [Nn]* ) exit 0;;
        esac
    done
fi



