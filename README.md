# docker_xilinx_vivado
Docker Ubuntu + Oracle JDK for running a Xilinx Vivado development environment.

## Dockerfile

The file Dockerfile from this repository can generate an image containing dependencies for the Xilinx Vivado development environment.

```bash
docker build -t ${USER}/ubuntu-for-xilinx-vivado .
```
Of course, installing the Xilinx Vivado development environment, as well as obtaining a license (WebPak is free) is left to the user (and not automated in here).

## bash scripts

The dockapp.sh script simplifies launching an instance of the Docker image described above.
The second script script.sh contains different configurations to call the function run_dockerapp contained in the dockapp.sh script.

This is to avoid the user having to enter a command like this and knowing that they must change each time you disconnect and reconnect the development board.


```bash
docker run --name xilinx_vivado --rm -i -t \ 
--device=/dev/bus/usb/002/008:/dev/bus/usb/002/008 \
--device=/dev/ttyUSB0:/dev/ttyUSB0 \
--device=/dev/ttyUSB1:/dev/ttyUSB1 \
-e DISPLAY=:0 \
-v ${HOME}/docker_share:${HOME}/docker_share \
-v ${HOME}/Documents/ITI4/VHDL_FPGA:${HOME}/Documents/ITI4/VHDL_FPGA \
-v /tmp/.X11-unix:/tmp/.X11-unix \
${USER}/xilinx-vivado /opt/Xilinx/Vivado/2015.2/bin/vivado
```

It should initially be enough to source the two script files in ~ / .bashrc.

Then the following functions can be called:

Launch of the container with bash:

```bash
dock_bash
```

Launch of the container with the command vivado:

```bash
dock_vivado
```

Launch of the container with specific settings:

```bash
run_dockapp -d <device name> \
-p <device_1>:<device_2>:<...> \
-i <name of the Docker image> \
-c <command name to be executed by Docker> \
-f <folder_1>:<folder_2>:<...>
```

Help is also available:

```bash
run_dockapp -h
```

```bash
Command: run_dockapp <parameter list> <...>

Parameter list:

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
```

Of course, the script can be modified according to the needs of the user.
