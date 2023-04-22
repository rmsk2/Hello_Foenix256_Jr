# This script starts SLIP networking (not cslip) on the RasPi.
# It assumes that the Rapsberry Pi has the IP address 192.168.5.2 
# and that the F256(K/Jr.) has the ip address 192.168.5.1
#
# It also assumes that the Serial Line is operated at 115200 bps
# and that the serial port used on the RasPi is /dev/ttyUSB0.

# Creates sl0 interface
slattach -s 115200 -p slip -L /dev/ttyUSB0 &
#  Wait a bit so the changes made by slattach become visible
sleep 2
# Turns on ARP for interface sl0. This is probably unneccesary.
ifconfig sl0 arp pointopoint
# Configure local IP address and bring up interface
ifconfig sl0 192.168.5.2
# Route traffic for the F256 over the interface sl0
route add 192.168.5.1 dev sl0
echo SLIP started
