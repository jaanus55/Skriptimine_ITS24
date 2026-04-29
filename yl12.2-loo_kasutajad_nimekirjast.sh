#!/bin/bash

# Määran nimekirjafaili asukoha muutujasse
nimekiri="/home/kasutaja/skriptid/nimekiri.txt"

# Määran väljundfaili, kuhu salvestatakse kasutajanimed ja paroolid
valjund="/home/kasutaja/skriptid/loodud_kasutajad.txt"

# Kontrollin, kas skript käivitati sudo/root õigustes
if [ "$EUID" -ne 0 ]; then
    echo "Palun käivita skript sudo õigustes!"
    exit 1
fi

# Kontrollin, kas etteantud nimekiri on olemas
if [ ! -e "$nimekiri" ]; then
    echo "Hoiatus: faili $nimekiri ei ole olemas!"
    exit 1
fi

# Kontrollin, kas etteantud nimekiri on ikka tavaline fail
if [ ! -f "$nimekiri" ]; then
    echo "Hoiatus: $nimekiri pole fail!"
    exit 1
fi

# Teen väljundfaili tühjaks või loon selle, kui seda pole olemas
> "$valjund"

# Kirjutan väljundfaili päise
echo "Kasutajanimi Parool" >> "$valjund"

# Funktsioon, mis muudab nime väiketähtedeks ja asendab täpitähed
muuda_nimi() {
    echo "$1" | tr '[:upper:]ÕÄÖÜ' '[:lower:]õäöü' | sed 's/õ/o/g; s/ü/u/g; s/ä/a/g; s/ö/o/g'
}

# Loen nimekirjafaili rida realt
while read -r eesnimi perenimi; do

    # Kui rida on tühi, jätan selle vahele
    if [ -z "$eesnimi" ] || [ -z "$perenimi" ]; then
        continue
    fi

    # Muudan eesnime väiketähtedeks ja eemaldan täpitähed
    eesnimi_puhas=$(muuda_nimi "$eesnimi")

    # Muudan perenime väiketähtedeks ja eemaldan täpitähed
    perenimi_puhas=$(muuda_nimi "$perenimi")

    # Tekitan kasutajanime kujul eesnimi.perenimi
    kasutajanimi="${eesnimi_puhas}.${perenimi_puhas}"

    # Tekitan 12 märgi pikkuse parooli
    parool=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c12)

    # Kontrollin, kas kasutaja on juba olemas
    if id "$kasutajanimi" &>/dev/null; then

        # Kui kasutaja on olemas, kirjutan selle kohta teate ekraanile
        echo "Kasutaja $kasutajanimi on juba olemas, jätan vahele."

        # Liigun järgmise nime juurde
        continue
    fi

    # Loon süsteemi kasutaja koos kodukataloogiga
    useradd -m "$kasutajanimi"

    # Määran kasutajale loodud parooli
    echo "$kasutajanimi:$parool" | chpasswd

    # Kirjutan kasutajanime ja parooli väljundfaili
    echo "$kasutajanimi $parool" >> "$valjund"

    # Kuvan ekraanile, et kasutaja on loodud
    echo "Loodud kasutaja: $kasutajanimi"

# Annan while-tsüklile sisendiks nimekirjafaili
done < "$nimekiri"

# Kuvan, kuhu tulemus salvestati
echo "Valmis. Kasutajanimed ja paroolid asuvad failis: $valjund"
