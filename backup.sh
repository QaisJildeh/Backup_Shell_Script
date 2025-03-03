#!/bin/bash

callDir=$(pwd);
source=$1;
destination=$2;
log=~/Documents/___Backups___/.logbackupSH.bk;
backupPath=~/Documents/___Backups___/;
timestamp=$(date +"%c");

function sourceExists(){
    local s="$1";
    if [[ ! -e "$s" ]]; then
        echo "["$timestamp"] ERROR: INVALID Source. Path does not exist." >> "$log";
        echo "ERROR: Source path does not exist.";
        exit;
    fi
}

function destinationExists(){
    local d="$1";
    if [[ ! -e "$d" ]]; then
        echo "["$timestamp"] ERROR: Destination does not exist" >> "$log";
        echo "ERROR: Destination does not exist";
        exit;
    fi
}


if [[ ! -e ~/Documents/___Backups___/ ]]; then
    mkdir "$backupPath";
fi

echo "" >> "$log";
echo "=============== ["$timestamp"] New Backup ===============" >> "$log";

if [[ -z "$source" ]]; then
    echo "["$timestamp"] ERROR: Source path not provided by user." >> "$log";
    echo "ERROR: Source path not provided.";
    exit;
fi

if [[ -z "$destination" ]]; then
    echo "Destination path to save your backup is not provided."; 
    read -p "If you would like to save your backup in specified location please enter the path: " destination;
    if [[ -z "$destination" ]]; then
        destination=$backupPath;
        echo "Destination still not provied. Backup will be save in "$backupPath"";
    fi
fi

sourceExists $source;
destinationExists $destination;

echo "";

read -p "Provide a name for your backup: " backupName;

read -p "Would you like to compress your backup to save space? [Y/n]" isCompress;

bFile="";
if [[ -d "$source" ]]; then
    cd "$source"/../;
    bFile=$(basename "$source");
else
    fixedPath=$(dirname "$source");
    cd "$fixedPath";
    bFile=$(echo "$source" | awk -F "/" '{print $NF}');
fi


if [[ ! -s "$source" ]]; then
    echo "["$timestamp"] WARNING: User trying to back up an empty directory." >> "$log";
    echo "WARNING: The directory that you want to backup is empty!";
    read -p "Enter a new source path if you like to update it: " newSource;
    sourceExists $newSource;
fi


if [[ $isCompress == "Y" || $isCompress == "y" || $isCompress == "yes" || $isCompress == "Yes" || $isCompress == "YES" || -z $isCompress ]];  then
    fileSize=$(du -sb "$bFile" | awk -F " " '{print $1}');
    if [[ "$fileSize" -ge 1000000000 ]]; then
        echo "File is greater than or equal to 1 GB. Proceeding with high compression level."
        #tar -cJf "$backupName".tar.xz "$bFile" >> "$log";
        # tar -cf - "$bFile" | xz -8 --verbose > "$backupName.tar.xz"
        tar -cf - "$bFile" | xz -8 --verbose > "$backupName.tar.xz";
        cp "$backupName".tar.xz "$destination";
        sudo rm "$backupName".tar.xz;
        echo "["$timestamp"] [TAR.XZ] COMPLETED: Backup has finished successfully!" >> "$log";
    else
        zip -r "$backupName".zip "$bFile" >> "$log";
        cp "$backupName".zip "$destination";
        sudo rm "$backupName".zip;
        echo "["$timestamp"] [ZIP] COMPLETED: Backup has finished successfully!" >> "$log";
    fi
else
    tar -cf "$backupName".tar "$bFile" >> "$log";
    cp "$backupName".tar "$destination";
    sudo rm "$backupName".tar;
    echo "["$timestamp"] [TAR] COMPLETED: Backup has finished successfully!" >> "$log";
fi

cd "$callDir";

echo "Backup Completed!";
exit;