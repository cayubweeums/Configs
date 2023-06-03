#!/bin/bash

dir=$(pwd)

echo -ne "
-------------------------------------------------------------------------
                            Config DNF
-------------------------------------------------------------------------
"
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf &&
echo "minrate=10k" | sudo tee -a /etc/dnf/dnf.conf &&
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf &&
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf

printf "Enabling RPM Fusion\n"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
printf "Done!\n\n"

# Enable Pycharm via copr
sudo dnf copr enable phracek/PyCharm -y

echo -ne "
-------------------------------------------------------------------------
                            Set up Git
-------------------------------------------------------------------------
"

sudo dnf -y install git gh curl wget

gh auth login
gh auth setup-git
# printf "Please insert git user name:\n"
# read git_name
# git config --global user.name "$git_name"
# printf "\nPlease insert git email:\n"
# read git_email
# git config --global user.email "$git_email"
# printf "Done!\n\n"

cd $dir


echo -ne "
-------------------------------------------------------------------------
                            Install Packages
-------------------------------------------------------------------------
"

sudo dnf -y upgrade --refresh

printf "Installing packages"
input="$dir/pkg-files/fedora-pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo dnf -y install ${line}
done < "$input"


# Flatpak and packages
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.tchx84.Flatseal com.vscodium.codium -y


# Gotop Install
wget https://github.com/xxxserxxx/gotop/releases/download/v4.2.0/gotop_v4.2.0_linux_amd64.rpm
sudo rpm -i gotop_v4.2.0_linux_amd64.rpm
curl -O -L https://raw.githubusercontent.com/xxxserxxx/gotop/master/fonts/Lat15-VGA16-braille.psf
setfont Lat15-VGA16-braille.psf


export PATH=$PATH:~/.local/bin

cp -r $dir/configs/.config/* ~/.config/
cp $dir/configs/.zshrc ~/Documents/
cp $dir/configs/.p10k.zsh ~/Documents/
cp $dir/configs/post-install-fedora.md ~/Documents/

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
sudo git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git /home/cayub/.nerd-fonts
cd ~/.nerd-fonts
./install.sh

# Install all ruby packages and colorLS
gem install clocale
gem install filesize
gem install rdoc
gem install colorls

# Enable xrdp
sudo systemctl enable xrdp.service

echo -ne "
..............Installing Conda now
"

cd /tmp
sleep 5
wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh
bash Anaconda3-2023.03-1-Linux-x86_64.sh

sleep 15

echo -ne "
-------------------------------------------------------------------------
            Read post-install-fedora.txt in ~/Documents
-------------------------------------------------------------------------
"

echo -ne "
-------------------------------------------------------------------------
            Rebooting to enable RDP
-------------------------------------------------------------------------
"

sudo reboot now