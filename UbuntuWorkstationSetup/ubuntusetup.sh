#Ubuntu Workstation Setup
#Script to be used to install software used on my ubuntu workstations

#Update Machine
sudo apt update && sudo apt upgrade -y

#Install Software
##Software in Default Repos
sudo apt install gimp gnome-tweaks virt-manager filezilla vim gdebi keepassx xournal evolution evolution-ews audacity gnumeric vlc chromium-browser git calibre zenmap vim virtualbox vagrant ansible zsh powerline fonts-powerline zsh-theme-powerlevel9k zsh-syntax-highlighting -y
##Install Nextcloud Client
sudo add-apt-repository ppa:nextcloud-devs/client -y
sudo apt update && sudo apt install nextcloud-client -y
##Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
##Install Snap Packages
sudo snap install qownnotes
sudo snap install --classic vscode
sudo snap install --classic powershell

#Customizations for ZSH
##Set ZSH to Default Shell for Current User
sudo usermod -s /usr/bin/zsh $(whoami)
##Download oh-my-zsh Add-on for ZSH
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
##Copy the .zshrc template from oh-my-zsh to user's home
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
##Enable PowerLevel9K theme
echo "source /usr/share/powerlevel9k/powerlevel9k.zsh-theme" >> ~/.zshrc
##Add Syntax Highlighting
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc

#Install Pulse Secure VPN (deb file in git repo) 
sudo dpkg -i pulse-9.0R1.x86_64.deb
sudo apt install libwebkitgtk-1.0-0 -y


##Still in progress - CURRENTLY NONE

