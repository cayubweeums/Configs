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

sudo dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf -y groupupdate sound-and-video

# Flatpak and packages
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.tchx84.Flatseal com.github.muriloventuroso.easyssh com.bitwarden.desktop org.remmina.Remmina -y

# Gotop Install
wget https://github.com/xxxserxxx/gotop/releases/download/v4.1.3/gotop_v4.1.3_linux_amd64.rpm
sudo rpm -i gotop_v4.1.3_linux_amd64.rpm
curl -O -L https://raw.githubusercontent.com/xxxserxxx/gotop/master/fonts/Lat15-VGA16-braille.psf
setfont Lat15-VGA16-braille.psf

export PATH=$PATH:~/.local/bin

cp -r $dir/configs/.config/* ~/.config/
cp $dir/configs/.zshrc ~/Documents/
cp $dir/configs/.p10k.zsh ~/Documents/
cp $dir/configs/post-install-fedora.txt ~/Documents/


echo -ne "
-------------------------------------------------------------------------
                            Styling
-------------------------------------------------------------------------
"

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

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

echo -ne "
-------------------------------------------------------------------------
            Read post-install-fedora.txt in ~/Documents
-------------------------------------------------------------------------
"h
