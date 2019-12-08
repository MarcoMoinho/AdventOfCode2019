# Day 5
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

 function Invoke-Function {
    param ( 
        [Parameter(Mandatory)] [int] $ValA,
        [Parameter(Mandatory)] [int] $ValB,
        [Parameter(Mandatory)] [int] $Address,
        [Parameter(Mandatory)] [string] $Type
    )

    switch ($Type) {
        "+" { $Script:IntCode[$Address] = $ValA + $ValB }
        "*" { $Script:IntCode[$Address] = $ValA * $ValB }
        Default { throw }
    }
 }

 function Invoke-Memory {
    param ( 
        [Parameter()]          [int]  $Value,
        [Parameter(Mandatory)] [int]  $Address,
        [Parameter(Mandatory)] [bool] $Write
    )

    if ($Write) { $Script:IntCode[$Address] = $Value } else { return $Script:IntCode[$Address] }
 }


$Script:IntCode = (Get-Content .\05.txt) -split ","
[int]$OpCode = 0
[int]$Pointer = 0

do {
    
    $Mode = "{0:00000}" -f ([int]$Script:IntCode[$Pointer])
    $OpCode = [int] $mode.Substring(3,2)

    # Get the values depending on the Mode
    if ($OpCode -in @(1,2,5,6,7,8)) {
        if ( $Mode.Substring(2,1) -eq "0" ) { $ValA = $Script:IntCode[$Script:IntCode[$Pointer + 1]] } else { $ValA = $Script:IntCode[$Pointer + 1] } 
        if ( $Mode.Substring(1,1) -eq "0" ) { $ValB = $Script:IntCode[$Script:IntCode[$Pointer + 2]] } else { $ValB = $Script:IntCode[$Pointer + 2] }
        if ($OpCode -in @(1,2,7,8)) {
            if ( $Mode.Substring(0,1) -eq "0" ) { $ValC = $Script:IntCode[$Pointer + 3] } else { $ValC = $Pointer + 3 }
        }
    }
    if ($OpCode -in @(3,4)) {
        if ( $Mode.Substring(2,1) -eq "0" ) { $ValA = $Script:IntCode[$Pointer + 1] } else { $ValA = $Pointer + 1 }
    }

    # Run the OpCode
    switch ($OpCode) {
        1 { Invoke-Function -Type "+" -ValA $ValA -ValB $ValB -Address $ValC }
        2 { Invoke-Function -Type "*" -ValA $ValA -ValB $ValB -Address $ValC }
        3 { Invoke-Memory -Write $true -Value (Read-Host "Insert value") -Address $ValA }
        4 { Write-Host "Output: " (Invoke-Memory -Write $false -Address $ValA) }
        5 { if ($ValA -gt 0) { $Pointer = $ValB } else { $Pointer += 3 } }
        6 { if ($ValA -eq 0) { $Pointer = $ValB } else { $Pointer += 3 } }
        7 { if ($ValA -lt $ValB) { Invoke-Memory -Write $true -Value "1" -Address $ValC } else { Invoke-Memory -Write $true -Value "0" -Address $ValC } }
        8 { if ($ValA -eq $ValB) { Invoke-Memory -Write $true -Value "1" -Address $ValC } else { Invoke-Memory -Write $true -Value "0" -Address $ValC } }
        99 { }
        Default { throw }
    }

    if ($OpCode -in @(1,2,7,8)) { $Pointer += 4 }
    if ($OpCode -in @(3,4))     { $Pointer += 2 }

} until ($OpCode -eq 99)