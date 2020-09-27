#! /bin/bash


function storage() {
	msg=$(bash -c $1)
    	whiptail --title "$1" --msgbox "$msg" 50 110 
}
function networking(){

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
            echo $ADVSEL
            #whiptail --title "Option 1" --msgbox "You chose option 3. Exit status $?" 8 45
        ;;
    esac
}
advancedMenu
