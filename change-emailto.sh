#!/bin/bash

valami_file="valami"
yaml_file="values.yaml"
tmp_file="tmp.yaml"

cp "$yaml_file" "$tmp_file"

# sorok bejárása a valami fájlból
while read -r valtozo; do
    # keresd meg az első sor számát, ahol ez a változó szerepel
    match_line=$(grep -n "$valtozo" "$tmp_file" | head -n1 | cut -d: -f1)

    # ha nincs találat, menj tovább
    [[ -z "$match_line" ]] && continue

    # számold ki a harmadik sor pozícióját
    target_line=$((match_line + 3))

    # csak akkor módosítsuk, ha azon a soron valóban emailto szerepel
    current_line=$(sed -n "${target_line}p" "$tmp_file")
    if [[ "$current_line" == *"emailto:"* ]]; then
        sed -i "${target_line}s/emailto: .*/emailto: uj@mail.hu/" "$tmp_file"
    fi

done < "$valami_file"
