#part1
printf '\033c'

echo "Inside part 1..."
sleep 5

# Takes 3 arguements
# 1st arguement is what the command does
# 2nd arguement is the exact command being executed
# 3rd arguement is the URL to the spot in the arch wiki

# Function Definitions
verbose_and_interactive() {
        printf "In simulation mode...\n"
        printf "$1 using the command ($2)\n"
        until prompt "$1" "$2" ; do : ; done
}

prompt() {
  read -p "Does the command ($2) match the Arch Installation guide? (Y/n): " response
        case "$response" in
                Y|y)
                        echo "OK. Exiting simulation mode..." 
                        sleep 0.5
                        echo "Executing ($2) And Proceeding..."
                        eval "$2"
                        echo "Completed."
                        return 0
                        ;;
                N|n)
                        echo "Exiting Install Script..."
                        sleep 2
                        exit
                        ;;
                *)
                        echo "You entered $response. Expected (Y/n)"
                        return 1
                        ;;
esac
} 

swap_partition_prompt() {
	fdisk -l
	printf "\n"
	read -p "Did you create a swap partition in fdisk? (Y/n): " awnser
        case "$awnser" in
                Y|y)
			fdisk -l
			printf "\n"
			read -p "Enter the swap partition that you created in fdisk: " swappartition
			echo "Making swap partition..."
			sleep 2
			mkswap $swappartition
			sleep 2
			echo "Turning swapon..."
			swapon $swappartition
			sleep 2
			return 0	
                        ;;
                N|n)
                        echo "OK. Moving on without swap..."
                        sleep 2
                        return 0
                        ;;
                *)
                        echo "You entered $awnser. Expected (Y/n)"
			sleep 5
                        return 1
                        ;;
esac
}


efi_partition_prompt() {
	fdisk -l
	printf "\n"
	read -p "Did you create a EFI partition in fdisk? (Y/n): " awnser
        case "$awnser" in
                Y|y)
			fdisk -l
			printf "\n"
			read -p "Enter the efi partition that you created in fdisk: " efipartition
			echo "Formatting EFI system partition to FAT32 using mkfs.fat()..."
			sleep 2
			mkfs.fat -F 32 $efi_partition
			# https://wiki.archlinux.org/title/installation_guide#Format_the_partitions
			sleep 2
			return 0
                        ;;
                N|n)
                        echo "OK. Moving on without efi partition..."
                        sleep 2
                        return 0
                        ;;
                *)
                        echo "You entered $awnser. Expected (Y/n)"
			sleep 5
                        return 1
                        ;;
esac
}

# Keyboard Layout Default's to US anyways but just incase...
loadkeys us
# https://wiki.archlinux.org/title/installation_guide#Set_the_console_keyboard_layout

# System clock
timedatectl set-ntp true
# https://wiki.archlinux.org/title/installation_guide#Update_the_system_clock

fdisk -l
printf "\n"
read -p "Enter the drive you would like to partition: " drive

# FDISK
echo "Entering fdisk for partitioning..."
sleep 2
fdisk $drive
echo "Exiting fdisk..."
sleep 4

# EFI PARTITION
until efi_partition_prompt ; do : ; done

# SWAP PARTITION
until swap_partition_prompt ; do : ; done

# ROOT PARTITION
fdisk -l
printf "\n"
read -p "Enter the root partition that you created in fdisk: " root_partition
echo "Formatting root partition to ext4 using mkfs.ext4..."
sleep 2
mkfs.ext4 $root_partition
sleep 2
mount $root_partition /mnt
sleep 2
# https://wiki.archlinux.org/title/installation_guide#Format_the_partitions

# Pacstrap
echo "Using the pacstrap script to install the base package, Linux kernel and firmware for common hardware..."
sleep 5
pacstrap /mnt base linux linux-firmware
#https://wiki.archlinux.org/title/installation_guide#Install_essential_packages

# Fstab
verbose_and_interactive "Generate an fstab file using -U to define by UUID" "genfstab -U /mnt >> /mnt/etc/fstab"
# https://wiki.archlinux.org/title/installation_guide#Fstab

