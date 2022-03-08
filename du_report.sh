#!/bin/bash

# Disk Space Usage
##################

# set -eux

# --> Script functions
# Display help
function Help {
	local script_filename=$1
	printf "\nNAME\n\n${script_filename} - Top disk space usage\n\n"
        printf "SYNOPSIS\n\n${script_filename} [-a|-D file|-e file|-h|-n number]\n\n"
	printf "DESCRIPTION\n\nThis Bash shell script is intended as a utility that generates a report, Disk Space Usage Report File (DSURF), on how much disk space is allocated to the largest subdirectories of given directories in the Disk Space Usage Configuration File (DSUCF). The directory that contains the DSUCF, Disk Space Usage Directory (DSUD), must be created in the user's home directory (/home/'user'/disk_usage/). The non-existent directories and duplicate ones in the DSUCF are discarded; only the valid directories are included in the DSURF. By default, the number of the largest subdirectories that are reported for each given directory is ten. However, it can also be specified by executing the script along with the appropriate option (n). It should also be taken into account that running this script multiple times does not generate separate report file, but rather it overwrites the existing one.\n\n"
        printf "OPTIONS\n\n"
        echo -e "-a\n\tDisplay all the entries in the DSUCF other than empty lines and exit.\n"
        echo -e "-e directory\n\tAppend directory to the DSUCF and exit.\n"
        echo -e "-D file\n\tRemove directory from the DSUCF and exit.\n"
        echo -e "-h\n\tDisplay this help and exit.\n"
	echo -e "-n\n\tSet number of subdirectories to be reported for each directory in the DSUCF.\n"
}
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
# Script filename
script_filename=$(basename $0)
# Default number of subdirectories
num_subdirs=10
# Handle script options
while getopts :aD:e:hn: opt
do
	case ${opt} in
		a)
			# Show all the entries in the DSUCF other than empty lines and exit
			sed -n '/^$/d ; p' ${du_config_file} 2> /dev/null
			exit
			;;
		D)
			# Remove entry from DSUCF and exit
			sed -i "s:^${OPTARG}\$:target: ; /target/d" ${du_config_file} 2> /dev/null
			sed -n '/^$/d ; p' ${du_config_file} 2> /dev/null
			exit
			;;
		e)
			# Add entry to DSUCF and exit
			sed -i "\$a\\${OPTARG}" ${du_config_file} 2> /dev/null
			sed -n '/^$/d ; p' ${du_config_file} 2> /dev/null
			exit
			;;
		h)
			# Display help message and exist
			Help ${script_filename}
			exit
			;;
		n)
			# Specify number of subdirectories to allow for in the DSURF
			if [[ ${OPTARG} =~ ^[0-9]+$ ]]; then
				num_subdirs=${OPTARG}
			else
				continue
			fi
			;;
		*)
			printf "Bad Usage: ${script_filename} [-a|-D file|-e file|-h|-n number]\nTry: Execute script with valid options\n"
			exit
			;;
	esac
done
# Create DSUD, if it does not exist
mkdir -p ${du_dir}
# Exit script if DSUCF does not exist or is empty
if [[ ! -f ${du_config_file} ]] || [[ ! -s ${du_config_file} ]]; then
	exit
fi
# Redirect STOUT to DSURF
exec 1> ${du_rpt}
# Print header
printf "# ${month} ${day} ${year}:\t\tTop ${num_subdirs} Disk Space Usage\n\n"
# Suppress empty entries and duplicate ones in DSUCF. Print top 10 disk space usage for each valid directory
while read entry
do
	if [[ -d ${entry} ]]; then
		entry=$(realpath ${entry})
		printf "Directory: %s\n" ${entry}
		du -S "${entry}" |
		sort -nr |
		head -n ${num_subdirs} |
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
