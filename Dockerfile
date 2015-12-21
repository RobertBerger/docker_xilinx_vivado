#
# Image Ubuntu + Oracle JDK for the Vivado Xilinx development environment.
#
# Version 0.0.1
#

FROM n3ziniuka5/ubuntu-oracle-jdk
MAINTAINER Joachim Schmidt "joachim.schmidt@openmailbox.org"

#
# Adding stuff for i386 architecture needed by NavDoc.
#

RUN dpkg --add-architecture i386
RUN apt-get update

#
# Installation of packages needed by the Vivado environment.
#

RUN apt-get install -y -q libusb-1.0.0 libusb-1.0.0-dev libusb-1.0-doc libxtst6 libxtst-dev libxtst-doc libxrender1 libxrender-dev libxext6 libxext-dev libxext-doc fxload
RUN apt-get install -y -q libstdc++6:i386 libfontconfig1:i386 libxext6:i386 libxrender1:i386 libglib2.0-0:i386 libsm6:i386

#
# Adding a repository and install GHDL.
#

RUN add-apt-repository ppa:pgavin/ghdl
RUN apt-get update
RUN apt-get install -y -q ghdl vim gtkwave

#
# Updating the system.
#

RUN apt-get dist-upgrade -y -q

#
# Launch the bash shell.
#

CMD ["/bin/bash"]
