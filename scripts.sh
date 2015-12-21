#!/bin/bash

#
# Author: Joachim Schmidt <joachim.schmidt@openmailbox.org>
#         Robert Berger <robert.berger@reliableembeddedsystems.com>
#
# Date: 21 dec 2015
#       27 septembre 2015
#
# Version: 0.1-en
#

#
# Functions to be sourced in file ~/.bashrc
#

#
# Function to run the development environment of Xilinx/Vivado.
#

function dock_vivado()
{
    run_dockapp -d FT2232C -i ${USER}/xilinx-vivado -f ${HOME}/docker_share:${HOME}/Documents/ITI4/VHDL_FPGA -c /opt/Xilinx/Vivado/2015.2/bin/vivado
}

#
# Function to run a bash shell found in the Docker image for the Xilinx/Vivado
# development environment.
#

function dock_bash()
{
    run_dockapp -d FT2232C -i ${USER}/xilinx-vivado -f ${HOME}/docker_share:${HOME}/Documents/ITI4/VHDL_FPGA -c /bin/bash
}

#
# Function to exeute the application GtkWave found in the Docker image for the 
# Xilinx/Vivado development environment.
#

function dock_gtkwave()
{
    run_dockapp -d FT2232C -i ${USER}/xilinx-vivado -f ${HOME}/docker_share:${HOME}/Documents/ITI4/VHDL_FPGA -c /usr/bin/gtkwave
}
