# This script starts SLIP networking (not cslip) on the RasPi.
# It assumes that the Rapsberry Pi has the IP address 192.168.5.2 
# and that the F256(K/Jr.) has the ip address 192.168.5.1
#
# It also assumes that the Serial Line is operated at 115200 bps
# and that the serial port used on the RasPi is /dev/ttyUSB0.

slattach -s 115200 -p slip -L /dev/ttyUSB0 &
sleep 2
ifconfig sl0 arp pointopoint
ifconfig sl0 192.168.5.2
route add 192.168.5.1 dev sl0
echo SLIP started
