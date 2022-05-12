#!/bin/bash

dir=$(pwd)

echo -ne "
-------------------------------------------------------------------------
                            Set up Git
-------------------------------------------------------------------------
"

printf "Please insert git user name:\n"
read git_name
git config --global user.name "$git_name"
printf "\nPlease insert git email:\n"
read git_email
git config --global user.email "$git_email"
printf "Done!\n\n"

printf "Generating public private key pair"
ssh-keygen -t rsa -b 4096 -C "$git_email"
ssh-add ~/.ssh/id_rsa
printf "Done!\n\n"

printf "Add SSH key to Github?\n"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) printf "Please go to https://github.com/settings/keys and add the your public key:";
		cat .ssh/id_rsa.pub; printf "\n"; read -p "Press enter to continue"; ssh -T git@github.com; break;;
		No ) break;;
	esac
done
printf "Done!\n\n"

echo -ne "
-------------------------------------------------------------------------
                            Install Packages
-------------------------------------------------------------------------
"

sudo rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey

sudo sh -c 'echo -e "[Atom]\nname=Atom Editor\nbaseurl=https://packagecloud.io/AtomEditor/atom/el/7/\$basearch\nenabled=1\ngpgcheck=0\nrepo_gpgcheck=1\ngpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey" > /etc/yum.repos.d/atom.repo'

printf "Do you want to make Atom the default GUI editor?\n"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) xdg-mime default atom.desktop text/plain; break;;
		No ) break;;
	esac
done

cd $dir

# Set up dnf config
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
echo "minrate=10k" | sudo tee -a /etc/dnf/dnf.conf
echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf

printf "Enabling RPM Fusion\n"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
printf "Done!\n\n"

printf "Installing packages"
input="$dir/pkg-files/fedora-pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo dnf -y install ${line}
done < "$input"

# Misc Packages that require extra steps
# --------------------------------------

sudo dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf -y groupupdate sound-and-video

# --------------------------------------


# Laptop Specific Packages
# --------------------------------------

printf "Is this a laptop install?\n"
select yn in "Yes" "No"; do
	case $yn in
		Yes ) sudo dnf -y install powertop tuned-utils;
    sudo systemctl start tuned
    printf "tuned recommendation: "
    tuned-adm recommend
    echo "SUBSYSTEM==\"power_supply\", ATTR{online}==\"0\", RUN+=\"`whereis tuned-adm | cut -d' ' -f2` profile laptop\"" | sudo tee --append /etc/udev/rules.d/powersave.rules
    echo "SUBSYSTEM==\"power_supply\", ATTR{online}==\"1\", RUN+=\"`whereis tuned-adm | cut -d' ' -f2` profile desktop\"" | sudo tee --append /etc/udev/rules.d/powersave.rules
    echo "SUBSYSTEM==\"power_supply\", ATTR{status}==\"Discharging\", RUN+=\"`whereis tuned-adm | cut -d' ' -f2` profile laptop\"" | sudo tee --append /etc/udev/rules.d/powersave.rules
    echo "SUBSYSTEM==\"power_supply\", ATTR{status}!=\"Discharging\", RUN+=\"`whereis tuned-adm | cut -d' ' -f2` profile desktop\"" | sudo tee --append /etc/udev/rules.d/powersave.rules
    sudo udevadm control --reload-rules && sudo udevadm trigger
    sudo systemctl enable tuned
    break;;
		No ) break;;
	esac
done

# --------------------------------------

# Flatpak install
# --------------------------------------

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.

# --------------------------------------


# Anaconda Install
# --------------------------------------
curl --output anaconda.sh https://repo.anaconda.com/archive/Anaconda3-2022.05-Linux-x86_64.sh
sudo chmod +x anaconda.sh
./anaconda.sh
# --------------------------------------

# Gotop Install
# --------------------------------------

wget https://github.com/xxxserxxx/gotop/releases/download/v4.1.3/gotop_v4.1.3_linux_amd64.rpm
sudo rpm -i gotop_v4.1.3_linux_amd64.rpm
curl -O -L https://raw.githubusercontent.com/xxxserxxx/gotop/master/fonts/Lat15-VGA16-braille.psf
setfont Lat15-VGA16-braille.psf

# --------------------------------------

export PATH=$PATH:~/.local/bin

cp -r $dir/configs/.config/* ~/.config/
cp $dir/configs/.zshrc ~/Documents/
cp $dir/configs/.p10k.zsh ~/Documents/
cp $dir/configs/post-install-fedora.txt ~/Documents/
mkdir ~/.themes
mkdir ~/.icons
mkdir ~/athena-server

# GTK Themeing
# --------------------------------------

git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git
cd Tela-circle-icon-theme/
./install.sh -a -d ~/.icons

cd $dir

git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme/
./install.sh -d ~/.themes --tweaks rimless

# --------------------------------------


# Dynamic Wallpapers Install
# --------------------------------------
curl -s "https://raw.githubusercontent.com/saint-13/Linux_Dynamic_Wallpapers/main/Easy_Install.sh" | sudo bash
# --------------------------------------


# Firefox Progressive Web App Install
# --------------------------------------
# Import GPG key and enable the repository
sudo rpm --import https://packagecloud.io/filips/FirefoxPWA/gpgkey
echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | sudo tee /etc/yum.repos.d/firefoxpwa.repo

# Update DNF cache
sudo dnf -q makecache -y --disablerepo="*" --enablerepo="firefoxpwa"

# Install the package
sudo dnf install firefoxpwa
# --------------------------------------


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

echo -ne "
-------------------------------------------------------------------------
                          Linux surface install
-------------------------------------------------------------------------
"

# Surface Specific kernel
# --------------------------------------
sudo dnf config-manager \
    --add-repo=https://pkg.surfacelinux.com/fedora/linux-surface.repo

sudo dnf -y install --allowerasing kernel-surface iptsd libwacom-surface
sudo systemctl enable iptsd

echo "[Unit]" | sudo tee -a /etc/systemd/system/default-kernel.path
echo "Description=Fedora default kernel updater" | sudo tee -a /etc/systemd/system/default-kernel.path
echo "[Path]" | sudo tee -a /etc/systemd/system/default-kernel.path
echo "PathChanged=/boot" | sudo tee -a /etc/systemd/system/default-kernel.path
echo "[Install]" | sudo tee -a /etc/systemd/system/default-kernel.path
echo "WantedBy=default.target" | sudo tee -a /etc/systemd/system/default-kernel.path

echo "[Unit]" | sudo tee -a /etc/systemd/system/default-kernel.service
echo "Description=Fedora default kernel updater" | sudo tee -a /etc/systemd/system/default-kernel.service
echo "[Service]" | sudo tee -a /etc/systemd/system/default-kernel.service
echo "Type=oneshot" | sudo tee -a /etc/systemd/system/default-kernel.service
echo 'ExecStart=/bin/sh -c "grubby --set-default /boot/vmlinuz*surface*"' | sudo tee -a /etc/systemd/system/default-kernel.service

sudo systemctl enable default-kernel.path
sudo grubby --set-default /boot/vmlinuz*surface*
# --------------------------------------

read -p "Enter new Hostname for this machine: " hostname
sudo hostnamectl set-hostname $hostname


echo "#//IPADDER/SHARENAME /Path/to/mount cifs credentials=/home/cayub/.smbcreds,noperm 0 0" | sudo tee -a /etc/fstab
touch ~/.smbcreds

echo -ne "
-------------------------------------------------------------------------
            Read post-install-fedora.txt in ~/Documents
-------------------------------------------------------------------------
"
