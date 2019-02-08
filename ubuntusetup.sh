#Ubuntu Workstation Setup
#Script to be used to install software used on my ubuntu workstations

#Update Machine
sudo apt update && sudo apt upgrade -y

#Install Software
##Software in Default Repos
sudo apt install virt-manager filezilla vim gdebi keepassx xournal evolution evolution-ews audacity gnumeric vlc chromium-browser git calibre zenmap vim virtualbox vagrant ansible zsh powerline fonts-powerline zsh-theme-powerlevel9k zsh-syntax-highlighting -y
##Install Nextcloud Client
sudo add-apt-repository ppa:nextcloud-devs/client
sudo apt update && sudo apt install nextcloud-client -y
##Install Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb
##Install Snap Packages
sudo snap install qownnotes
sudo snap install --classic vscode
sudo snap install --classic powershell

#Set ZSH to Default Shell for Current User
sudo usermod -s /usr/bin/zsh $(whoami)


##Still in progress
#Customizations for ZSH
#Install Pulse Secure VPN 

