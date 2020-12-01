#!/bin/bash

###################################################################
# Script Name	: Files and folders name translator | trans-fifo.sh
# Description	: Translate all directory and/or files in the current directory using translate-shell
# Args          : 
# Parameters	: nothing=transtale folders and files, d=directory type, f=file type
# Author	   	: Régis "Sioxox" André
# Email	    	: pro@regisandre.be
# Website		: https://regisandre.be
# Github		: https://github.com/regisandre
###################################################################

RED='\033[1;31m'
GREEN="\033[1;32m"
NC='\033[0m' # No Color

# Check if there is Internet connection
if ping -q -c 1 -W 1 8.8.8.8 > /dev/null; then
	echo -ne "\n${GREEN}Internet connection : OK${NC}\n\n"
else
	echo -ne "${RED}First, connect the computer to the Internet${NC}\n\n"
	zenity --error --title="Internet problem" --text="First, connect the computer to the Internet" --no-wrap
	exit 1
fi

# Check if all the need packages are installed
if ! command -v trans &> /dev/null; then 
	echo -e "${RED}trans is not installed${NC}"

	# Automatically install required packages
	if zenity --question --title="Confirm automatic installation" --text="Are you sure you want to go ahead and install these programs: trans" --no-wrap 
    then
        sudo apt update && sudo apt install -y translate-shell
    else
    	zenity --error --title="Packages needed" --text="These packages must be installed for the script to work" --no-wrap
    	echo -ne "\n${RED}These packages must be installed for the script to work${NC}\n\n"
    	exit 1
	fi
fi

if [[ ! -z $1 ]]; then
	echo "yes"
	type="-type $1"
else
	type=""
	echo "no $type"
fi

# Translate all folders and files name in the current directory. translate-shell can use other translator, to show the list of all available translators, use this command : "trans -S"
find * -depth $type -execdir bash -c 'mv "{}" "$(trans -no-warn -no-autocorrect -e google -b fr:en "{}" | sed "s/ \/ /\//g")"' {} \;



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