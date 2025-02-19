#!/bin/bash

#==============================================================================
#           FILE: colman_shadow.sh
#          USAGE: ./colman_shadow.sh -u <gebruikersnaam> -p <wachtwoord>
#    DESCRIPTION: Voegt gebruiker toe aan shadow bestand en controleert wachtwoord.
#
#        OPTIONS: -u <gebruikersnaam> -p <wachtwoord>
#         AUTHOR: Thibeau Colman (thibeau.colman@student.kdg.be)
#==============================================================================


echo 'Dit is het script van Thibeau Colman'

function printError() {
    echo -e "\033[0;31mFout: $1\033[0m" >&2
    exit 1
}


function askForInput() {
    if [ -z "$username" ]; then
        read -p "Geef gebruikersnaam: " username
        echo "Gebruikersnaam: $username"
    else
        echo "Gebruikersnaam: $username"
    fi
    if [ -z "$password" ]; then
        read -sp "Geef wachtwoord: " password
        echo
        echo "Wachtwoord: $password"
    fi
}


while getopts "u:p:" opt; do
    case $opt in
        u) username=$OPTARG ;;
        p) password=$OPTARG ;;
        *) printError "Ongeldige optie: -$OPTARG" ;;
    esac
done

askForInput

if [[ ! "$username" =~ ^[a-zA-Z]+$ ]]; then
    printError "Gebruikersnaam mag enkel uit alfabetische karakters bestaan."
fi

password_hash=$(echo -n "$password" | sha256sum | awk '{print $1}')

if grep -q "^$username:" shadow; then
    existing_hash=$(grep "^$username:" shadow | cut -d':' -f2)
    if [ "$existing_hash" == "$password_hash" ]; then
        echo "Paswoord klopt."
    else
        echo "Paswoord $password is fout."
    fi
    echo "User $username bestaat al."
else
    echo "Gebruikersnaam: $username"
    echo "Wachtwoord: $password"
    echo "SHA-256 Hash: $password_hash"

    echo "$username:$password_hash" >> shadow

    echo "Gebruiker $username is toegevoegd aan het shadow bestand."
fi