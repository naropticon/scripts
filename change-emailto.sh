#!/bin/bash

valami_file="valami"
yaml_file="values.yaml"
tmp_file="tmp.yaml"

cp "$yaml_file" "$tmp_file"

# beolvassuk a valami fájl szavait tömbbe
mapfile -t szavak < "$valami_file"

# soronként bejárjuk a YAML-t és átírjuk, ha kell
awk -v szavak="${szavak[*]}" '
BEGIN {
    split(szavak, keresett_szavak, " ");
    keres_mod = 0;
}
{
    # ellenőrizzük, hogy ez egy blokkelem-e (szó szerepel-e a sorban)
    for (i in keresett_szavak) {
        if (index($0, keresett_szavak[i]) > 0) {
            keres_mod = 1;
            break;
        }
    }

    if (keres_mod == 1 && $0 ~ /emailto:/) {
        print "emailto: uj@mail.hu";
        keres_mod = 0;
    } else {
        print $0;
    }
}
' "$yaml_file" > "$tmp_file"
