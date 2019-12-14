# Day 10
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$Input = Get-Content .\10.txt

# Convert into an asteroid list
$Asteroids = @()
$Y = 0
foreach ($Line in $Input) {
    $X = 0
    foreach ($C in $Line.ToCharArray()) {
        if ($C -eq "#") { $Asteroids += "{0},{1}" -f $X, $Y }
        $X++
    }
    $Y++
}

# Part 1
# Go through them all
$Max = 0
$FinalPos = "" 
foreach ($Asteroid in $Asteroids) {

    $LineOfSight = @()
    $Count = 0
    foreach ($A in $Asteroids) {
        if ($A -eq $Asteroid) { continue }
    
        # Relativize the coords
        $CoordsA = $A -split ","
        $CoordsB = $Asteroid -split ","
        $X = [int]$CoordsA[0] - [int]$CoordsB[0]
        $Y = [int]$CoordsA[1] - [int]$CoordsB[1]

        # Line of sight
        $Val = [math]::Atan2($Y, $X)

        if ($LineOfSight -contains $Val) { continue }
        $LineOfSight += $Val
        $Count++
    }

    if ($Count -gt $Max) { 
        $FinalPos = $Asteroid
        $Max = $Count 
    }
}
Write-Host "Final position: $($FinalPos), detections: $($Max)"
