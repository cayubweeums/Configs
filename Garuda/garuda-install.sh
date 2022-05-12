#!/bin/bash

dir=$(pwd)

echo -ne "
-------------------------------------------------------------------------
                            Setup Paru
-------------------------------------------------------------------------
"
cd ~/
git clone "https://aur.archlinux.org/paru.git"
mv paru/ .paru
cd ~/.paru
makepkg -si --noconfirm


echo -ne "
-------------------------------------------------------------------------
                            Install Packages
-------------------------------------------------------------------------
"

cd $dir

input="$dir/pkg-files/garuda-pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo pacman -S --noconfirm --needed ${line}
done < "$input"

# Install packages using Paru
paru_input="$dir/pkg-files/aur-pkgs.txt"
while read -r line
do
  echo "Installing $line"
  paru -S --noconfirm --needed ${line}
done < "$paru_input"

paru -S --noconfirm --needed gwe
paru -S --noconfirm --needed kwin-bismuth
paru -S --noconfirm --needed plasma5-wallpapers-dynamic

export PATH=$PATH:~/.local/bin

cp -r $dir/configs/.config/* ~/.config/
cp -r $dir/configs/Pictures/* ~/Pictures/
cp $dir/configs/.zshrc ~/Documents/
cp $dir/configs/.p10k.zsh ~/Documents/
cp $dir/configs/Cayub-Bismuth-KDE.tar.gz ~/Documents/
cp $dir/configs/Cayub-Bismuth-Keyboard-Shortcuts.kksrc ~/Documents/


pip install konsave
python ~/.local/lib/python3.10/site-packages/konsave -i ~/Documents/ArchCayub/configs/kde.knsv
sleep 1
python ~/.local/lib/python3.10/site-packages/konsave -a kde


echo -ne "
-------------------------------------------------------------------------
               Enabling (and Theming) Login Display Manager
-------------------------------------------------------------------------
"
sudo echo [Theme] >>  /etc/sddm.conf
sudo echo Current=Nordic >> /etc/sddm.conf


sudo echo '#//IPADDER/SHARENAME /Path/to/mount cifs credentials=/home/cayub/.smbcred,noperm 0 0' >> /etc/fstab


echo -ne "
-------------------------------------------------------------------------
                          ZSH config
-------------------------------------------------------------------------
"
# ZSH configs
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/cayub/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/cayub/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Git clone nerd Fonts for zsh colorLS
sudo git clone https://github.com/ryanoasis/nerd-fonts.git /home/cayub/.nerd-fonts
cd ~/.nerd-fonts
./install.sh

# Install all ruby packages and colorLS
gem install clocale
gem install filesize
gem install rdoc
gem install colorls

# Setup grub theme

echo -e "\n"
echo "Installing Grub Sleek Theme..."
sleep 2

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

sudo git clone --depth=1 https://github.com/sandesh236/sleek--themes /home/cayub/grubtheme
cd /home/cayub/grubtheme/Sleek\ theme-dark && sudo chmod +x install.sh && sudo ./install.sh


echo -e "\n"
echo "Grub Sleek Theme Installed..."
sleep 2


sudo touch ~/.smbcreds

echo -ne "
-------------------------------------------------------------------------
            Launch a zsh terminal and run the install script
            in the nerdfonts folder located at ~/.nerdfonts
-------------------------------------------------------------------------
"
