#!/bin/bash

dir=$(pwd)

echo -ne "
-------------------------------------------------------------------------
                            Config DNF
-------------------------------------------------------------------------
"
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
echo "minrate=10k" | sudo tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf

printf "Enabling RPM Fusion\n"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
printf "Done!\n\n"


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
sudo dnf -y remove libreoffice-core*

sudo dnf -y upgrade --refresh

# Xanmod Kernel edge install and config
sudo dnf copr enable rmnscnce/kernel-xanmod -y
sudo dnf install kernel-xanmod-edge -y
sudo dnf install kernel-xanmod-edge-headers kernel-xanmod-edge-devel -y

printf "Installing packages"
input="$dir/pkg-files/fedora-pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo dnf -y install ${line}
done < "$input"

sudo dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf -y groupupdate sound-and-video

# Sublime
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg

sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo

sudo dnf install sublime-text 

printf "Do you want to make VScodium the default GUI editor?\n"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) xdg-mime default subl text/plain; break;;
		No ) break;;
	esac
done

# Flatpak and packages
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.tchx84.Flatseal org.onlyoffice.desktopeditors org.polymc.PolyMC com.github.muriloventuroso.easyssh  -y

# ASDf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

# Gotop Install
wget https://github.com/xxxserxxx/gotop/releases/download/v4.1.3/gotop_v4.1.3_linux_amd64.rpm
sudo rpm -i gotop_v4.1.3_linux_amd64.rpm
curl -O -L https://raw.githubusercontent.com/xxxserxxx/gotop/master/fonts/Lat15-VGA16-braille.psf
setfont Lat15-VGA16-braille.psf

# Howdy Install/Config
sudo dnf copr enable principis/howdy
sudo dnf -y --refresh install howdy
printf "In the next window place your video camera in the device path under video. (i.e. /dev/video2)\n Type y to continue"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) break;;
		No ) break;;
	esac
done
sudo howdy config
sudo sed -i -e '2iauth       sufficient   pam_python.so /lib64/security/howdy/pam.py\' /etc/pam.d/sudo
sudo sed -i -e '2iauth        sufficient    pam_python.so /lib64/security/howdy/pam.py\' /etc/pam.d/gdm-password
sudo chmod o+x /lib64/security/howdy/dlib-data
touch howdy.te && echo -ne "module howdy 1.0;

require {
    type lib_t;
    type xdm_t;
    type v4l_device_t;
    type sysctl_vm_t;
    class chr_file map;
    class file { create getattr open read write };
    class dir add_name;
}

#============= xdm_t ==============
allow xdm_t lib_t:dir add_name;
allow xdm_t lib_t:file { create write };
allow xdm_t sysctl_vm_t:file { getattr open read };
allow xdm_t v4l_device_t:chr_file map;
" >> howdy.te
checkmodule -M -m -o howdy.mod howdy.te
semodule_package -o howdy.pp -m howdy.mod
sudo semodule -i howdy.pp


export PATH=$PATH:~/.local/bin

cp -r $dir/configs/.config/* ~/.config/
cp $dir/configs/.zshrc ~/Documents/
cp $dir/configs/.p10k.zsh ~/Documents/
cp $dir/configs/post-install-fedora.txt ~/Documents/
mkdir ~/.themes
mkdir ~/.icons
mkdir ~/athena-server


echo -ne "
-------------------------------------------------------------------------
                            Styling
-------------------------------------------------------------------------
"
# GTK Icon Themeing
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme/
./install.sh -a -d ~/.icons

cd $dir

# Dynamic Wallpapers Install
curl -s "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/main/Easy_Install.sh" | sudo bash

gsetttings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

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
touch ~/.smbcreds

echo -ne "
-------------------------------------------------------------------------
            Read post-install-fedora.txt in ~/Documents
-------------------------------------------------------------------------
"
