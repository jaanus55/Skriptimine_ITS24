#!/bin/bash

# Küsin kasutajalt teenuse nime ja salvestan selle muutujasse "teenus"
read -p "Sisesta teenuse nimi: " teenus

# Kontrollin, kas kasutaja jättis teenuse nime tühjaks
if [ -z "$teenus" ]; then

    # Kui teenuse nime ei sisestatud, kuvan veateate
    echo "Viga: teenuse nimi ei tohi olla tühi!"

    # Lõpetan skripti veakoodiga 1
    exit 1

# Lõpetan tühja sisendi kontrolli
fi

# Kontrollin systemctl käsuga, kas teenus on aktiivne
# --quiet tähendab, et systemctl ei väljasta teksti, vaid annab ainult tulemuskoodi
if systemctl is-active --quiet "$teenus"; then

    # Kui teenus on aktiivne, kuvan teate, et teenus töötab
    echo "$teenus on aktiivne ja töötab."

# Kui teenus ei ole aktiivne, läheb skript else ossa
else

    # Kui teenus ei ole aktiivne, kuvan hoiatuse
    echo "Hoiatus: $teenus ei ole aktiivne!"

# Lõpetan if tingimuslause
fi
