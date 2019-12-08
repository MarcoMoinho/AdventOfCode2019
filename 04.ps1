# Day 4
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$Min = 137683
$Max = 596253

$Part1 = 0
$Part2 = 0
for ($n = $Min; $n -le $Max; $n++) {

    if ($n % 10000 -eq 0) { Write-Progress -Activity "Searching" -Status "Searching $($n)/$($Max)" -PercentComplete ($n/$Max*100) }

    # Check if they are increasing or at least same
    for ($i = 0; $i -lt 5; $i++) {
        if ([int]$n.ToString().Substring($i,1) -gt [int]$n.ToString().Substring($i+1,1)) { break }    
    }
    if ($i -lt 5) { continue }

    # Match for Part 1
    if ($n.ToString() -match "(\d)\1{1,}") { $Part1++ }

    # Match for Part 2
    $ok = $false
    for ($i = 0; $i -le 9; $i++) {
        if (($n.ToString() -like "*$($i)$($i)*") -and ($n.ToString() -notlike "*$($i)$($i)$($i)*")) { $ok = $true }
    }
    if ($ok) { $Part2++ }

}

Write-Output "Total Part1: $($Part1)"
Write-Output "Total Part2: $($Part2)"