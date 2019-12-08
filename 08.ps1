# Day 8
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

# Image data
$Data = (Get-Content .\08.txt).ToCharArray()
$Width  = 25
$Height = 6

# Layer data
$Layer = 0
$Layers = @{}

# Store everything into separate layers
$Counter = -1
foreach ($Dig in $Data) {
    $Counter++
    if ($Counter % ($Width * $Height) -eq 0) { 
        $Layer += 1
        $Layers.$Layer = @()
    }
    $Layers.$Layer += $Dig
}

# Find the fewest 0 digits
# This could be done in the loop above
$Min = $Width * $Height + 1
$LayerID = -1
foreach ($L in $Layers.Keys) {
    $Count = 0
    foreach ($Dig in $Layers.$L) {
        if ($Dig -eq "0") { $Count++ }
        if ( $Count -gt $Min ) { break }
    }
    if ( $Count -lt $Min) {
        $Min = $Count
        $LayerID = $L
    }
}

# Count the number of digits required in the layer
$DigA = 0
$DigB = 0
foreach ($Dig in $Layers.$LayerID) {
    if ($Dig -eq "1") { $DigA ++ }
    if ($Dig -eq "2") { $DigB ++ }
}
Write-Host "Part1: $($DigA*$DigB)"


# Part 2

# Create a single Layer with the Image
$Image = @()
for ($Pixel = 0; $Pixel -lt $Width * $Height; $Pixel++) { $Image += "2" } # Transparent image
for ($L = 1; $L -le $Layers.Count; $L++) {
    $Pixel = -1
    foreach ($Dig in $Layers.$L) {
        $Pixel++
        if ($Dig -eq "2") { continue }
        if ($Image[$Pixel] -eq "2") { $Image[$Pixel] = $Dig } 
    }    
}

# Print on screen
for ($Pixel = 0; $Pixel -lt $Image.Count; $Pixel++) {
    if ($Pixel % $Width -eq 0) { Write-Host "" }
    if ($Image[$Pixel] -eq "1") { Write-Host "X" -NoNewline } else { Write-Host " " -NoNewline }
}
Write-Host ""