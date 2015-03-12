
<# 
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
#>

<#
 This is a simple script to create 7-Zip Archives to function
  as backups for files.
   
 It is recommended to use Windows Task Scheduler to automatically run this script 
  at regular intervals.
#>

param(
	# Add a directory to backlog.dat
	[string]$add,
	
	# Begin backup sequence
	[switch]$backup,
	
	# List the contents of backlog.dat
	[switch]$list,
	
	# Remove an entry from backlog.dat
	[int]$remove,
	 
	# Displays the most recent logfile
	[switch]$log,
	
	# Specify target location instead of using default
	[string]$target,
	
	# Display help dialog
	[switch]$help
)

# Gets a variable from the ini file at line_num
function GetINIValue {
    param ([int] $line_num)

    $equ_index = $ini_file[$line_num].IndexOf("=")
   
    $val = $ini_file[$line_num].Substring($equ_index + 1, $ini_file[$line_num].Length - $equ_index - 1)

    return $val
}

# Initialize backlog.ini
if (-NOT (Test-Path $PSScriptRoot\backlog.ini)) {

    echo "7zip=C:\Program Files\7-zip\7z.exe" > $PSScriptRoot\backlog.ini
    echo "Destination=C:$env:HomePath\backlog\" >> $PSScriptRoot\backlog.ini
    echo "DeleteOldFiles=False" >> $PSScriptRoot\backlog.ini
    echo "MaxFileAge=30" >> $PSScriptRoot\backlog.ini

    $ini_file = Get-Content $PSScriptRoot\backlog.ini
} else {
    $ini_file = Get-Content $PSScriptRoot\backlog.ini
}


$szip = GetINIValue 0
$destination = GetINIValue 1
$delete_old  = GetINIValue 2
$delete_age  = GetINIValue 3

Set-Alias SZip $szip

$date 		 = Get-Date -Format yyyy.MM.dd
$destination = $destination
$secondary   = "C:$env:HomePath\backlog\$date"
#>
if (-NOT (Test-Path "D:\")) {
    $destination = $secondary
}

# Create the directory list if it doesn't exist
if (Test-Path $PSScriptRoot\backlog.dat){
     $source = Get-Content $PSScriptRoot\backlog.dat
} else {
		 
	echo $null > backlog.dat
}

if ($backup) {

	# Make sure the target directory exists
	
	if (!(Test-Path $destination\$date)) { mkdir $destination\$date }
	
	# Create the log file
	
	$logfile = "$destination\$date\{$date}_back.log"
    $null > $logfile
	
	# Begin backup process with 7z
    
	foreach ($line in $source) {
		
		Write-Host -NoNewline "$line.........."

        SZip a -mx9 $destination\$date\$date.7z $line >> $logfile

		if ($LastExitCode -eq 0) {
			Write-Output " OK"
		}
		if ($LastExitCode -eq 1) {
			Write-Output " WARNING - See log file."
		}
		if ($LastExitCode -eq 2) {
			Write-Output " FATAL ERROR - See log file."
		}
		if ($LastExitCode -eq 7) {
			Write-Output " Command Line Error"
		}
		if ($LastExitCode -eq 8) {
			Write-Output " Not enough memory for operation."
		}
		if ($LastExitCode -eq 255) {
			Write-Output " Process stopped by user."
		}
        Write "EXIT CODE: $LastExitCode" >> $logfile

	}
	
	SZip l $destination\$date.7z >> $logfile

    if ($delete_old -and $delete_age -gt 0) {
        # Delete backups older than $delete_age
        $file_age = (Get-Date).AddDays(-$delete_age)
    
        if (Test-Path "D:\") {
            Write-Output "Checking '$destination' for files older than $delete_age days" >> $logfile
     
            $files = Get-ChildItem $destination | Where {$_.LastWriteTime -le "$file_age"}

            foreach ($file in $files) {
                if ($file.Exists) {
                     if ($file -ne $null) {
                        Write-Output "Deleting $file"
                        Remove-Item -Recurse $file.FullName | Out-Null
                    }
                }
                
            }
        }
    }


}

if ($target) {
	$destination = $target
}

if ($add) {
	Write-Output $add >> backlog.dat
}

if ($remove) {

	# Still not sure why the hell this works, but it does the trick. Thanks, StackOverflow.
	$source | foreach {$n=1}{if ($n++ -ne $remove) {$_}} > $PSScriptRoot\backlog.dat
}

if ($list) {

	# Make sure backlog.dat exists. This may or may not be redundant *shrug*
	if (Test-Path $PSScriptRoot\backlog.dat) {
		
		$t = 1
		# Step through entries in backlog.dat and display them in a numbered list.
		foreach ($i in $source) {
			Write-Output "$t. $i"
			$t++
		}
	} else {
		Write-Output "WARNING: backlog.dat not found in $PSScriptRoot\" >> $logfile 
	}
}

if ($log) {
	# Get the log file from the most recent backup directory
	$folder = Get-ChildItem "$destination" | select -last 1
	cat $destination\$folder\*.log
}

if ($help) {
	Write-Output ""
	Write-Output "Name:  Backlog"
	Write-Output "Usage: backlog [OPTION]... [OPTION][PATH]..."
	Write-Output "Use 7-zip to create an archive of directories and files specified"
	Write-Output " in backlog.dat at maximum compression ratio."
	Write-Output ""
	Write-Output "	-backup			Begin the backup sequence"
	Write-Output "	-target			Specify a target directory for backup"
	Write-Output "	       			 instead of using default."
	Write-Output "	       			 Use in conjunction with -backup"
	Write-Output ""
	Write-Output "	-add			Write new entry to backup list"
	Write-Output "	-remove			Delete an entry from the backup list"
	Write-Output ""
	Write-Output "	-list			Display the backup list"
	Write-Output "	-log			Display the most recent log file"
	Write-Output "	-help			Display this help dialog"
	Write-Output ""
}

