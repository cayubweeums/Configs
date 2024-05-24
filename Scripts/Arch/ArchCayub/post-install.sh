#!/bin/bash

# ZSH configs
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp -r ~/ArchTitus/configs/.zshrc ~/.zshrc
cp -r ~/ArchTitus/configs/.p10k.zsh ~/.p10k.zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/cayub/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/cayub/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Git clone nerd Fonts for zsh colorLS
git clone https://github.com/ryanoasis/nerd-fonts.git /home/cayub/.nerd-fonts
# cd ~/.nerd-fonts
# ./install.sh

# Install all ruby packages and colorLS
gem install clocale
gem install filesize
gem install rdoc
gem install colorls

# Setup grub theme
clear
echo -e "\n"
echo "Installing Grub Sleek Theme..."
sleep 2
clear
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

git clone --depth=1 https://github.com/sandesh236/sleek--themes /home/cayub/grubtheme
cd /home/cayub/grubtheme/Sleek\ theme-dark && chmod +x install.sh && sudo ./install.sh

clear
echo -e "\n"
echo "Grub Sleek Theme Installed..."
sleep 2
clear

touch ~/.smbcreds

echo -ne "
-------------------------------------------------------------------------
            Launch a zsh terminal and run the install script
            in the nerdfonts folder located at ~/.nerdfonts
-------------------------------------------------------------------------
"
