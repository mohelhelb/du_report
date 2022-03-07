#!/bin/bash

# Disk Space Usage
##################

# set -eux

# --> Script functions
# Output directories
function display_dirs {
	local directories="$@"
	local directory
	for directory in "${directories[@]}"
	do
		printf "%s\n" ${directory}
	done
}
# <-- Script functions
# Get user
user=$(whoami)
# Disk Space Usage Directory (DSUD)
du_dir="/home/${user}/disk_usage"
# Disk Space Usage Report File (DSURF)
du_rpt="${du_dir}/du.rpt"
# Disk Space Usage Configuration File (DSUCF)
du_config_file="${du_dir}/config_file.txt"
# Get date-related parameters
day=$(date +%d)
month=$(date +%B)
year=$(date +%Y)
# Create array of invalid directories
invalid_dirs=()
# Create DSUD, if it does not exist
mkdir -p ${du_dir}
# Exit script if DSUCF does not exist or is empty
if [[ ! -f ${du_config_file} ]] || [[ ! -s ${du_config_file} ]]; then
	exit
fi
# Redirect STOUT to DSURF
exec 1> ${du_rpt}
# Print header
printf "# ${month} ${day} ${year}:\t\tTop 10 Disk Space Usage\n\n"
# Suppress empty entries and duplicate ones in DSUCF. Print top 10 disk space usage for each valid directory
while read entry
do
	if [[ -d ${entry} ]]; then
		entry=$(realpath ${entry})
		printf "Directory: %s\n" ${entry}
		du -S "${entry}" |
		sort -nr |
		head -n 10 |
		cat -n |
		gawk 'BEGIN{printf "No\tSize\t\tSubdirectory\n"}{printf "%02d:\t%d\t\t%s\n", $1,$2,$3}END{printf "\n"}'
	else
		invalid_dirs+=("${entry}")
	fi
done < <(sed "/^$/d ; s:^~/:${HOME}/: ; s:/$::" ${du_config_file} | sort -u)
# Print invalid entries in DSUCF
if [[ ${#invalid_dirs[@]} -ne 0 ]]; then
	printf "Invalid Directories:\n"
	display_dirs "${invalid_dirs[@]}"
fi
# Exit script
exit
