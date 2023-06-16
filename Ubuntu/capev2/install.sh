#!/bin/bash

dir=$(pwd)

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install curl wget neofetch -y && echo "neofetch" >> .bashrc && source .bashrc


cd $dir


echo -ne "
-------------------------------------------------------------------------
                            Install Packages
-------------------------------------------------------------------------
"

printf "Installing packages"
input="$dir/pkg_files/pop_os_pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo apt-get install ${line} -y
done < "$input"

cp -r $dir/configs/.config/* ~/.config/

echo -ne "
-------------------------------------------------------------------------
                            Install Capev2
-------------------------------------------------------------------------
"

git clone https://github.com/kevoreilly/CAPEv2.git
