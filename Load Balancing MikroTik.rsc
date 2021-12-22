# dec/22/2021 11:28:41 by RouterOS 7.1
# software id = IR4H-VX51
#
# model = RB450Gx4
# serial number = B8D00AC9B27F
/interface ethernet
set [ find default-name=ether1 ] comment="111726367312 STREAMIX 50M" \
    mac-address=48:83:B4:57:01:7B name="Eth1_[ISP1]" rx-flow-control=on \
    tx-flow-control=on
set [ find default-name=ether2 ] comment="111726371139 1P 50M" mac-address=\
    38:A4:ED:64:2B:A5 name="Eth2_[ISP2]" rx-flow-control=on tx-flow-control=\
    on
set [ find default-name=ether3 ] comment="111726376334 INDIHOME BISNIS 2P" \
    disabled=yes mac-address=40:A1:08:B4:06:B6 name="Eth3_[ISP3]" \
    rx-flow-control=on tx-flow-control=on
set [ find default-name=ether4 ] name="Eth4_[LOCAL]" rx-flow-control=on \
    tx-flow-control=on
set [ find default-name=ether5 ] mac-address=0C:A8:A7:28:A6:5E name=Eth5 \
    poe-out=off rx-flow-control=on tx-flow-control=on
/interface list
add name=WAN
add name=NMS
add name=LAN
/interface lte apn
set [ find default=yes ] ip-type=ipv4
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/port
set 0 name=serial0
/routing bgp template
set default as=65530 disabled=no name=default output.network=bgp-networks
/routing ospf instance
add name=default-v2
add name=default-v3 version=3
/routing ospf area
add disabled=yes instance=default-v2 name=backbone-v2
add disabled=yes instance=default-v3 name=backbone-v3
/routing table
add fib name=to_WAN1
add fib name=to_WAN2
add fib name=to_WAN3
/ip neighbor discovery-settings
set discover-interface-list=NMS
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface detect-internet
set detect-interface-list=WAN internet-interface-list=WAN lan-interface-list=\
    LAN wan-interface-list=WAN
/interface list member
add interface="Eth1_[ISP1]" list=WAN
add interface="Eth2_[ISP2]" list=WAN
add interface="Eth3_[ISP3]" list=WAN
add interface="Eth4_[LOCAL]" list=LAN
add interface=Eth5 list=NMS
/ip address
add address=192.168.2.2/30 comment="ISP 2 50M" interface="Eth2_[ISP2]" \
    network=192.168.2.0
add address=192.168.1.2/30 comment="ISP 1 50M" interface="Eth1_[ISP1]" \
    network=192.168.1.0
add address=192.168.3.2/30 comment="ISP 3 50M" interface="Eth3_[ISP3]" \
    network=192.168.3.0
add address=172.30.1.1/30 comment=LOCAL interface="Eth4_[LOCAL]" network=\
    172.30.1.0
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,8.8.4.4,118.98.103.122
/ip firewall address-list
add address=172.30.1.0/30 comment=LOCAL list="ALL NETWORK"
add address=10.172.192.128/25 comment="NMS RADIOLINK" list="ALL NETWORK"
/ip firewall mangle
add action=accept chain=prerouting comment="##################################\
    ##########LOAD BALANCE PCC 3 WAN##########################################\
    ##" dst-address-list="ALL NETWORK" in-interface-list=LAN
add action=accept chain=output dst-address-list="ALL NETWORK" \
    out-interface-list=LAN
add action=mark-connection chain=input in-interface="Eth1_[ISP1]" \
    new-connection-mark=WAN1_conn passthrough=yes
add action=mark-connection chain=input in-interface="Eth2_[ISP2]" \
    new-connection-mark=WAN2_conn passthrough=yes
add action=mark-connection chain=input in-interface="Eth3_[ISP3]" \
    new-connection-mark=WAN3_conn passthrough=yes
add action=mark-routing chain=output connection-mark=WAN1_conn \
    new-routing-mark=to_WAN1 passthrough=yes
add action=mark-routing chain=output connection-mark=WAN2_conn \
    new-routing-mark=to_WAN2 passthrough=yes
add action=mark-routing chain=output connection-mark=WAN3_conn \
    new-routing-mark=to_WAN3 passthrough=yes
add action=accept chain=prerouting dst-address=192.168.1.0/24 \
    in-interface-list=LAN
add action=accept chain=prerouting dst-address=192.168.2.0/24 \
    in-interface-list=LAN
add action=accept chain=prerouting dst-address=192.168.3.0/24 \
    in-interface-list=LAN
