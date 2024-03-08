#!/bin/bash


echo """   _       __             ____             
 (_)_ _  / _|___ _ __ _ |__ / __ ___ _ _  
 | | ' \|  _/ _ \ '_ \ '_|_ \/ _/ _ \ ' \ 
 |_|_||_|_| \___/ .__/_||___/\__\___/_||_|
                |_|                 	@0xrushy     

 """



analyze_ipa() {
    ipa_file_path="$1"

    # Extract Info.plist from IPA
    unzip -q -c "$ipa_file_path" "Payload/*.app/Info.plist" > info.plist

    # Analyze Info.plist
    bold=$(tput bold)
    reset=$(tput sgr0)

    echo -e "${bold}App Transport Security (ATS) ${reset}"
    if grep -q "<key>NSAppTransportSecurity</key><dict>" info.plist; then
        echo -e "${bold}enabled${reset}"
    else
        echo -e "${bold}not enabled${reset}"
    fi

    echo -e "\n${bold}URLs:${reset}"
    grep -o 'https\?://[^"]*' info.plist
    
    echo -e "\n${bold}API keys and secrets:${reset}"
    grep -oE '[0-9a-fA-F]{32,}|&amp;[a-zA-Z0-9@^]+' info.plist | sort -u

    echo -e "\n${bold}App Permissions:${reset}"

permissions=("NSPhotoLibraryUsageDescription" "NSLocationWhenInUseUsageDescription" "NSLocationUsageDescription" "NSLocationAlwaysUsageDescription" "NSContactsUsageDescription" "NSCalendarsUsageDescription" "NSCameraUsageDescription")
for permission in "${permissions[@]}"; do
    description=$(grep -A1 "<key>$permission</key>" info.plist | grep -v "<key>$permission</key>" | grep -oP '(?<=<string>).*?(?=</string>)' | sed -e 's/^[[:space:]]*//' -e '/^$/d' | sed -e ':a;N;$!ba;s/\n/ /g')
    if [ -n "$description" ]; then
        echo -e "${bold}${purple}$permission:${reset} $description"
    fi
done

    # Clean up
    rm info.plist
}

# Check 
if [ $# -ne 2 ] || [ "$1" != "-f" ]; then
    echo "Usage: $0 -f <ipa_file>"
    exit 1
fi
ipa_file_path="$2"


analyze_ipa "$ipa_file_path"
