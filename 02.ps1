# Day 2
Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

function Invoke-Sum {
    param ( 
        [Parameter(Mandatory)] [int] $ParamA,
        [Parameter(Mandatory)] [int] $ParamB,
        [Parameter(Mandatory)] [int] $Address
    )

    $Script:IntCode[$Address] = [int]$Script:IntCode[$ParamA] + [int]$Script:IntCode[$ParamB]
}

function Invoke-Multiply {
    param ( 
        [Parameter(Mandatory)] [int] $ParamA,
        [Parameter(Mandatory)] [int] $ParamB,
        [Parameter(Mandatory)] [int] $Address
    )

    $Script:IntCode[$Address] = [int]$Script:IntCode[$ParamA] * [int]$Script:IntCode[$ParamB]
}

function Start-IntCode {
    param (
        [Parameter(Mandatory)] [int] $ParamA,
        [Parameter(Mandatory)] [int] $ParamB
    )

    $Script:IntCode[1] = $ParamA
    $Script:IntCode[2] = $ParamB
    $Pointer = 0

    do {
        $OpCode = $Script:IntCode[$Pointer]
        switch ($OpCode) {
            1 { Invoke-Sum      -ParamA $Script:IntCode[$Pointer + 1] -ParamB $Script:IntCode[$Pointer + 2] -Address $Script:IntCode[$Pointer + 3] }
            2 { Invoke-Multiply -ParamA $Script:IntCode[$Pointer + 1] -ParamB $Script:IntCode[$Pointer + 2] -Address $Script:IntCode[$Pointer + 3] }
            99 {  }
            Default { throw }
        }
        $Pointer += 4
    } until ($OpCode -eq 99)

    return $Script:IntCode[0]
}

# Part 1
$Script:IntCode = (Get-Content .\02.txt) -split ","
Write-Output "Part 1:" (Start-IntCode -ParamA 12 -ParamB 2)

# Part 2
# Bruteforcing our way through
$ParamA = -1
$ParamB = 0
do {
    
    
    $ParamA += 1
    if ($ParamA -gt 99) {
        $ParamA = 0
        $ParamB += 1
        Write-Progress -Activity "Processing Part 2" -Status "Searching $($ParamB)/99" -PercentComplete $ParamB
    }

    $Script:IntCode = (Get-Content .\02.txt) -split ","
    $Output = Start-IntCode -ParamA $ParamA -ParamB $ParamB

    
} until ($Output -eq 19690720)

Write-Output "Part 2:" ($ParamA *100 + $ParamB)