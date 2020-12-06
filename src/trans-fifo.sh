#!/bin/bash

###################################################################
# Script Name	: Files and folders name translator | trans-fifo.sh
# Description	: Translate all directory and/or files in the current directory using translate-shell
# Args          : 
# Parameters	: 1 : choose the translator to use, google or bing; 2 : nothing=transtale folders and files, d=directory type, f=file type
# Author	   	: Régis "Sioxox" André
# Email	    	: pro@regisandre.be
# Website		: https://regisandre.be
# Github		: https://github.com/regisandre
###################################################################

RED='\033[1;31m'
GREEN="\033[1;32m"
NC='\033[0m' # No Color

# Check if all the need packages and scripts are installed
checkNecessaryPackagesInstalled() {
    # Packages needed : translate-shell, findutils, sed, grep, zenity, zenity-common
	packagesNeeded=(translate-shell findutils sed grep zenity zenity-common)
    
    # Checks one by one if the packages are installed and adds them to an installation list
    for pn in ${packagesNeeded[@]}; do
        if [[ $(dpkg -s $pn | grep Status) != *"installed"* ]]; then
            echo -e "${RED}$pn is not installed${NC}"
            packagesThatMustBeInstalled+="$pn "
        fi
    done

    # Automatically install required packages and scripts
    if [[ ! -z "$packagesThatMustBeInstalled" ]]; then
        # Multi-step question for packages installation with zenity (GUI) or simple questions in the terminal
        if [[ $(dpkg -s zenity | grep Status) == *"installed"* ]]; then # Check if zenity is installed
            if zenity --question --title="Confirm automatic installation" --text="Are you sure you want to go ahead and install these programs: $packagesThatMustBeInstalled?" --no-wrap 
            then
                sudo apt update && sudo apt install -y $packagesThatMustBeInstalled
            else
                if zenity --question --title="Packages needed" --text="These packages must be installed for the script to work.\n\nDo you want to retry installing the packages necessary for this script to run correctly?" --no-wrap
                then
                    checkNecessaryPackagesInstalled # Restart the required package checks
                else
                    if ! zenity --question --title="Continue without all packages installed?" --text="Do you want to continue without all the packages being installed? This could cause problems during script execution." --no-wrap
                    then
                        exit 1
                    fi
                fi
            fi  
        else
            echo -n "Are you sure you want to go ahead and install these programs: $packagesThatMustBeInstalled? (Y/n): "; read answer
            if [ "$answer" != "${answer#[Yy]}" ]; then
                sudo apt update && sudo apt install -y $packagesThatMustBeInstalled
            else
                echo -ne "\n${RED}These packages must be installed for the script to work${NC}\n\nDo you want to retry installing the packages necessary for this script to run correctly? (Y/n): "; read answer
                if [ "$answer" != "${answer#[Yy]}" ]; then
                    checkNecessaryPackagesInstalled # Restart the required package checks
                else
                    echo -n "Do you want to continue without all the packages being installed? This could cause problems during script execution (Y/n): "; read answer
                    if [ "$answer" == "${answer#[Yy]}" ]; then
                        exit 1
                    fi
                fi
            fi
        fi
    fi
}

# Check if there is Internet connection
checkInternetConnection() {
    if ping -q -c 1 -W 1 8.8.8.8 > /dev/null; then
        echo -ne "\n${GREEN}Internet connection : OK${NC}\n\n"
        checkNecessaryPackagesInstalled # Check if all the need packages and scripts are installed
    else
        # Multi-step question for the Internet connection with zenity (GUI) or simple questions in the terminal
        if [[ $(dpkg -s zenity | grep Status) == *"installed"* ]]; then # Check if zenity is installed
            if zenity --question --title="Internet problem" --text="First, connect the computer to the Internet to install any missing packages\n\nDo you want to try again after connecting to the Internet?" --no-wrap
            then
                checkInternetConnection # Restart the Internet connection test
            else
                if ! zenity --question --title="Continue without Internet?" --text="Do you want to continue without an Internet connection? This could cause problems during script execution." --no-wrap
                then
                    exit 1
                fi
            fi
        else
            echo -ne "${RED}First, connect the computer to the Internet${NC}\n\n"

            echo -n "Do you want to try again after connecting to the Internet? (Y/n): "; read answer
            if [ "$answer" != "${answer#[Yy]}" ]; then
                checkInternetConnection # Restart the Internet connection test
            else
                echo -n "Do you want to continue without an Internet connection? This could cause problems during script execution (Y/n): "; read answer
                if [ "$answer" == "${answer#[Yy]}" ]; then
                    exit 1
                fi
            fi
        fi
    fi
}

