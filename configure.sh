#/bin/bash
# configure.sh USER_PASSWORD VNC_PASSWORD ZT_PRIVATE_KEY ZT_NETWORK_ID NOMACHINE_DMG_URL

# Disable spotlight indexing
sudo mdutil -i off -a

# Create new account
sudo dscl . -create /Users/user
sudo dscl . -create /Users/user UserShell /bin/bash
sudo dscl . -create /Users/user RealName "User"
sudo dscl . -create /Users/user UniqueID 1001
sudo dscl . -create /Users/user PrimaryGroupID 80
sudo dscl . -create /Users/user NFSHomeDirectory /Users/user
sudo dscl . -passwd /Users/user $1
sudo dscl . -passwd /Users/user $1
sudo createhomedir -c -u user > /dev/null

# Enable VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -allUsers -privs -all
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes 

# VNC password - http://hints.macworld.com/article.php?story=20071103011608872
echo $2 | perl -we 'BEGIN { @k = unpack "C*", pack "H*", "1734516E8BA8C5E2FF1C39567390ADCA"}; $_ = <>; chomp; s/^(.{8}).*/$1/; @p = unpack "C*", $_; foreach (@k) { printf "%02X", $_ ^ (shift @p || 0) }; print "\n"' | sudo tee /Library/Preferences/com.apple.VNCSettings.txt

# Start VNC/reset changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -console
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate

# Install ZeroTier
sudo mkdir -p "/Library/Application Support/ZeroTier/One"
sudo echo "$3" > "/Library/Application Support/ZeroTier/One/identity.secret"
mkdir ~/.tmp > /dev/null 2>&1
sudo curl -o ~/.tmp/zt.pkg -k https://download.zerotier.com/dist/ZeroTier%20One.pkg
sudo installer -pkg ~/.tmp/zt.pkg -target /
sudo rm -rf "/Applications/ZeroTier\ One.app"
sudo zerotier-cli join $4 > /dev/null 2>&1

# Install NoMachine
sudo curl -o ~/.tmp/nomachine.pkg -k "$5"
sudo hdiutil attach ~/.tmp/nomachine.pkg
sudo installer -package /Volumes/NoMachine/NoMachine.pkg  -target /
sudo hdiutil detach /Volumes/NoMachine/
