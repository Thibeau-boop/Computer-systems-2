#!/bin/bash

#==============================================================================
#           FILE: colman_multi.sh
#          USAGE: ./colman_ibans.sh <modus> <bestand>
#    DESCRIPTION: Controleert of IBAN rekeningnummers correct zijn.
#
#        OPTIONS: <modus> - 'g' voor IBAN zonder spaties, 's' voor IBAN met spaties
#         AUTHOR: Thibeau Colman (thibeau.colman@student.kdg.be)
#==============================================================================

# normaal moet er gecheckt worden of alles geinstalleerd is maar aangezien dit hier niet van toepassing is, is dit niet nodig


echo 'Dit is het script van Thibeau Colman'


if [ "$EUID" -eq 0 ]; then
    echo "Please run as non-root"
    exit 1
fi

rood='\033[0;31m'
reset='\033[0m'

function printError() {
    echo -e "${rood}Fout: $1${reset}" >&2
    exit 1
}

if [ "$1" == "--help" ]; then
    echo -e "\e[32m"
    echo "Gebruik: $0 <modus> <bestand>"
    echo "Controleert of IBAN rekeningnummers correct zijn."
    echo ""
    echo "  <modus> - 'g' voor IBAN zonder spaties, 's' voor IBAN met spaties"
    echo -e "\e[0m"
    exit 0
fi

function rekeningcontrole() {
    iban=$1
    rekening=$2
    controlegetal=$3
    
    rekening=$(echo $rekening | sed 's/^0*//')

    if (( rekening % 97 == controlegetal )); then
        echo "Gevonden: $iban (Correct)"
    else
        echo -e "Gevonden: $iban (${rood}NIET ${reset}Correct)"
    fi
}

function zoek_iban() {
    mode=$1
    file=$2

    if [ "$mode" == "g" ]; then
        iban_regex="([A-Z]{2}[0-9]{2}[A-Z0-9]{10}[0-9]{2})"
    elif [ "$mode" == "s" ]; then
        iban_regex="([A-Z]{2}[0-9]{2}( [A-Z0-9]{4}){3} [0-9]{2})|([A-Z]{2}[0-9]{2}[A-Z0-9]{10}[0-9]{2})"
    else
        printError "Ongeldige modus. Gebruik 'g' voor IBAN zonder spaties of 's' voor IBAN met spaties."
    fi
    
    while IFS= read -r line; do
        if [[ $line =~ $iban_regex ]]; then
            iban="${BASH_REMATCH[0]}"
            clean_iban="${iban// /}"
            rekeningnummer="${clean_iban:4:10}"
            controlegetal="${clean_iban:14:2}"
            
            if [ "$mode" == "s" ]; then
                iban="${clean_iban:0:4} ${clean_iban:4:4} ${clean_iban:8:4} ${clean_iban:12:4} ${clean_iban:16:2}"
            fi
            
            rekeningcontrole "$iban" "$rekeningnummer" "$controlegetal"
        fi
    done < "$file"
}

if [ "$#" -ne 2 ]; then
    printError "Gebruik: $0 <modus> <bestand>"
fi

if [ ! -f "$2" ] || [ ! -s "$2" ]; then
    printError "Het opgegeven bestand bestaat niet of is leeg."
fi

zoek_iban "$1" "$2"


    