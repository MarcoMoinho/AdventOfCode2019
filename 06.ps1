# Day 6
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$Orbits = Get-Content .\06.txt
$OrbitList = @{}

function Assert-IsObjectInPath {
    param (
        [Parameter(Mandatory)] [string] $Object,
        [Parameter(Mandatory)] [string] $Path
    )

    if ($Path -eq "COM") { return $false }
    if ($Path -eq $Object) { return $true }

    return Assert-IsObjectInPath -Object $Object -Path $Script:OrbitList[$Path]
}

function Get-OrbitCount {
    param (
        [Parameter(Mandatory)] [string] $Object,
        [Parameter(Mandatory)] [string] $End
    )

    if ($Object -eq $End)  { return 0 }
    if ($Object -eq "COM") { return 0 } 
    return 1 + (Get-OrbitCount -Object $Script:OrbitList[$Object] -End $End)
}

# Create an Orbit List, equal to the input but easier to access
$Script:OrbitList."COM" = ""
foreach ($Orbit in $Orbits) {
    $tmp = $Orbit -split "\)"
    $Script:OrbitList."$($tmp[1])" = $tmp[0]
}

# Part 1
# For each object count the total orbits
$Part1 = 0
foreach ($Object in $Script:OrbitList.Keys) {
    if ($Object -eq "") { continue }
    $Part1 += Get-OrbitCount -Object $Object -End "COM"
}
Write-Output "Part1: $($Part1)"

# Part 2
# Search for a common node between YOU and SAN
$Object = "YOU"
do {
    $Object = $Script:OrbitList[$Object]
    if (Assert-IsObjectInPath -Object $Object -Path "SAN") { break }
} until ($Object -eq "COM")

# Count the orbits between both, minus 1 because start is included
$Part2 =  (Get-OrbitCount -Object "YOU" -End $Object) - 1
$Part2 += (Get-OrbitCount -Object "SAN" -End $Object) - 1

Write-Output "Part2: $($Part2)"