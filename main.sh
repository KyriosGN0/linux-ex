#! /bin/bash


function repo(){
	packs=$(yum list installed | grep @$1 | awk '{print $1 " " $2}')
	package=$(whiptail --title "packages in $1" --menu --noitem "please choose a package" 0 0 0 \
		${packs[@]} 3>&1 1>&2 2>&3)
	echo $package
}

function packet(){
	if [ "$1" = "icmp" ]; then
		ip=$(whiptail --title "icmp packet" --inputbox "please enter the dest ip" 8 39 3>&1 1>&2 2>&3)
		ping -c 4 $ip > icmp
		res=$(cat icmp)
		whiptail --title "icmp result" --msgbox "$res" 45 90
	elif [ "$1" = "dns" ]; then
		addr=$(whiptail --title "dns packet" --inputbox "please enter the url" 8 39 3>&1 1>&2 2>&3)
		nslookup $addr > dns
		res=$(cat dns)
		whiptail --title "dns result" --msgbox "$res" 45 90
	elif [ "$1" = "http" ]; then
		addr=$(whiptail --title "http packet" --inputbox "please enter the url without www" 8 39 3>&1 1>&2 2>&3)
		curl -I http://www.$addr > http
		res=$(cat http)
                whiptail --title "http result" --msgbox "$res" 45 90
	fi
}

function storage() {
	text=$(bash -c $1)
    	whiptail --title "$1" --msgbox "$text" 50 110 
}
function networking(){
	case $1 in
		1)
			ports=$(ss -tulw | grep LISTEN | awk '{print $5}' | awk -F : '{gsub(/[^0-9 ]/,"",$2); print $2}'| uniq)
			whiptail --title "open ports" --msgbox "$ports" 45 90
		;;
		2)
			bash -c 'python net.py'
		;;
		3)
			proto=$(whiptail --title 'choose your protocol' --fb --menu "pick the protocol for the packet" 15 60 4 \
				"icmp" 'send a ping packet' \
				"dns" 'get the ip' \
				"http" 'send an http request' 3>&1 1>&2 2>&3)
			#TODO implement tcp/udp 
			packet $proto
		;;	
		esac		
}

function advancedMenu() {
    CHOMEN=$(whiptail --title "Advanced Menu" --fb --menu "Choose an option" 15 60 4 \
        "1" "inspect the stroage of you machine" \
        "2" "inspect the networking of your machine" \
        "3" "inpect you dnf/yum/apt repos" 3>&1 1>&2 2>&3)
    case $CHOMEN in
        1)
            
            STO=$(whiptail --title "storage" --menu --fb "choose the level you want to view" 15 60 4 \
		    "pvs" "physical discs" \
		    "vgs" "volume groups" \
		    "lvs" "logical volume" 3>&1 1>&2 2>&3)
	    storage $STO	
        ;;
        2)
            
            NET=$(whiptail --title "networking" --menu --fb "choose what is it you want to do" 15 60 4 \
		    "1" "check open ports" \
		    "2" "watch tcp wireshark style" \
		    "3" "craft and send packet" 3>&1 1>&2 2>&3)
	    networking $NET
        ;;
        3)
	    
	    repolist=($(yum repolist | awk ' NR > 1 {print $1 " "  "i-really-do-not-like-bash"}'))
	    YUM=$(whiptail --title "repo control" --menu --noitem "please choose repo"  50 60 15 \
		    ${repolist[@]} 3>&1 1>&2 2>&3)
	    repo $YUM
        ;;
    esac
}
advancedMenu
