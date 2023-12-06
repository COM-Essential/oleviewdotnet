﻿function Get-ClassNames {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    $x = [System.IO.Path]::GetExtension($Path)
    if ($x -eq ".ps1xml") {
        $xml = [xml](Get-Content $Path)
        $xml.SelectNodes("//TypeName").InnerText
    } else {
        $re = [regex]::new("\[(OleViewDotNet\.[a-zA-Z0-9.]+)\]")
        $ss = Get-Content $Path
        foreach($s in $ss) {
            $m = $re.Match($s)
            if ($m.Success -and $m.Groups.Count -gt 1) {
                $m.Groups[1].Value
            }
        }
    }
}

function Find-MissingTypes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path,
        [switch]$Sorted
    )

    PROCESS {
        Write-Host $Path
        $ns = Get-ClassNames $Path
        if ($Sorted) {
            $ns = $ns | Sort-Object -Unique
        }

        $asm = [OleViewDotNet.EntryPoint].Assembly
        
        foreach($n in $ns) {
            $t = $asm.GetType($n)
        
            if ($t -eq $null) {
                Write-Host "$n missing."
            }
        }
    }
}