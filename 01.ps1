# Day 1
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$MassList = Get-Content .\01.txt

function Get-FuelRequired {
    param (
        [Parameter(Mandatory)] [int]  $Mass,
        [Parameter(Mandatory)] [bool] $Recursive
    )

    $Fuel = ([math]::floor($Mass / 3) - 2)
    
    if ($Fuel -lt 0) { return 0 }
    if ($Recursive) {
        return $Fuel + (Get-FuelRequired -Mass $Fuel -Recursive $true) 
    } else {
        return $Fuel
    }
}

$FuelModules    = 0
$FuelEverything = 0

foreach ($Mass in $MassList) {

    $ModuleFuel = Get-FuelRequired -Mass $Mass -Recursive $false
    $FuelModules += $ModuleFuel
    $FuelEverything += Get-FuelRequired -Mass $ModuleFuel -Recursive $true
    $FuelEverything += $ModuleFuel

}

Write-Output "Fuel for modules: $($FuelModules)"
Write-Output "Total fuel: $($FuelEverything)"
