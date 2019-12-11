# Day 9
# Intcode computer rebuilt
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

# Local Memory
$Script:Memory = @{}
$Script:RelativeBase = 0

function Read-Memory {
    param (
        [Parameter(Mandatory)] [double] $Pointer,
        [Parameter(Mandatory)] [string] $Mode
    )

    [string]$Address = 0
    switch ($Mode) {
        "0" { $Address = Read-Memory -Mode 1 $Pointer }
        "1" { $Address = $Pointer }
        "2" { $Address = [double]$Script:RelativeBase + [double](Read-Memory -Mode 1 $Pointer) }
        Default { throw }
    }
    if ($Script:Memory.Keys -notcontains $Address) { return 0 } else { $Script:Memory.$Address }
}

function Write-Memory {
    param (
        [Parameter(Mandatory)] [double] $Pointer,
        [Parameter(Mandatory)] [string] $Mode,
        [Parameter(Mandatory)] [string] $Value
    )

    [string]$Address = 0
    switch ($Mode) {
        "0" { $Address = Read-Memory -Mode 1 $Pointer }
        "1" { throw }
        "2" { $Address = [double]$Script:RelativeBase + [double](Read-Memory -Mode 1 $Pointer) }
        Default { throw }
    }
    $Script:Memory.$Address = $Value
}

function Start-IntCode {
    param ( 
        [Parameter(Mandatory)] [object] $IntCode,
        [Parameter(Mandatory)] [double] $Pointer,
        [Parameter(Mandatory)] [double] $RelativeBase

    )

    # Put as global so I don't have to pass them around 
    $Script:Memory = $IntCode
    $Script:RelativeBase = $RelativeBase 

    [int]$OpCode = 0

    do {
        
        $Mode = "{0:00000}" -f [int](Read-Memory -Pointer $Pointer -Mode 1)
        $OpCode = [int] $Mode.Substring(3,2)

        # Parse all modes 
        $Val1 = @{ Pointer = $Pointer + 1;  Mode = $Mode.Substring(2, 1) }
        $Val2 = @{ Pointer = $Pointer + 2;  Mode = $Mode.Substring(1, 1) }
        $Val3 = @{ Pointer = $Pointer + 3;  Mode = $Mode.Substring(0, 1) }

        # Run the OpCode
        switch ($OpCode) {
            1 { Write-Memory @Val3 -Value ([double](Read-Memory @Val1) + [double](Read-Memory @Val2)) }
            2 { Write-Memory @Val3 -Value ([double](Read-Memory @Val1) * [double](Read-Memory @Val2)) }
            3 { Write-Memory @Val1 -Value (Read-Host "Insert number") }
            4 { Write-Host "Out:" (Read-Memory @Val1) }
            5 { if ([double](Read-Memory @Val1) -gt 0) { $Pointer = [double](Read-Memory @Val2) } else { $Pointer += 3 } }
            6 { if ([double](Read-Memory @Val1) -eq 0) { $Pointer = [double](Read-Memory @Val2) } else { $Pointer += 3 } }
            7 { if ([double](Read-Memory @Val1) -lt [double](Read-Memory @Val2)) { Write-Memory @Val3 -Value "1" } else { Write-Memory @Val3 -Value "0" } }
            8 { if ([double](Read-Memory @Val1) -eq [double](Read-Memory @Val2)) { Write-Memory @Val3 -Value "1" } else { Write-Memory @Val3 -Value "0" } }
            9 { $Script:RelativeBase += [double](Read-Memory @Val1) }
            99 { return $null }
            Default { throw }
        }

        if ($OpCode -in @(1,2,7,8)) { $Pointer += 4 }
        if ($OpCode -in @(3,4,9))   { $Pointer += 2 }

    } until ($OpCode -eq 99)

    return $null
}


$Count = 0
$IntCode = @{}
((Get-Content .\09.txt) -split ",") | ForEach-Object {
    $tmp = [string]$Count
    $IntCode.$tmp = [string]$_
    $Count++
}

Start-IntCode -IntCode $IntCode -Pointer 0 -RelativeBase 0