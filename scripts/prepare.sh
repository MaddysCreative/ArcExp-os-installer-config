#!/usr/bin/env bash

# Function to display an error and exit
show_error() {
    printf "ERROR: %s\n" "$1" >&2
    exit 1
}

# Loop until pacman-init.service finishes
printf 'Waiting for pacman-init.service to finish running before starting the installation... '

while true; do
    systemctl status pacman-init.service | grep -q 'Finished Initializes Pacman keyring.'

    if [[ $? -eq 0 ]]; then
        printf 'Done'
        break
    fi

    sleep 2
done

# Synchronize with repos
sudo pacman -Syy || show_error "Failed to synchronize with repos"

# Optimize download speed using reflector based on IP address
country_code=$(curl -s https://ipapi.co/country/)
sudo reflector --country $country_code --age 20 --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist || show_error "Failed to optimize download speed"

exit 0
