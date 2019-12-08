# Day 7
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

# A lot of this code is from Day 5
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

function Start-IntCode {
    param ( 
        [Parameter(Mandatory)] [int] $PhaseSetting,
        [Parameter(Mandatory)] [int] $InputSignal,
        [Parameter(Mandatory)] [int] $AmpID,
        [Parameter(Mandatory)] [bool] $Reset
    )

    if ($Reset) { 
        $Script:IntCode = (Get-Content .\07.txt) -split ","
        [int]$Pointer = 0
    } else { 
        $Script:IntCode = $Script:Softw.$AmpID
        [int]$Pointer = $Script:Pointers.$AmpID 
    }
    
    [int]$OpCode = 0
    
    do {
        
        $Mode = "{0:00000}" -f ([int]$Script:IntCode[$Pointer])
        $OpCode = [int] $mode.Substring(3,2)

        # Get the values depending on the Mode
        if ($OpCode -in @(1,2,5,6,7,8)) {
            if ( $Mode.Substring(2,1) -eq "0" ) { $ValA = $Script:IntCode[$Script:IntCode[$Pointer + 1]] } else { $ValA = $Script:IntCode[$Pointer + 1] } 
            if ( $Mode.Substring(1,1) -eq "0" ) { $ValB = $Script:IntCode[$Script:IntCode[$Pointer + 2]] } else { $ValB = $Script:IntCode[$Pointer + 2] }
            if ( $OpCode -in @(1,2,7,8) ) {
                if ( $Mode.Substring(0,1) -eq "0" ) { $ValC = $Script:IntCode[$Pointer + 3] } else { $ValC = $Pointer + 3 }
            }
        }
        if ( $OpCode -in @(3,4) ) {
            if ( $Mode.Substring(2,1) -eq "0" ) { $ValA = $Script:IntCode[$Pointer + 1] } else { $ValA = $Pointer + 1 }
        }

        if ( $OpCode -eq 3 ) {
            if ($PhaseSetting -ge 0) {
                $ValX = $PhaseSetting
                $PhaseSetting = -1
            } else {
                $ValX = $InputSignal
            }
        }

        # Run the OpCode
        switch ($OpCode) {
            1 { Invoke-Function -Type "+" -ValA $ValA -ValB $ValB -Address $ValC }
            2 { Invoke-Function -Type "*" -ValA $ValA -ValB $ValB -Address $ValC }
            3 { Invoke-Memory -Write $true -Value $ValX -Address $ValA }
            4 { return (Invoke-Memory -Write $false -Address $ValA) }
            5 { if ([int]$ValA -gt 0) { $Pointer = $ValB } else { $Pointer += 3 } }
            6 { if ([int]$ValA -eq 0) { $Pointer = $ValB } else { $Pointer += 3 } }
            7 { if ([int]$ValA -lt [int]$ValB) { Invoke-Memory -Write $true -Value "1" -Address $ValC } else { Invoke-Memory -Write $true -Value "0" -Address $ValC } }
            8 { if ([int]$ValA -eq [int]$ValB) { Invoke-Memory -Write $true -Value "1" -Address $ValC } else { Invoke-Memory -Write $true -Value "0" -Address $ValC } }
            99 { return $null }
            Default { throw }
        }

        if ($OpCode -in @(1,2,7,8)) { $Pointer += 4 }
        if ($OpCode -in @(3,4))     { $Pointer += 2 }

        if (-not $Reset) { 
            $Script:Softw.$AmpID = $Script:IntCode 
            $Script:Pointers.$AmpID = $Pointer
        } # Store for later
    } until ($OpCode -eq 99)

    return $null
}

function Get-Permutations {
    param ( 
        [Parameter(Mandatory)] [string] $Value
    )

    $Result = @()
    if ($Value.length -gt 2) {
        # Loop through all the characters
        foreach ($Char in $Value.ToCharArray()) {
            $tmp = $Value -replace $Char, ""
            foreach ($Permutation in (Get-Permutations -Value $tmp)) {
                $Result += $Char + $Permutation
            }
        } 
    } else {
        $Result += $Value.Substring(0,1) + $Value.Substring(1,1) 
        $Result += $Value.Substring(1,1) + $Value.Substring(0,1)
    }
    return $Result
}


# Part 1
$Script:IntCode = $null
$Permutations = Get-Permutations -Value "01234"
[int]$Max = 0
foreach ($Value in $Permutations) {
    [int]$Signal = 0
    for ($Phase = 0; $Phase -lt 5; $Phase++) { 
        $Signal = Start-IntCode -PhaseSetting $Value.Substring($Phase,1) -InputSignal $Signal -Reset $true -AmpID 0 
    }
    if ($Signal -gt $Max) { $Max = $Signal }
}
Write-Output "Part1: $($Max)"


# Part 2
$Script:IntCode = $null
$Script:Softw = @{}
$Script:Pointers = @{}
$Permutations = Get-Permutations -Value "56789"


[int]$Max = 0
foreach ($Value in $Permutations) {

    # Initialize the 5 Amps
    for ($AmpID = 0; $AmpID -lt 5; $AmpID++) { 
        $Script:Softw.$AmpID = (Get-Content .\07.txt) -split "," 
        $Script:Pointers.$AmpID = 0
    }

    # First run with Phase Settings
    [int]$Signal = 0
    for ($Phase = 0; $Phase -lt 5; $Phase++) { 
        $Signal = Start-IntCode -PhaseSetting $Value.Substring($Phase,1) -InputSignal $Signal -Reset $false -AmpID $Phase
    }

    # Run until halts
    do {
        for ($AmpID = 0; $AmpID -lt 5; $AmpID++) { 
            $Signal = Start-IntCode -PhaseSetting -1 -InputSignal $Signal -Reset $false -AmpID $AmpID 
            if ($Signal -lt 1) { break }
            $Script:Pointers[$AmpID] += 2 # Because I didn't store it before. Hackjob.
        }
        if ($Signal -gt $Max) { $Max = $Signal }
    } until ($Signal -lt 1)

}

Write-Output "Part2: $($Max)"