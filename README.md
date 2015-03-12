# backlog
A backup script written in Windows Powershell

This script requires 7-zip which can be found here: http://www.7-zip.org/download.html

I strongly recommend using a scheduling program such as Windows Task Scheduler to run this script at regular intervals.

To begin using backlog, open PowerShell and navigate to the directory in which it is installed.
Next type ".\backlog" into the command line and press ENTER. This will cause the script to initialize its configuration files.

####The Configuration Files

#####backlog.dat
This is where the paths of the directories or files you wish to back up are stored. These may be entered manually
(one per line), or from the command line using "backlog -add *path*".

#####backlog.ini
This is where the script stores its options, and by default it looks like this: 
>7zip=C:\Program Files\7-zip\7z.exe

>Destination=C:\Users\tdman_000\backlog\
  
>DeleteOldFiles=False
  
>MaxFileAge=30

**7zip** specifies the install location of the 7-zip executable

**Destination** determines the location in which backed up files will be stored.

**DeleteOldFiles** can be True or False. This option determines if archives that are in the destination and older than
  MaxFileAge will be deleted.
  
**MaxFileAge** determines the cutoff age of files for deletion in days.

####Usage
*.\backlog -help*
```
Name:  Backlog
Usage: backlog [OPTION]... [OPTION][PATH]...
Use 7-zip to create an archive of directories and files specified
 in backlog.dat at maximum compression ratio.

	-backup			Begin the backup sequence
	-target			Specify a target directory for backup
	       			 instead of using default.
	       			 Use in conjunction with -backup

	-add			Write new entry to backup list
	-remove			Delete an entry from the backup list

	-list			Display the backup list
	-log			Display the most recent log file
	-help			Display this help dialog
```

####License
Copyright 2015 Tyler Manifold

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