add action=mark-connection chain=prerouting dst-address-type=!local \
    in-interface-list=LAN new-connection-mark=WAN1_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:3/0
add action=mark-connection chain=prerouting dst-address-type=!local \
    in-interface-list=LAN new-connection-mark=WAN2_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:3/1
add action=mark-connection chain=prerouting dst-address-type=!local \
    in-interface-list=LAN new-connection-mark=WAN3_conn passthrough=yes \
    per-connection-classifier=both-addresses-and-ports:3/2
add action=mark-routing chain=prerouting connection-mark=WAN1_conn \
    in-interface-list=LAN new-routing-mark=to_WAN1 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=WAN2_conn \
    in-interface-list=LAN new-routing-mark=to_WAN2 passthrough=yes
add action=mark-routing chain=prerouting connection-mark=WAN2_conn \
    in-interface-list=LAN new-routing-mark=to_WAN3 passthrough=yes
/ip firewall nat
add action=masquerade chain=srcnat comment="ISP A" out-interface=\
    "Eth1_[ISP1]" src-address=172.30.1.0/30
add action=masquerade chain=srcnat comment="ISP B" out-interface=\
    "Eth2_[ISP2]" src-address=172.30.1.0/30
add action=masquerade chain=srcnat comment="ISP B" out-interface=\
    "Eth3_[ISP3]" src-address=172.30.1.0/30
/ip route
add check-gateway=ping disabled=no dst-address=0.0.0.0/0 gateway=192.168.1.1 \
    routing-table=to_WAN1
add check-gateway=ping disabled=no dst-address=0.0.0.0/0 gateway=192.168.2.1 \
    routing-table=to_WAN2
add check-gateway=ping disabled=no dst-address=0.0.0.0/0 gateway=192.168.3.1 \
    routing-table=to_WAN3
add check-gateway=ping disabled=no dst-address=0.0.0.0/0 gateway=192.168.2.1
add check-gateway=ping disabled=no distance=2 dst-address=0.0.0.0/0 gateway=\
    192.168.1.1
add check-gateway=ping disabled=no distance=3 dst-address=0.0.0.0/0 gateway=\
    192.168.3.1
add disabled=no dst-address=10.80.123.0/30 gateway=172.30.1.2
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/ip smb
set allow-guests=no
/ip ssh
set forwarding-enabled=remote strong-crypto=yes
/snmp
set contact="DOPNETINDO PRATAMA" enabled=yes location=BENGKULU trap-version=2
/system clock
set time-zone-name=Asia/Jakarta
/system identity
set name=android1449944773409
/system note
set note="\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \n\
    \nDDDD   OOOO  PPPPP  NN     NN EEEEE TTTTTTTT\
    \nD  DD OO  OO PP  PP NN N   NN EE       TT\
    \nD  DD OO  OO PPPPP  NN  N  NN EEEEE    TT\
    \nD  DD OO  OO PP     NN   N NN EE       TT\
    \nDDDD   OOOO  PP     NN     NN EEEEE    TT\
    \n\
    \n############################################\
    \n# Hi Engineer.. Wellcome  !! #\
    \n# This Machine Manage by Dopnetindo Pratama  #\
    \n############################################\
    \n\
    \n[\?]             Gives the list of available commands\
    \ncommand [\?]     Gives help on the command and list of arguments\
    \n\
    \n[Tab]           Completes the command/word. If the input is ambiguous,\
    \n                a second [Tab] gives possible options\
    \n\
    \n/               Move up to base level\
    \n..              Move up one level\
    \n/command        Use command at the base level\
    \n\
    \n\
    \n"
/system ntp client
set enabled=yes
/system ntp server
set manycast=yes
/system ntp client servers
add address=202.162.32.12
/system routerboard settings
set cpu-frequency=auto
/tool bandwidth-server
set authenticate=no enabled=no
/tool mac-server
set allowed-interface-list=NMS
/tool mac-server mac-winbox
set allowed-interface-list=NMS
/tool mac-server ping
set enabled=no
/tool netwatch
add comment="ISP 1 [streamix]" down-script="/system scheduler enable Alarm0" \
    host=192.168.1.1 interval=1s up-script="/system scheduler disable Alarm0"
add comment="ISP 2 [phoenix]" down-script="/system scheduler enable Alarm1" \
    host=192.168.2.1 interval=1s up-script="/system scheduler disable Alarm1"
add comment="ISP 3 [phoenix]" down-script="/system scheduler enable Alarm1" \
    host=192.168.3.1 interval=1s up-script="/system scheduler disable Alarm1"
add comment="DNS GOOGLE" host=8.8.8.8 interval=1s timeout=30ms
