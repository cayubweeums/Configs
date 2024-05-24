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

echo -ne "
-------------------------------------------------------------------------
                            Set up Git
-------------------------------------------------------------------------
"

sudo dnf -y install git gh curl wget

gh auth login
gh auth setup-git
printf "Please insert git user name:\n"
read git_name
git config --global user.name "$git_name"
printf "\nPlease insert git email:\n"
read git_email
git config --global user.email "$git_email"
printf "Done!\n\n"

cd $dir


echo -ne "
-------------------------------------------------------------------------
                            Install Packages
-------------------------------------------------------------------------
"

sudo dnf -y upgrade --refresh

printf "Installing packages"

sudo dnf -y install @fonts util-linux-user go python3 python python-pip fastfetch btop zsh openssl ranger ruby ruby-devel neovim rust ripgrep bat lm_sensors docker docker-compose


# Flatpak and packages
flatpak install flathub com.bitwarden.desktop com.visualstudio.code net.waterfox.waterfox com.vivaldi.Vivaldi io.github.mahmoudbahaa.outlook_for_linux com.github.IsmaelMartinez.teams_for_linux com.slack.Slack org.signal.Signal com.discordapp.Discord com.mattjakeman.ExtensionManager -y

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
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-syntax-highlighting/Fedora_Rawhide/shells:zsh-users:zsh-syntax-highlighting.repo
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-autosuggestions/Fedora_Rawhide/shells:zsh-users:zsh-autosuggestions.repo

sudo dnf install zsh-autosuggestions zsh-syntax-highlighting

echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc

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
                          Python config
-------------------------------------------------------------------------
"
# Poetry Install and config
curl -sSL https://install.python-poetry.org | python3 -

poetry completions zsh > ~/.zfunc/_poetry


echo -ne "
-------------------------------------------------------------------------
            Read post-install-fedora.txt in ~/Documents
-------------------------------------------------------------------------
"
