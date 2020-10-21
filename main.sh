#! /bin/bash

function check(){
	if [ $1 = 0 ]; then
		whiptail --title "success" --msgbox "the action was successful" 15 50
                advancedMenu
        else
                whiptail --title "failure" --msgbox "something went wrong!" 15 50
                advancedMenu
        fi
}


function repo(){
	packs=$(yum list installed | grep @$1 | awk '{print $1 " " $2}')
	package=$(whiptail --title "packages in $1" --menu --noitem "please choose a package" 0 0 0 \
		${packs[@]} 3>&1 1>&2 2>&3)
	rpmpack=$(rpm -ql $package | egrep '/usr/bin|/usr/sbin|/opt' | awk -F /  '{print $4}')
	ps aux > ps.txt
	if [ -z "$rpmpack" ]; then
		whiptail --title "ERROR" --msgbox "there was an error, this program is kinda shit" 45 90
		advancedMenu
	else
		proc=$(head -n 1 ps.txt | awk '{print $1 " " $2 " " $8 " " $9 " " $11}'; cat ps.txt| grep "$rpmpack" |awk '{print $1 " " $2 " " $8 " " $9 " " $11}')
		if [ -z "$proc" ]; then
			whiptail --title "process" --msgbox "there are no processes active from this package, or i couldn't find them." 45 90
		else
			whiptail --title "process" --scrolltext --msgbox  "$proc" 45 90
		fi
		daemon=$(ps aux | awk '{print $11}' | tr / '\n' | grep d$ | sort | uniq | grep "$rpmpack")
		if [ -z "$daemon" ]; then
			whiptail --title "daemons" --msgbox "there are no daemons active from this package, or i couldn't find them." 45 90
		else
			whiptail --title "daemons" --msgbox "$daemon" 45 90
		fi
		place=$(rpm -ql $package)
		whiptail --title "package place" --scrolltext --msgbox "$place" 45 90
		advancedMenu
	fi
}

function packet(){
	if [ "$1" = "icmp" ]; then
		ip=$(whiptail --title "icmp packet" --inputbox "please enter the dest ip" 8 39 3>&1 1>&2 2>&3)
		ping -c 4 $ip > icmp
		res=$(cat icmp)
		whiptail --title "icmp result" --msgbox "$res" 45 90
		advancedMenu
	elif [ "$1" = "dns" ]; then
		addr=$(whiptail --title "dns packet" --inputbox "please enter the url" 8 39 3>&1 1>&2 2>&3)
		nslookup $addr > dns
		res=$(cat dns)
		whiptail --title "dns result" --msgbox "$res" 45 90
		advancedMenu
	elif [ "$1" = "http" ]; then
		addr=$(whiptail --title "http packet" --inputbox "please enter the url without www" 8 39 3>&1 1>&2 2>&3)
		curl -I http://www.$addr > http
		res=$(cat http)
                whiptail --title "http result" --msgbox "$res" 45 90
		advancedMenu
	fi
}

