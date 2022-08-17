#!/bin/bash

dir=$(pwd)

echo -ne "
-------------------------------------------------------------------------
                            Set up Git
-------------------------------------------------------------------------
"
sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install git gh curl wget -y

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

printf "Installing packages"
input="$dir/pkg_files/pop_os_pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo apt-get install ${line} -y
done < "$input"

# Astrovim
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
nvim +PackerSync

printf "Do you want to make nvim the default GUI editor?\n"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) xdg-mime default nvim text/plain; break;;
		No ) break;;
	esac
done

# Flatpaks
flatpak install flathub com.github.tchx84.Flatseal com.leinardi.gwe org.polymc.PolyMC com.github.muriloventuroso.easyssh com.valvesoftware.Steam -y

# ASDf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

# Gotop Install
wget https://github.com/xxxserxxx/gotop/releases/download/v4.1.4/gotop_v4.1.4_linux_amd64.deb
sudo apt-get install ./gotop_v4.1.4_linux_amd64.deb
curl -O -L https://raw.githubusercontent.com/xxxserxxx/gotop/master/fonts/Lat15-VGA16-braille.psf
setfont Lat15-VGA16-braille.psf

export PATH=$PATH:~/.local/bin

cp -r $dir/configs/.config/* ~/.config/
cp $dir/configs/.zshrc ~/Documents/
cp $dir/configs/.p10k.zsh ~/Documents/
cp $dir/configs/post_install_pop_os.txt ~/Documents/
mkdir ~/cayubs-server


echo -ne "
-------------------------------------------------------------------------
                            Styling
-------------------------------------------------------------------------
"

cd $dir

# Dynamic Wallpapers Install
curl -s "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/main/Easy_Install.sh" | sudo bash

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


sudo touch ~/.smbcreds

read -p "Enter new Hostname for this machine: " hostname
sudo hostnamectl set-hostname $hostname

echo "#//IPADDER/SHARENAME /Path/to/mount cifs credentials=/home/cayub/.smbcreds,noperm 0 0" | sudo tee -a /etc/fstab

echo -ne "
-------------------------------------------------------------------------
            Read post-install-fedora.txt in ~/Documents
-------------------------------------------------------------------------
"
