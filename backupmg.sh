#!/bin/bash


backup_path="./"
root_dir="/"
to_save="/"

#Terminal colors for output text
RED="\033[0;31m";
GREEN="\033[0;32m";
YELLOW="\033[0;33m";
BLUE="\033[0;34m";
RESET="\033[0m";

if [[ $UID -ne 0 ]]; then
	echo -e "${RED}[!] This program must be run in root mode or sudo privileges${RESET}"
	exit 1
fi

if [[ $# -eq 1 ]]; then
	if /usr/bin/ls $1 >/dev/null 2>&1;
	then
		to_save=$1;
	else
		echo -e "${YELLOW}[!] Path $1 doesn't exist, using '/' as default path to save${RESET}";
	fi
fi

echo -e "${BLUE}Welcome to the Backup Manager tool, please select an option below${RESET}";
echo -e "${BLUE}1]${RESET} Save the filesystem";
echo -e "${BLUE}2]${RESET} Load the filesystem";
echo -e "${BLUE}3]${RESET} Exit";
read response

if [[ $response != 1 && $response != 2 && $response != 3 ]]; then
	echo -e "${RED}[!] Invalid argument${RESET}";
	exit 1;
fi

if [[ $response -eq 1 ]]; then
	echo -e "${YELLOW}[i] Starting the backup...${RESET}";

	TOTAL_SIZE=$(/usr/bin/du -sb $to_save --exclude="$backup_path/bkp-01012025.tar.gz" --exclude=/proc --exclude=/sys\
	--exclude=/mnt --exclude=/tmp --exclude=/dev 2>/dev/null | awk '{print $1}')

	# Proceed to saving filesystem
	if /usr/bin/tar --exclude=/sys --exclude=/proc --exclude=/mnt --exclude=/dev --exclude=/tmp -cpf - $to_save \
		--warning=no-file-ignored 2>/dev/null | pv -s "$TOTAL_SIZE" > "$backup_path/bkp-$(date '+%d%m%Y-%Hh%M').tar.gz"; then
		echo -e "${BLUE}[+] Successfully saved the filesystem at $backup_path${RESET}"
		exit 0
	else
		echo -e "${RED}[!] An error occured and the filesystem could not be saved! (${YELLOW}$?${RESET})";
		exit 1
	fi
elif [[ $response -eq 2 ]]; then
	echo -e "${BLUE}[i] Please input the path of the backup image to load:${RESET}";
	read image_path

	TOTAL_SIZE=$(/usr/bin/du -sb $image_path 2>/dev/null | awk '{print $1}')
	if [[ -e $image_path && -r $image_path ]]; then
		if pv "$image_path" | /usr/bin/tar -xvpf - -C ./ >/dev/null 2>&1; then
			echo -e "${BLUE}[+] Successfully loaded backup from $image_path${RESET}";
			exit 0
		else
			echo -e "${RED}[!] An error occured and the backup image could not be loaded! (${YELLOW}$?${RESET})";
			exit 1
		fi
	else
		echo -e "${RED}[!] Specified image path doesn't exist${RESET}";
		exit 1
	fi
else
	echo -e "${BLUE}[i] Thanks for using the backupmg tool, bye!${RESET}";
	exit 0
fi
