#! /bin/bash
# there is an alternate way to redirect the out put 
# https://unix.stackexchange.com/questions/42728/what-does-31-12-23-do-in-a-script
# go here to see that way and understand it, i don't get that way tho


function storage() {
	msg=$(bash -c $1)
    	echo $msg
    	#whiptail --title $1 --msgbox $msg 15 60 4
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
            
            whiptail --title "networking" --msgbox "You chose option 2. Exit status $?" 8 45
        ;;
        3)
            echo $ADVSEL
            #whiptail --title "Option 1" --msgbox "You chose option 3. Exit status $?" 8 45
        ;;
    esac
}
advancedMenu
