### Disk Space Usage

#### Description

This Bash script is intended as a utility that helps monitor the disk space usage for specific directories in the user's file system.

#### Setup

The steps that should be taken to set up this script are as follows:

- Clone the GitHub repository (preferably into */home/"user"/projects/*).
	```
        [mkdir -p ~/projects/]
        git clone git@github.com:mohelhelb/du_report.git [~/projects/du_report/]
	```
- Create the Disk Space Usage Directory (DSUD) and Configuration File (DSUCF).
	```
	mkdir -p ~/disk_usage/
	touch ~/disk_usage/config_file.txt
	```
- Modify the *du_dir*, *du_rpt*, and *du_config_file* variables in the *du_report.sh* script accordingly if required.
- Write the full path of the directories to be monitored to the DSUCF.
- Execute the script.
	```
        [sudo chmod a+x ~/projects/du_report/du_report.sh]
        bash ~/projects/du_report/du_report.sh
	```
- View Disk Space Usage Report File.
	```
	vim ~/disk_usage/du.rpt
	```
