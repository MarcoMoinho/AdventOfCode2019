# Day 16

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Input = (Get-Content .\16.txt).ToCharArray() 

$Values = @()
foreach ($Val in $Input) {
    $Values += [int]$Val.ToString() # Convert to int
}

function Get-Pattern { 
    param (
        [Parameter(Mandatory)] [int] $Line,
        [Parameter(Mandatory)] [int] $Len
    )

    $BasePattern = @(0, 1, 0, -1)

    $Pattern = @()
    $Indx = 0
    $Count = 0
    for ($L = 0; $L -lt $Len; $L++) {
        $Count++
        if ($Count -ge $Line) { $Indx++; $Count = 0 }
        if ($Indx -ge $BasePattern.Count) { $Indx = 0 }
        $Pattern += [int]$BasePattern[$Indx]
    }

    return $Pattern 
}

# Part 1
for ($Phase = 1; $Phase -le 100; $Phase++) {
    $Result = @()
    for ($Line = 1; $Line -le $Values.Count; $Line++) {

        $Pattern = Get-Pattern -Line $Line -Len $Values.Count

        $tmp = 0
        for ($i = 0; $i -lt $Values.Count; $i++) {
            $tmp += ( $Values[$i] * $Pattern[$i] )
        }
        $Result += [int]$tmp.ToString().Substring($tmp.ToString().Length -1,1) # Last char
    }
    $Values = $Result
    Write-Host $Phase
}
($Values -join "").Substring(0,8)

# Part 2
$Input = (Get-Content .\16.txt).ToCharArray() 
$Values = @()
foreach ($Val in $Input) {
    $Values += [int]$Val.ToString() # Convert to int
}
$Values = $Values * 10000 # 10.000 times the values

# Get the offset
$Offset = @()
for ($i = 0; $i -lt 7; $i++) { $Offset += $Values[$i] }
$Offset = [int]($Offset -join "")
$Offset
