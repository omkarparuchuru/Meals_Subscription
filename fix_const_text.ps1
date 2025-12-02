# Fix remaining const issues with Theme.of(context)
$files = @(
    "lib\login_page.dart",
    "lib\profile_page.dart"
)

foreach ($filePath in $files) {
    $fullPath = Join-Path "c:\Users\paruc\final_meals" $filePath
    $content = Get-Content $fullPath -Raw
    
    # Remove const from Text widgets that have TextStyle with Theme.of(context)
    $content = $content -replace '(\s+)const Text\(\s*\n\s*([''"].*?[''"])\s*,\s*\n\s*style: TextStyle\(\s*\n(?:.*?\n)*?.*?Theme\.of\(context\)', '$1Text($2, style: TextStyle('
    
    # More specific: Remove const from Text when style contains Theme.of(context)
    $lines = $content -split "`r?`n"
    $newLines = @()
    $inConstText = $false
    $hasThemeInStyle = $false
    $textStartIndex = -1
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check if this line starts a const Text with style
        if ($line -match '^\s*const Text\(') {
            $inConstText = $true
            $textStartIndex = $i
            $hasThemeInStyle = $false
        }
        
        # Check if we're in a const Text and find Theme.of(context)
        if ($inConstText -and $line -match 'Theme\.of\(context\)') {
            $hasThemeInStyle = $true
        }
        
        # Check if we've reached the end of the Text widget
        if ($inConstText -and $line -match '^\s*\),?\s*$') {
            if ($hasThemeInStyle) {
                # Go back and remove const from the Text line
                $newLines[$textStartIndex] = $newLines[$textStartIndex] -replace 'const Text\(', 'Text('
            }
            $inConstText = $false
        }
        
        $newLines += $line
    }
    
    Set-Content -Path $fullPath -Value ($newLines -join "`r`n") -NoNewline
    Write-Host "Fixed: $filePath"
}

Write-Host "Done fixing const Text issues!"