checkInternetConnection

if [[ ! -z $1 ]] && [[ "$1" == "bing" || "$1" == "google" ]]; then
	export translator="$1"
else
	export translator="bing"
fi

if [[ ! -z $2 ]]; then
	type="-type $2"
else
	type=""
fi

echo -e "${RED}Translator : $translator${NC}"

# Translate all folders and files name in the current directory. translate-shell can use other translator, to show the list of all available translators, use this command : "trans -S"
find * $type -depth -exec bash -c 'mv "{}" "$(trans -no-warn -no-autocorrect -e $translator -b fr:en "{}" | sed "s/ \/ /\//g")"' {} \;



# All my other attempts

# Takes directory entries specified and renames them using the pattern provided.
# https://devconnected.com/how-to-rename-a-directory-on-linux/
#for directory in *
#do
#    if [ -d "$directory" ]
#    then
#      mv "${directory}" $(trans -no-warn -no-autocorrect -e bing -b fr:en ${directory}) || echo 'Could not rename '"$directory"''
#    fi
#done

#mv "${directory}" $(trans -no-warn -no-autocorrect -e bing -b fr:en "${directory}" | sed "s/ \/ /\//g") || echo 'Could not rename '"$directory"''

#for d in $( find * -type d ); do mv $d $(trans -no-warn -no-autocorrect -e bing -b fr:en $d | sed "s/ \/ /\//g") ; done
#for d in $( find * -type d ); do echo $d ; done
#for d in $( find * -type d ); do trans -no-warn -no-autocorrect -e bing -b fr:en $d | sed "s/ \/ /\//g" ; done

#find * -type d -execdir mv "{}" "$(trans -no-warn -no-autocorrect -e bing -b fr:en {} | sed "s/ \/ /\//g")" \;
#find * -type d | xargs mv -t "$(trans -no-warn -no-autocorrect -e bing -b fr:en -t | sed "s/ \/ /\//g")" \;
#find * -type d -print0 | xargs -I {} -0 mv "{}" "$(trans -no-warn -no-autocorrect -e bing -b fr:en {} | sed "s/ \/ /\//g")" \;


#old_names=($(find * -type d))
#old_names=('"$(find * -type d | while read dir; do echo "$dir"; done)"')
#old_names=($(find * -type d -print0 | while read -d '' -r dir; do echo "$dir"; done))
#for item in ${old_names[@]}; do
#	new_name=$(echo $(trans -no-warn -no-autocorrect -e bing -b fr:en "$item" | sed "s/ \/ /\//g" | xargs echo)
#	if [[ ! -z "$new_name" ]]; then
#		echo "The translated folder name is $new_name"
#		echo ${old_names[@]} | sed -e "s/\"$item\"/\"$new_name\"/"
#		echo "There is the new directories name : ${old_names[@]}"
#	fi
#done

#shopt -s globstar
#for dir in **/*/; do
#    new_name=$(trans -no-warn -no-autocorrect -e bing -b fr:en "${dir}" | sed "s/ \/ /\//g")
#    if [[ ! -z "$new_name" ]]; then
#    	mv "${dir}" "${new_name}" || echo 'Could not rename '"$directory"''
#    fi
#done