# Create part 2 and change root into the new system
sed '1,/^#part_2$/d' arch_install.sh > /mnt/arch_install_part2.sh
chmod +x /mnt/arch_install_part2.sh
arch-chroot /mnt ./arch_install_part2.sh
exit 

#part_2

# Takes 3 arguements
# 1st arguement is what the command does
# 2nd arguement is the exact command being executed
# 3rd arguement is the URL to the spot in the arch wiki

# Function Definitions

verbose_and_interactive() {
        printf "In simulation mode...\n"
        printf "$1 using the command ($2)\n"
        until prompt "$1" "$2" ; do : ; done
}

prompt() {
  read -p "Does the command ($2) match the Arch Installation guide? (Y/n): " response
        case "$response" in
                Y|y)
                        echo "OK. Exiting simulation mode..." 
                        sleep 0.5
                        echo "Executing ($2) And Proceeding..."
                        eval "$2"
                        echo "Completed."
                        return 0
                        ;;
                N|n)
                        echo "Exiting Install Script..."
                        sleep 2
                        exit
                        ;;
                *)
                        echo "You entered $response. Expected (Y/n)"
                        return 1
                        ;;
esac
} 

printf '\033c'

echo "Inside part 2..."
sleep 5

pacman -S --noconfirm sed
printf '\033c'

# Time Zone
echo "Changing time to US/Eastern..."
sleep 2
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
sleep 1
# https://wiki.archlinux.org/title/installation_guide#Time_zone

# Hwclock
echo "Running hwclock to generate /etc/adjtime"
sleep 2
hwclock --systohc 
sleep 1
#https://wiki.archlinux.org/title/installation_guide#Time_zone

# Localization
echo "Adding en_US.UTF-8 UTF-8 to /etc/locale.gen"
sleep 2
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
sleep 1
#https://wiki.archlinux.org/title/installation_guide#Localization

# Localization Part 2
echo "Generating the locales by running locale-gen..."
sleep 2
locale-gen
sleep 1
#https://wiki.archlinux.org/title/installation_guide#Localization

# Localization Part 3 
echo "Creating the locale.conf file and setting the LANG variable..."
sleep 2
echo "LANG=en_US.UTF-8" > /etc/locale.conf
sleep 1
#https://wiki.archlinux.org/title/installation_guide#Localization

# Localization Part 4
echo "Making keyboard layout changes persistant in vconsole.conf..."
sleep 2
echo "KEYMAP=us" > /etc/vconsole.conf
sleep 1
#https://wiki.archlinux.org/title/installation_guide#Localization

# Network Configuration
read -p "Enter A Hostname For Your Device: " hostname
echo "Adding hostname to /etc/hostname..."
echo $hostname > /etc/hostname
sleep 2
# https://wiki.archlinux.org/title/installation_guide#Network_configuration

# Local Hostname Resolution
echo "Setting up local hostname resolution..."
echo "127.0.0.1       localhost" >> /etc/hosts
sleep 2
echo "::1             localhost" >> /etc/hosts
sleep 2
echo "127.0.1.1       $hostname.localdomain       $hostname" >> /etc/hosts
sleep 2
# https://wiki.archlinux.org/title/Network_configuration#Local_hostname_resolution

echo "---Set the root password---" 
passwd
#https://wiki.archlinux.org/title/installation_guide#Root_password


# Need with encryption (add later)
#verbose_and_interactive "Recreate initramfs image" "mkinitcpio -P" \ 
#"https://wiki.archlinux.org/title/installation_guide#Initramfs"


