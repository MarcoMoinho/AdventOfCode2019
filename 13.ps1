# Day 13
# Same intcode computer as 11
param (
    [Parameter()] [bool] $Animate = $true
)

Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

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

function Get-Input {
    # Play automagically
    if ($Script:BatX -lt $Script:BallX) { return 1 }
    if ($Script:BatX -gt $Script:BallX) { return -1 }
    return 0
}

function Start-IntCode {

    [int]$OpCode = 0
    
    do {
        
        $Mode = "{0:00000}" -f [int](Read-Memory -Pointer $Script:Pointer -Mode 1)
        $OpCode = [int] $Mode.Substring(3,2)

        # Parse all modes 
        $Val1 = @{ Pointer = $Script:Pointer + 1;  Mode = $Mode.Substring(2, 1) }
        $Val2 = @{ Pointer = $Script:Pointer + 2;  Mode = $Mode.Substring(1, 1) }
        $Val3 = @{ Pointer = $Script:Pointer + 3;  Mode = $Mode.Substring(0, 1) }

        # Run the OpCode
        switch ($OpCode) {
            1 { Write-Memory @Val3 -Value ([double](Read-Memory @Val1) + [double](Read-Memory @Val2)) }
            2 { Write-Memory @Val3 -Value ([double](Read-Memory @Val1) * [double](Read-Memory @Val2)) }
            3 { Write-Memory @Val1 -Value (Get-Input) }
            4 { }
            5 { if ([double](Read-Memory @Val1) -gt 0) { $Script:Pointer = [double](Read-Memory @Val2) } else { $Script:Pointer += 3 } }
            6 { if ([double](Read-Memory @Val1) -eq 0) { $Script:Pointer = [double](Read-Memory @Val2) } else { $Script:Pointer += 3 } }
            7 { if ([double](Read-Memory @Val1) -lt [double](Read-Memory @Val2)) { Write-Memory @Val3 -Value "1" } else { Write-Memory @Val3 -Value "0" } }
            8 { if ([double](Read-Memory @Val1) -eq [double](Read-Memory @Val2)) { Write-Memory @Val3 -Value "1" } else { Write-Memory @Val3 -Value "0" } }
            9 { $Script:RelativeBase += [double](Read-Memory @Val1) }
            99 {  }
            Default { throw }
        }

        if ($OpCode -in @(1,2,7,8)) { $Script:Pointer += 4 }
        if ($OpCode -in @(3,4,9))   { $Script:Pointer += 2 }

    } until ($OpCode -in @(4,99))

    if ($OpCode -eq 99) { return $null } else { return Read-Memory @Val1 }
}

function Set-Position {
    param (
        [Parameter(Mandatory)] [string] $Direction
    )

    # Get the new direction
    switch ( $Script:Dir ) {
        "N" { if ($Direction -eq "0") { $Script:Dir = "W" } else { $Script:Dir = "E" } }
        "E" { if ($Direction -eq "0") { $Script:Dir = "N" } else { $Script:Dir = "S" } } 
        "S" { if ($Direction -eq "0") { $Script:Dir = "E" } else { $Script:Dir = "W" } }
        "W" { if ($Direction -eq "0") { $Script:Dir = "S" } else { $Script:Dir = "N" } }
        Default { throw }
    }

    # Move 
    switch ( $Script:Dir ) {
        "N" { $Script:Y += 1 }
        "E" { $Script:X += 1 }
        "S" { $Script:Y -= 1 }
        "W" { $Script:X -= 1 }
        Default { throw }
    }
}

function Set-ConsolePosition {
    param (
        [Parameter(Mandatory)] [int] $X,
        [Parameter(Mandatory)] [int] $Y
    )

    $Position = $Host.ui.rawui.cursorposition
    $Position.x=$X
    $Position.y=$Y
    $Host.ui.rawui.cursorposition=$position
}

# Initialize
$Script:Memory = @{}
$Script:Pointer = 0
$Script:RelativeBase = 0
$Count = 0
((Get-Content .\13.txt) -split ",") | ForEach-Object {
    $tmp = [string]$Count
    $Script:Memory.$tmp = [string]$_
    $Count++
}

$Count = 0
$Instruction = @{}
$Total = 0
if ($Animate) { Clear-Host }
do {
    $Out = Start-IntCode
    if ($null -eq $Out) { break }

    $Instruction.$Count = $Out
    $Count ++

    if ($Count -eq 3) {
        $Count = 0
        if ($Instruction.2 -eq "2") { $Total += 1}
        if (-not $Animate) { continue }

        Set-ConsolePosition -X $Instruction.0 -Y $Instruction.1
        switch ($Instruction.2) {
            0 { Write-Host " " -NoNewline }
            1 { Write-Host "#" -NoNewline }
            2 { Write-Host "+" -NoNewline }
            3 { Write-Host "=" -NoNewline }
            4 { Write-Host "o" -NoNewline }
            Default { throw }
        }
    }

} until ($null -eq $Out)
Write-Host
Write-Host "Part 1: $($Total) block tiles."

# Part 2
# We use the same code 
# Initialize
$Script:Memory = @{}
$Script:Pointer = 0
$Script:RelativeBase = 0
$Count = 0
((Get-Content .\13.txt) -split ",") | ForEach-Object {
    $tmp = [string]$Count
    $Script:Memory.$tmp = [string]$_
    $Count++
}

$Script:Memory."0" = 2 # Set the coins
$Count = 0
$Instruction = @{}
$Score = 0
[int]$Script:BallX = 0
[int]$Script:BatX = 0
if ($Animate) { Clear-Host } else { Write-Host "Playing... (this will take a while)" }
do {
    $Out = Start-IntCode
    if ($null -eq $Out) { break }

    $Instruction.$Count = $Out 

    $Count ++
    if ($Count -eq 3) {
        $Count = 0
        if (($Instruction.0 -eq "-1") -and ($Instruction.1 -eq "0")) {
            # Score Update
            $Score = $Instruction.2
            if (-not $Animate) { continue }
            Set-ConsolePosition -X 60 -Y 6
            Write-Host "Score: $($Instruction.2)" -NoNewline
            
        } else {
            # Screen Update
            if ( $Instruction.2 -eq 4 ) { $BallX = $Instruction.0 }
            if ( $Instruction.2 -eq 3 ) { $BatX = $Instruction.0 }
            if (-not $Animate) { continue }
            Set-ConsolePosition -X $Instruction.0 -Y $Instruction.1
            switch ($Instruction.2) {
                0 { Write-Host " " -NoNewline }
                1 { Write-Host "#" -NoNewline }
                2 { Write-Host "+" -NoNewline }
                3 { Write-Host "=" -NoNewline }
                4 { Write-Host "o" -NoNewline }
                Default { throw }
            }
        } 
    }
    
} until ($null -eq $Out)
write-host ""
Write-Host "Part 2: Score: $($Score)"