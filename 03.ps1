# Day 3
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

function Expand-Directions {
    param (
        [Parameter(Mandatory)] [string] $Path,
        [Parameter(Mandatory)] [Object] $CurrentXY
    )

    $Direction = $Path.Substring(0,1)
    $Length = [int]$Path.Substring(1,$Path.Length-1)

    [int]$X = $CurrentXY.X 
    [int]$Y = $CurrentXY.Y
    $Points = @()

    for ($C = 0; $C -lt $Length; $C++) {
        switch ($Direction) {
            "U" { $Y++ }
            "D" { $Y-- }
            "R" { $X++ }
            "L" { $X-- }
            Default { throw }
        }
        $Points += "{0},{1}" -f $X,$Y
    }

    return @{
        X = $X
        Y = $Y
        Points = $Points
    }
}

# Get all the directions 
$Directions = Get-Content .\03.txt

# Calculate all the points for Path A
Write-Host "Getting Path A... " -NoNewline
$PositionA = @{
    X = 0
    Y = 0
}
$PointsA = @()
foreach ($Path in ($Directions[0] -split ",")) {
    $Tmp = Expand-Directions -Path $Path -CurrentXY $PositionA
    $PositionA.X = $Tmp.X
    $PositionA.Y = $Tmp.Y
    $PointsA    += $Tmp.Points
}
Write-Host "$($PointsA.Count) points"

# Calculate all the points for Path B
Write-Host "Getting Path B... " -NoNewline
$PositionB = @{
    X = 0
    Y = 0
}
$PointsB = @()
foreach ($Path in ($Directions[1] -split ",")) {
    $Tmp = Expand-Directions -Path $Path -CurrentXY $PositionB
    $PositionB.X = $Tmp.X
    $PositionB.Y = $Tmp.Y
    $PointsB    += $Tmp.Points
}
Write-Host "$($PointsB.Count) points"

# Check the closest to 0 for Part A
Write-Host "Comparing both paths... "
[int]$Min = 9999999
foreach ($Point in $PointsA) {
    $XY = $Point -split ","
    if (([math]::Abs($XY[0]) + [math]::Abs($XY[1])) -gt $Min){ continue }

    if ($Point -in $PointsB) {
        if (([math]::Abs($XY[0]) + [math]::Abs($XY[1])) -lt $Min){
            $Min = [math]::Abs($XY[0]) + [math]::Abs($XY[1])
        }
     }
}
Write-Host "Part1: $($Min)"

# Part B
$Min = 9999999
for ($LenA = 0; $LenA -lt $PointsA.Count; $LenA++) {
    
    if ($LenA % 100 -eq 0) { Write-Progress -Activity "Searching Part B" -Status "Searching $($LenA)/$($PointsA.Count)" -PercentComplete ($LenA/$PointsA.Count*100) }
    
    if ($LenA -gt $Min) { continue }
    
    if ($PointsA[$LenA] -in $PointsB) {
        for ($LenB = 0; $LenB -lt $PointsB.Count; $LenB++) {
            
            if ($LenB -gt $Min) { continue }
            if ($PointsB[$LenB] -eq $PointsA[$LenA]) {
                if (($LenA + $LenB) -lt $Min) { 
                    $Min = $LenA + $LenB
                    break
                }
            }

        }
    }

}

Write-Host "Part2: $($Min+2)"