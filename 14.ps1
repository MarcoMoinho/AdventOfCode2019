# Day 14
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

$Script:Reactions = @{}
$Script:Quantities = @{}
$Script:Stock = @{}
[long]$Script:TotalOre = 0

function Get-Reactions {
    Get-Content -Path .\14.txt | ForEach-Object {
        $tmp = $_ -split "=>"

        $Dest = Get-FromText -Text $tmp[1]
        $Source = @{}
        $tmp[0] -split "," | ForEach-Object {
            $tmp2 = Get-FromText $_
            $Source += @{ $tmp2.Material = $tmp2.Qty }
        }
    
        $R = @{}
        $R."$($Dest.Material)" = @{
            Quantity = $Dest.Qty
            Materials = $Source 
        }
        $Script:Reactions += $R 
    }
}

function Get-FromText {
    param (
        [Parameter(Mandatory)] [String] $Text
    )

    $Tmp = $Text.Trim() -split " "
    return @{
        Material = $Tmp[1]
        Qty = $Tmp[0]
    }
}

function Get-Materials {
    param (
        [Parameter(Mandatory)] [string] $RawMaterial,
        [Parameter(Mandatory)] [long] $Qty
    )

    if ($RawMaterial -eq "ORE") {
        $Script:TotalOre += $Qty
        return 
    }

    if ($Script:Reactions.Keys -notcontains $RawMaterial) { throw }

    # Check our stock
    if ($Script:Stock.Keys -notcontains $RawMaterial) { $Script:Stock.$RawMaterial = 0 }
    if ($Script:Stock.$RawMaterial -lt $Qty) {
        
        # We need to request more if we dont have enough
        [long]$QuantityCreatable = $Script:Reactions.$RawMaterial.Quantity
        [long]$QuantityRequired = [math]::Ceiling( ($Qty - $Script:Stock.$RawMaterial) / $QuantityCreatable )

        # Get all the components for this material 
        foreach ($Component in $Script:Reactions.$RawMaterial.Materials.Keys) {
            [long]$ComponentQuantity = $Script:Reactions.$RawMaterial.Materials.$Component
            Get-Materials -RawMaterial $Component -Qty ( $ComponentQuantity * $QuantityRequired )
        }

        # Create it
        $Script:Stock.$RawMaterial += $QuantityRequired * $QuantityCreatable
    }

    # We need to take it out of stock since we used it
    $Script:Stock.$RawMaterial -= $Qty
    if ($Script:Stock.$RawMaterial -lt 0) { throw }
}

# Create a list of all the reactions in the file
Get-Reactions

# Get all the required materials
Get-Materials -RawMaterial "FUEL" -Qty 1
Write-Host "Part1: Total Ore: $($Script:TotalOre)"

# Part2
$Ore1Fuel = $Script:TotalOre
$TargetOre = 1000000000000

$Script:Quantities = @{}
$Script:Stock = @{}
[long]$Script:TotalOre = 0
$FuelMade = 0
do {
    [int]$Step = [math]::Floor(($TargetOre - $Script:TotalOre) / $Ore1Fuel)
    Get-Materials -RawMaterial "FUEL" -Qty $Step
    $FuelMade += $Step 
} while ($Step -gt 1)

Write-Host "Part2: $($FuelMade) fuel made with $($Script:TotalOre) ore."