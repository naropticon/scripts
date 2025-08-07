#!/bin/bash

echo "Lekérdezés az összes helm.sh/release.v1 Secret-ről..."
mapfile -t helm_secrets < <(oc get secrets -A -o json | jq -r '
  .items[] | 
  select(.type == "helm.sh/release.v1") | 
  "\(.metadata.namespace) \(.metadata.name)"
')

echo "Lekérdezés az aktív helm release-ekről..."
mapfile -t helm_releases < <(helm list -A -o json | jq -r '.[] | "\(.namespace) \(.name)"')

# Összehasonlítás
echo ""
echo "Árván maradt helm.sh/release.v1 secretek:"
for secret in "${helm_secrets[@]}"; do
    ns=$(awk '{print $1}' <<< "$secret")
    name=$(awk '{print $2}' <<< "$secret")

    # Kibontjuk a release nevet a Secret nevéből
    # Formátum: sh.helm.release.v1.<name>.v<version>
    release_name=$(sed -E 's/^sh\.helm\.release\.v1\.([^\.]+)\.v[0-9]+$/\1/' <<< "$name")

    if ! grep -q "$ns $release_name" <<< "${helm_releases[*]}"; then
        echo "  Namespace: $ns, Secret: $name (nincs hozzá tartozó release)"
    fi
done