function storage() {
	SIM=$(whiptail --title "choice" --menu "what would you like to do" 15 60 4 \
		"1" "manage $1" \
		"2" "view current $1" 3>&1 1>&2 2>&3)
	if [ "$SIM" = 2 ]; then
		text=$(bash -c $1)
		whiptail --title "$1" --msgbox "$text" 50 110
		advancedMenu
	else
		if [ "$1" = "pvs" ]; then
			choice=$(whiptail --title "manage $1" --menu --fb "please choose what to do" 45 90 4 \
				"1" "remove pv" \ 
				"2" "add a pv" 3>&1 1>&2 2>&3)
			if [ "$choice" == 1 ]; then
				pvs=$(bash -c $1 | awk ' NR >1 {print $1 " " "g"}')
				pv=$(whiptail --title "$1" --menu --noitem "choose the pv to remove" 45 90 4 \
					${pvs[@]} 3>&1 1>&2 2>&3)
				pvremove -f "$pv"
				check $?
			else
				blocks=$(lsblk -l -o NAME,FSTYPE -dsn | awk '$2 == "" {print $1 " " "g" }' | sort | uniq)
				dev=$(whiptail --title "block devices" --menu --noitem "there are all devices that don't have file systems USE CAUTION THIS IS DANGEROUS" 0 0 0 \
					${blocks[@]} 3>&1 1>&2 2>&3)
					pvcreate -f /dev/"$dev"
					check $?
			fi
		elif [ "$1" = "vgs" ]; then
			choice=$(whiptail --title "manage $1" --menu --fb "please choose what to do" 45 90 4 \
                                "1" "remove vg" \
				"2" "rename a vg"
				"3" "remove a pv from a vg" \
                                "4" "add a pv to vg "\
			        "5" "create a vg" 3>&1 1>&2 2>&3)
			if [ "$choice" = 1 ]; then
				vgs=$(bash -c $1 | awk ' NR >1 {print $1 " " "g"}')
                                vg=$(whiptail --title "$1" --menu --noitem "choose the vg to remove" 45 90 4 \
                                        ${vgs[@]} 3>&1 1>&2 2>&3)
				vgremove -f "$vg" 
				check $?
			elif [ "$choice" = 2 ];then
				vgs=$(bash -c $1 | awk ' NR >1 {print $1 " " "g"}')
                                vg=$(whiptail --title "$1" --menu --noitem "choose the vg to rename" 45 90 4 \
                                        ${vgs[@]} 3>&1 1>&2 2>&3)
				name=$(whiptail --title "new name" --inputbox "enter new name please" 45 90 3>&1 1>&2 2>&3)
                                vgrename $vg $name
                                check $?
			elif [ "$choice" = 3 ]; then
				vgs=$(bash -c $1 | awk ' NR >1 {print $1 " " "g"}')
                                vg=$(whiptail --title "$1" --menu --noitem "choose the vg to reduce" 45 90 4 \
                                        ${vgs[@]} 3>&1 1>&2 2>&3)
				pvs=$(bash -c pvs | awk ' NR >1 {print $1 " " "g"}')
                                pv=$(whiptail --title "pvs" --menu --noitem "choose the pv to remove" 45 90 4 \
                                        ${pvs[@]} 3>&1 1>&2 2>&3)
				vgreduce $vg $pv
				check $?
			elif [ "$choice" = 4 ];then 
				vgs=$(bash -c $1 | awk ' NR >1 {print $1 " " "g"}')
                                vg=$(whiptail --title "$1" --menu --noitem "choose the vg to extened" 45 90 4 \
                                        ${vgs[@]} 3>&1 1>&2 2>&3)
				pvs=$(bash -c pvs | awk ' NR >1 {print $1 " " "g"}')
                                pv=$(whiptail --title "pvs" --menu --noitem "choose the pv to add" 45 90 4 \
                                        ${pvs[@]} 3>&1 1>&2 2>&3)
				vgextend $vg $pv
				check $?
			else
				Name=$(whiptail --title "vg name" --inputbox "enter the name for the volume group" 8 39 3>&1 1>&2 2>&3)
				pv=$(whiptail --title "pv path" --inputbox "enter the full path of the pvs" 8 39 3>&1 1>&2 2>&3)
				vgcreate -f "$Name" "$pv"
				check $?
			fi
		elif [ "$1" = "lvs" ]; then
			Name=$(whiptail --title "lv name" --inputbox "enter the name for the logical volume" 8 39 3>&1 1>&2 2>&3)
			vg=$(whiptail --title "vg name" --inputbox "enter the vg name in which to create the lv" 8 39 3>&1 1>&2 2>&3)
			size=$(whiptail --title "lv size" --inputbox "enter the size of the lv with the format like so 2m or 2G" 8 39 3>&1 1>&2 2>&3)
			lvcreate -L "$size" -n "$Name" "$vg"
			check $1
		fi
	fi
}
function networking(){
	case $1 in
		1)
			ports=$(ss -tulw | grep LISTEN | awk '{print $5}' | awk -F : '{gsub(/[^0-9 ]/,"",$2); print $2 }'| uniq | awk 'NF > 0 {print $1 " " "i-bash"}')
			socket=$(whiptail --title "open ports" --menu --noitem "chose open port to write" 45 90 0 \
				${ports[@]} 3>&1 1>&2 2>&3)
				if echo "sending some data $(uname -n)" 2>/dev/null > /dev/tcp/127.0.0.1/"$socket"
				then
					whiptail --title "success" --msgbox "the data was sent! port is open!" 17 50
					advancedMenu
				else
					whiptail --title "success" --msgbox "the data was not send, something is wrong?" 45 90
					advancedMenu
				fi
			
		;;
		2)
			bash -c 'python net.py'
			advancedMenu
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