efi_mount_prompt() {
	fdisk -l
	printf "\n"
	read -p "Did you create an EFI partition earlier in fdisk? (Y/n): " awnser
        case "$awnser" in
                Y|y)

			echo "Downloading grub, efibootmgr & networkmanager..."
			sleep 2
			pacman --noconfirm -S grub efibootmgr networkmanager
			sleep 2
			echo "Making directory /boot/efi..."
			sleep 2
			mkdir /boot/efi
			fdisk -l
			printf "\n"
			read -p "Enter the EFI partition that you created earlier: " efi_partition
			echo "Mounting EFI partition to /boot/efi..."
			sleep 2
			mount $efi_partition /boot/efi 
			# https://wiki.archlinux.org/title/GRUB#UEFI_systems
			sleep 2
			echo "Installing grub EFI application..."
			sleep 2
			grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
			# https://wiki.archlinux.org/title/GRUB#UEFI_systems
			sleep 2
			return 0	
                        ;;
                N|n)
                        echo "OK. Downloading grub & networkmanager..."
                        sleep 2
			pacman --noconfirm -S grub networkmanager
			sleep 2
			printf "\n"
			fdisk -l
			printf "\n"
			read -p "Enter the drive (NOT the partition) where GRUB is to be installed: " drive
			grub-install --target=i386-pc $drive
                        return 0
                        ;;
                *)
                        echo "You entered $awnser. Expected (Y/n)"
			sleep 5
                        return 1
                        ;;
esac
}

# EFI mount
until efi_mount_prompt ; do : ; done

verbose_and_interactive "Generate grub.cfg" "grub-mkconfig -o /boot/grub/grub.cfg" 
# https://wiki.archlinux.org/title/GRUB#Generated_grub.cfg
sleep 5

# Install packages
echo "Installing Your System Packages..."
sleep 5
# Needs to be seperate to reinstall archlinux-keyring... this fixes lightdm-slick-greeter bug
pacman -S --noconfirm archlinux-keyring accountsservice
pacman -S --noconfirm xorg-server xorg-xinit i3-gaps i3blocks rofi nitrogen lightdm lightdm-slick-greeter lxappearance dunst \
picom noto-fonts noto-fonts-emoji xdotool pacutils mupdf imwheel sudo bluez bluez-utils zsh zsh-completions git alacritty \
bpytop firefox neovim tree bluez bluez-utils neofetch lolcat powerline powerline-fonts stow 


printf "\n"
echo "Enabling NetworkManager..."
sleep 2
systemctl enable NetworkManager.service
printf "\n"

echo "Enabling Lightdm..."
sleep 2
printf "\n"
systemctl enable lightdm.service
printf "\n"

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
read -p "Enter Your Username: " username
useradd -m -G wheel -s /bin/zsh $username
passwd $username

aipt3_path=/home/$username/arch_install_part3.sh
sed '1,/^#part_3$/d' arch_install_part2.sh > $aipt3_path
chown $username:$username $aipt3_path
chmod +x $aipt3_path
su -c $aipt3_path -s /bin/zsh $username
exit 

#part_3

# Takes 3 arguements
# 1st arguement is what the command does
# 2nd arguement is the exact command being executed
# 3rd arguement is the URL to the spot in the arch wiki

# Function Definitions

verbose_and_interactive() {
        printf "In simulation mode...\n"
        printf "$1 using the command ($2)\n"
        until prompt "$1" "$2" ; do : ; done
}

prompt() {
  read -p "Does the command ($2) match the Arch Installation guide? (Y/n): " response
        case "$response" in
                Y|y)
                        echo "OK. Exiting simulation mode..." 
                        sleep 0.5
                        echo "Executing ($2) And Proceeding..."
                        eval "$2"
                        echo "Completed."
                        return 0
                        ;;
                N|n)
                        echo "Exiting Install Script..."
                        sleep 2
                        exit
                        ;;
                *)
                        echo "You entered $response. Expected (Y/n)"
                        return 1
                        ;;
esac
} 

printf '\033c'

#echo "Inside part 3..."
#sleep 5

cd $HOME

# POST install (TODO import dot files)
mkdir -p ~/.dev ~/data ~/dl ~/docs ~/drive ~/pics ~/vids ~/.dotfiles ~/.builds/yay/
mv arch_install_part3.sh ~/.dev/
echo "Cloning your dot files..."
sleep 2
git clone https://github.com/EscherMoore/Dotfiles.git ~/.dotfiles/. && sleep 2
sleep 5
rm -rf ~/.bashrc
cd ~/.dotfiles/ && stow -vSt ~ *
sleep 5
pacman -S --noconfirm --needed base-devel
echo "Cloning your AUR helper(yay)..."
sleep 2
git clone https://aur.archlinux.org/yay.git ~/.builds/yay
sleep 5
echo "Installation Complete! Exiting..."
sleep 2
exit
