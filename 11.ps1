# Day 11
# Same intcode computer
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
            3 { Write-Memory @Val1 -Value (Get-CurrentColor) }
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

function Get-CurrentColor {
    $XY = "{0},{1}" -f $Script:X, $Script:Y
    if ($Script:Area -contains $XY) { return 1 } else { return 0 } 
}

function Set-CurrentColor {
    param (
        [Parameter(Mandatory)] [string] $Color
    )

    $XY = "{0},{1}" -f $Script:X, $Script:Y
    if ($Script:Unique -notcontains $XY) { $Script:Unique += $XY }
    $Indx = $Script:Area.IndexOf($XY)
    switch ($Color) {
        "0" { if ($Indx -ge 0) { $Script:Area[$Indx] = "" } } 
        "1" { if ($Indx -lt 0) { $Script:Area += $XY }  }
        Default { throw }
    }
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
((Get-Content .\11.txt) -split ",") | ForEach-Object {
    $tmp = [string]$Count
    $Script:Memory.$tmp = [string]$_
    $Count++
}

# Area to draw
$Script:Area = @()
$Script:Unique = @()

# Current Position
[int]$Script:X = 0
[int]$Script:Y = 0
$Script:Dir = "N"

$Paint = $true # first move is always paint
do {
    $Out = Start-IntCode
    if ($null -eq $Out) { break }

    if ($Paint) { Set-CurrentColor -Color $Out }
    if (-not $Paint) { Set-Position -Direction $Out } 

    $Paint = (-not $Paint)
} until ($null -eq $Out)

Clear-Host
Write-Host "Part 1: Unique Painted: $($Script:Unique.Count)"


# Redo the same thing for part 2
$Script:Memory = @{}
$Script:Pointer = 0
$Script:RelativeBase = 0
$Count = 0
((Get-Content .\11.txt) -split ",") | ForEach-Object {
    $tmp = [string]$Count
    $Script:Memory.$tmp = [string]$_
    $Count++
}

# Area to draw
$Script:Area = @()
$Script:Area += "0,0" # Part 2 starts white
$Script:Unique = @()

# Current Position
[int]$Script:X = 0
[int]$Script:Y = 0
$Script:Dir = "N"

$Paint = $true # first move is always paint
do {
    $Out = Start-IntCode
    if ($null -eq $Out) { break }

    if ($Paint) { Set-CurrentColor -Color $Out }
    if (-not $Paint) { Set-Position -Direction $Out } 

    $Paint = (-not $Paint)
} until ($null -eq $Out)

foreach ($Pos in $Script:Area) { 
    if ($Pos -eq "") { continue }
    $XY = $Pos -split "," 
    Set-ConsolePosition -X ([math]::Abs($XY[0])) -Y ([math]::Abs($XY[1]) + 3 ) # Offset so we see the previous result
    Write-Host "#" -NoNewline
}
Write-Host ""