#!/bin/bash

# Küsin kasutajalt uue kasutajanime ja salvestan selle muutujasse kasutajanimi
read -p "Sisesta uus kasutajanimi: " kasutajanimi

# Küsin kasutajalt parooli ja salvestan selle muutujasse parool; -s peidab parooli trükkimise ajal
read -s -p "Sisesta parool: " parool

# Teen tühja rea, sest read -s ei vii automaatselt uut rida ilusasti edasi
echo

# Kontrollin, kas skript käivitati root/sudo õigustes
if [ "$EUID" -ne 0 ]; then

    # Kuvan veateate, kui skriptil ei ole piisavalt õigusi
    echo "Palun käivita skript sudo õigustes!"

    # Lõpetan skripti veakoodiga 1
    exit 1

# Lõpetan root õiguste kontrolli
fi

# Kontrollin, kas sisestatud kasutajanimi on tühi
if [ -z "$kasutajanimi" ]; then

    # Kuvan veateate, kui kasutajanime ei sisestatud
    echo "Kasutajanimi ei tohi olla tühi!"

    # Lõpetan skripti veakoodiga 1
    exit 1

# Lõpetan tühja kasutajanime kontrolli
fi

# Kontrollin, kas sellise nimega kasutaja on juba olemas
if id "$kasutajanimi" &>/dev/null; then

    # Kuvan teate, kui kasutaja on juba olemas
    echo "Kasutaja $kasutajanimi on juba olemas!"

    # Lõpetan skripti veakoodiga 1
    exit 1

# Lõpetan olemasoleva kasutaja kontrolli
fi

# Loon uue kasutaja koos kodukataloogiga /home/kasutajanimi
useradd -m "$kasutajanimi"

# Määran loodud kasutajale parooli muutujast parool
echo "$kasutajanimi:$parool" | chpasswd

# Loon kasutaja kodukataloogi sisse kausta nimega kataloog
mkdir -p "/home/$kasutajanimi/kataloog"

# Loon kausta sisse faili nimega teretulemast_kasutajanimi.txt
touch "/home/$kasutajanimi/kataloog/teretulemast_$kasutajanimi.txt"

# Kirjutan faili sisse tervitusteksti
echo "Tere tulemast, $kasutajanimi!" > "/home/$kasutajanimi/kataloog/teretulemast_$kasutajanimi.txt"

# Määran kataloogi ja faili omanikuks loodud kasutaja
chown -R "$kasutajanimi:$kasutajanimi" "/home/$kasutajanimi/kataloog"

# Annan kataloogile õigused: omanik saab muuta, teised saavad lugeda ja siseneda
chmod 755 "/home/$kasutajanimi/kataloog"

# Annan failile õigused: omanik saab muuta, teised saavad lugeda
chmod 644 "/home/$kasutajanimi/kataloog/teretulemast_$kasutajanimi.txt"

# Kuvan teate, et kasutaja loomine õnnestus
echo "Kasutaja $kasutajanimi on loodud."

# Kuvan loodud faili täpse asukoha
echo "Fail asub: /home/$kasutajanimi/kataloog/teretulemast_$kasutajanimi.txt"
