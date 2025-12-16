# Read the AHK file
$fileContent = Get-Content -Path "d:\Github\KMCounter\KMCounter.ahk"

# Find the LoadControlList function and extract all Hwnd values
$inFunction = $false
$hwndList = @()
$lineNumber = 0

foreach ($line in $fileContent) {
    $lineNumber++
    
    # Check if we're entering the LoadControlList function
    if ($line -match "^LoadControlList") {
        $inFunction = $true
        continue
    }
    
    # Check if we're exiting the LoadControlList function
    if ($inFunction -and $line -match "^\s*return,\s*list") {
        $inFunction = $false
        break
    }
    
    # If we're inside the function, extract Hwnd values
    if ($inFunction) {
        if ($line -match 'Hwnd:\s*"([^"]+)"') {
            $hwnd = $matches[1]
            $hwndList += @{
                Hwnd = $hwnd
                Line = $lineNumber
            }
        }
    }
}

# Find duplicates
$duplicates = $hwndList | Group-Object -Property Hwnd | Where-Object { $_.Count -gt 1 }

if ($duplicates.Count -gt 0) {
    Write-Host "Duplicate Hwnd values found:"
    foreach ($dup in $duplicates) {
        Write-Host "Hwnd: $($dup.Name)"
        foreach ($item in $dup.Group) {
            Write-Host "  Line $($item.Line)"
        }
    }
} else {
    Write-Host "No duplicate Hwnd values found."
}

# Also check for sc1 specifically since that's the one causing the error
$sc1Entries = $hwndList | Where-Object { $_.Hwnd -eq "sc1" }
if ($sc1Entries.Count -gt 0) {
    Write-Host "\nsc1 entries found:"
    foreach ($entry in $sc1Entries) {
        Write-Host "  Line $($entry.Line)"
    }
}
