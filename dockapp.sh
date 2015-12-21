#!/bin/bash

#
# Author: Joachim Schmidt <joachim.schmidt@openmailbox.org>
#         Robert Berger <robert.berger@reliableembeddedsystems.com>
#
# Date: 21 dec. 2015
#       27 septembre 2015
#
# Version: 0.1-en
#

# Script to ron the development environment of Xilinx/Vivado
# in a container.

VERT="\\033[1;32m"
NORMAL="\\033[0;39m"
ROUGE="\\033[1;31m"
ROSE="\\033[1;35m"
BLEU="\\033[1;34m"
BLANC="\\033[0;02m"
BLANCCLAIR="\\033[1;08m"
JAUNE="\\033[1;33m"
CYAN="\\033[1;36m"


 -d <device name>
    See the result of the lsusb command.
 -p <device_1>:<device_2>:<...>
    Mapping the list of devices.
    Devices of type /dev/ttyUSB*
    and the devices associated with
    the development board are mapped
    automatically.
 -i <name of the Docker image>
 -c <command name to be executed by Docker>
 -f <folder_1>:<folder_2>:<...>
    Mapping the folder list.
    The folder /tmp/.X11-unix is automatically
    mapped.
 -h
    Display the online help.
 -v
    Display the version of the script.


function print_help
{
    echo -e "Command: ${JAUNE}run_dockapp${NORMAL} ${VERT}<parameter list> <...>${NORMAL}"
    echo -e ""
    echo -e "Parameter list:"
    echo -e ""
    echo -e " ${BLEU}-d${NORMAL} ${VERT}<device name>${NORMAL}"
    echo -e "    See the result of the ${ROUGE}lsusb${NORMAL} command."
    echo -e " ${BLEU}-p${NORMAL} ${VERT}<device_1>:<device_2>:<...>${NORMAL}"
    echo -e "    Mapping the list of devices."
    echo -e "    ${ROUGE}Devices of type /dev/ttyUSB*${NORMAL}"
    echo -e "    ${ROUGE}and the devices associated with the${NORMAL}"
    echo -e "    ${ROUGE}development board are mapped${NORMAL}"
    echo -e "    ${ROUGE}automatically.${NORMAL}"
    echo -e " ${BLEU}-i${NORMAL} ${VERT}<name of the Docker image>${NORMAL}"
    echo -e " ${BLEU}-c${NORMAL} ${VERT}<command name to be executed by Docker>${NORMAL}"
    echo -e " ${BLEU}-f${NORMAL} ${VERT}<folder_1>:<folder_2>:<...>${NORMAL}"
    echo -e "    Mapping the folder list."
    echo -e "    ${ROUGE}The folder $X11FOLD is automatically${NORMAL}"
    echo -e "    ${ROUGE}mapped.${NORMAL}"
    echo -e " ${BLEU}-h${NORMAL}"
    echo -e "    Display the online help."
    echo -e " ${BLEU}-v${NORMAL}"
    echo -e "    Display the version of the script."
}

function print_version
{
    echo -e "Version:"
    echo -e "(run_dockapp 0.1-en)"
}

