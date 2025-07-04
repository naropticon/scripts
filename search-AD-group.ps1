# Használat powershellből:
# powershell -ExecutionPolicy Bypass -File .\keres-csoportok.ps1

# Módosítsd ezt a változót arra, amivel kezdődik a keresett csoportnév
$keresettEleje = "dev"

# AD keresés inicializálása
$kereso = New-Object DirectoryServices.DirectorySearcher
$kereso.Filter = "(&(objectCategory=group)(name=$keresettEleje*))"
$kereso.PageSize = 1000  # biztosítja, hogy ne korlátozza 100 találatra
$kereso.PropertiesToLoad.Add("name") | Out-Null

# Találatok kiírása
$talalatok = $kereso.FindAll()

if ($talalatok.Count -eq 0) {
    Write-Host "Nincs találat a(z) '$keresettEleje*' csoportnévre."
} else {
    Write-Host "Talált csoportok:"
    foreach ($talalat in $talalatok) {
        $talalat.Properties["name"]
    }
}
