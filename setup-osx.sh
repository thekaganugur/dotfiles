# Close any open System Preferences panes, to prevent them from overriding settings
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Delete all .DS_Store files so View Style can be changed properly
# cd ~ && find . -type f -name '*.DS_Store' -ls -delete

###

# Hammerspoon allow user setable init file location
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

# System Preferences, Keyboard, Keyboard
# Enable key repeat
# Key Repeat: 1.4 * 15ms = ms
# Delay Until Repeat: 15 * 15ms = ms
# defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -float 1.4

# System Preferences, Keyboard, Text
# [ ] Correct spelling automatically
# [ ] Capitalise words automatically
# [ ] Add period with double-space
# [ ] Use smart quotes and dashes
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# # # # #

# Dock, Automatically hide and show
defaults write com.apple.dock autohide -bool true
# Dock, Remove the auto-hiding delay
defaults write com.apple.dock autohide-delay -float 0
# Dock, Don’t show recent applications
defaults write com.apple.dock show-recents -bool false

# # # # #

killall Finder Dock
echo "You need to logout for some changes to take effect"