function run_dockapp
{
    local USB_BOARD="" # Variable denoting the development board.
    local BUS=""
    local DEV=""
    local DEVLST=""
    local FOLDLST=""
    local DOCKIMG=""
    local CMD="/bin/bash"
    local X11FOLD="/tmp/.X11-unix"

    #
    # Argument list of the script
    #
    # -p <device name>
    # -i <name of Docker image>
    # -c <command to be executed by Docker>
    # -f <folder for installation in Docker>
    # -h <Help>
    #

    local OPTLST=":d:p:i:c:f:hv"
    
    local opt_dev=0
    local opt_periph=0
    local opt_img=0
    local opt_cmd=0
    local opt_fold=0
    local opt
    
    OPTERR=0
    
    #
    # Display help if there is no argument.
    #
    
    if [[ $# -eq 0 ]] ; then
        print_help
        return 1
    fi

    #
    # Analyze the options received as paramters.
    #
    
    while getopts $OPTLST opt ; do
        case $opt in
            d ) opt_dev=1
                USB_BOARD=$OPTARG ;;
            p ) opt_perif=1
                DEVLST=$OPTARG ;;
            i ) opt_img=1
                DOCKIMG=$OPTARG ;;
            c ) opt_cmd=1
                CMD=$OPTARG ;;
            f ) opt_fold=1
                FOLDLST=$OPTARG ;;
            h ) print_help
                unset OPTIND
                unset OPTARG
                unset OPTERR
                return 0 ;;
            v ) print_version
                unset OPTIND
                unset OPTARG
                unset OPTERR
                return 0 ;;
            ? ) echo -e "${ROUGE}*${NORMAL} Illegal option -$OPTARG" >&2
                unset OPTIND
                unset OPTARG
                unset OPTERR
                return 1 ;;
        esac
    done

    shift $(($OPTIND - 1))
    unset opt

    #
    # Checks if there are invalid arguments remaining.
    #
    
    if [[ $# -ne 0 ]] ; then
        if [[ $# -eq 1 ]] ; then
            echo -e -n "${ROUGE}*${NORMAL} Illegal option " >&2
        else
            echo -e -n "${ROUGE}*${NORMAL} Illegal options " >&2
        fi
        
        while [[ $# -ne 0 ]] ; do
            echo -n "$1 "
            shift
        done

        echo ""

        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    #
    # It is verified that a device was mentioned in the argment
    # and recovered bus numbers and USB device numbers.
    #
    local res=0
    
    if [[ $opt_dev -ne 0 ]] ; then
        BUS_DEV=$(lsusb | grep $USB_BOARD)
        res=$?
        unset opt_dev
    else
        echo -e "${ROUGE}*${NORMAL} No development board has been specified." >&2
        echo -e ""
        print_help
        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    #
    # We verify the smooth running of the lsusb command.
    #
    
    if [[ $res -ne 0 ]] ; then
        echo -e "${ROUGE}*${NORMAL} No corresponding development board for ${ROUGE}${USB_BOARD}${NORMAL} is connected." >&2
        echo -e ""
        print_help
        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    unset res

    #
    # We verify that a Docker image was mentioned in the argument.
    #

    if [[ $opt_img -ne 0 ]] ; then
        echo -e "${VERT}*${NORMAL} Image Docker ${VERT}${DOCKIMG}${NORMAL}"
        unset opt_img
    else
        echo -e "${ROUGE}*${NORMAL} No Docker image was specified." >&2
        echo -e ""
        print_help
        unset OPTIND
        unset OPTARG
        unset OPTERR
        return 1
    fi

    #
    # We verify that a Docker command was mentioned in the argument.
    #

    if [[ $opt_cmd -ne 0 ]] ; then
        echo -e "${VERT}*${NORMAL} Command to be executed by Docker ${VERT}${CMD}${NORMAL}"
        unset opt_cmd
    else
        echo -e "${ROUGE}*${NORMAL} No command was specified." >&2
        echo -e "${ROUGE}*${NORMAL} The default command is ${VERT}${CMD}${NORMAL}" >&2
    fi

    #
    # The device list is generated to map between the host environment
    # and the environment of the container.
    #

    if [[ $opt_perif -ne 0 ]] ; then
        local TMP=$DEVLST
        DEVLST=""
    
        TMP=$(echo $TMP | awk 'BEGIN{FS=":"} {NF=NF; print $0}')

        for i in $TMP ; do
            DEVLST=$(echo "$DEVLST --device=${i}:${i}")
            echo -e "${VERT}*${NORMAL} Mapping device ${VERT}${i}${NORMAL}"
        done
        
        unset TMP
        unset opt_perif
    fi

    BUS_DEV=$(echo $BUS_DEV | awk 'BEGIN{FS=" "} {print $2 " " $4}' | awk 'BEGIN{FS=":"} {print $1}')

    BUS=$(echo $BUS_DEV | awk 'BEGIN{FS=" "} {print $1}')
    DEV=$(echo $BUS_DEV | awk 'BEGIN{FS=" "} {print $2}')

    echo -e "${VERT}*${NORMAL} Usb device bus number ${ROUGE}$USB_BOARD${NORMAL} : ${VERT}${BUS}${NORMAL}"
    echo -e "${VERT}*${NORMAL} Usb device number ${ROUGE}$USB_BOARD${NORMAL} : ${VERT}${DEV}${NORMAL}"
    
    DEVLST="$DEVLST --device=/dev/bus/usb/$BUS/$DEV:/dev/bus/usb/$BUS/$DEV "
    echo -e "${VERT}*${NORMAL} Mapping device ${VERT}/dev/bus/usb/$BUS/$DEV${NORMAL}"

    #
    # Automatic mapping of serial type devices via USB (/dev/ttyUSB*).
    #
    
    local DEVTTY=$(ls /dev/ttyUSB*)

    for i in $DEVTTY ; do
        DEVLST="$DEVLST --device=$i:$i "
        echo -e "${VERT}*${NORMAL} Mapping device ${VERT}${i}${NORMAL}"
    done

    unset DEVTTY
    
    #
    # The folder list is generated to map between the host environment
    # and the environment of the container.
    #

    if [[ $opt_fold -ne 0 ]] ; then
        local TMP=$FOLDLST
        FOLDLST=""

        TMP=$(echo $TMP | awk 'BEGIN{FS=":"} {NF=NF; print $0}')

        for i in $TMP ; do
            FOLDLST=$(echo "$FOLDLST -v ${i}:${i}")
            echo -e "${VERT}*${NORMAL} Mapping file ${VERT}${i}${NORMAL}"
        done

        unset TMP
        unset opt_fold
    fi

    FOLDLST=$(echo "$FOLDLST -v $X11FOLD:$X11FOLD")
    echo -e "${VERT}*${NORMAL} Mapping file ${VERT}${X11FOLD}${NORMAL}"

    #
    # It executes the command in the Docker container.
    #

    echo -e "${VERT}*${NORMAL} Starting a new instance of the Docker image..."
    echo -e ""

    eval "docker run --name xilinx_vivado --rm -i -t $DEVLST -e DISPLAY=$DISPLAY $FOLDLST $DOCKIMG $CMD"

    echo -e "${VERT}*${NORMAL} Closing and deleting the instance of the Docker image."

    #
    # Local variables are eliminated
    #
    
    unset USB_BOARD
    unset BUS
    unset DEV
    unset DEVLST
    unset FOLDLST
    unset DOCKIMG
    unset CMD
    unset X11FOLD

    #
    # Also global variables related to management options
    # are removed.
    #
    
    unset OPTIND
    unset OPTARG
    unset OPTERR
}
