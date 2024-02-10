#!/bin/bash
# Color codes for output formatting
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLU}Auto Tools for MacOS${NC}"
echo ""

# Setting up the menu options
PS3='Please enter your choice: '
options=("Bypass on Recovery" "Disable Notification (SIP)" "Disable Notification (Recovery)" "Check MDM Enrollment" "Quit")
select opt in "${options[@]}"; do
    case $opt in
        "Bypass on Recovery")
            echo -e "${GRN}Bypass on Recovery${NC}"
            if [ -d "/Volumes/Macintosh HD - Data" ]; then
                diskutil rename "Macintosh HD - Data" "Data"
            fi
            echo -e "${GRN}Create new user${NC}"
            echo -e "${BLU}Press Enter to move to the next step, leaving blank will default the value${NC}"
            echo -e "Enter the full name (Default: MAC)"
            read realName
            realName="${realName:=MAC}"
            echo -e "${BLU}Enter username ${RED}WITHOUT SPACES OR ACCENTS ${GRN} (Default: MAC)${NC}"
            read username
            username="${username:=MAC}"
            echo -e "${BLU}Enter password (Default: 1234)${NC}"
            read passw
            passw="${passw:=1234}"
            dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
            echo -e "${GRN}Creating user${NC}"
            # Create user
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
            mkdir "/Volumes/Data/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
            dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
            dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership $username
            # Block certain Apple URLs to prevent device enrollment checks
            echo "0.0.0.0 deviceenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >>/Volumes/Macintosh\ HD/etc/hosts
            echo -e "${GRN}Successfully blocked host${NC}"
            # Finalize setup and cleanup
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            echo "----------------------"
            break
            ;;
        "Disable Notification (SIP)")
            echo -e "${RED}Please Insert Your Password To Proceed${NC}"
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            break
            ;;
        "Disable Notification (Recovery)")
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            break
            ;;
        "Check MDM Enrollment")
            echo -e "${GRN}Checking MDM Enrollment. An error indicates success.${NC}"
            echo -e "${RED}Please Insert Your Password To Proceed${NC}"
            sudo profiles show -type enrollment
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option $REPLY" ;;
    esac
done
