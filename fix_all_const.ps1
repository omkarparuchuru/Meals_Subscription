# Comprehensive fix for all const issues with Theme.of(context)
$files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Fix const BorderSide with Theme.of(context)
    $content = $content -replace 'const BorderSide\(\s*\n\s*color:\s*Theme\.of\(context\)', 'BorderSide(color: Theme.of(context)'
    $content = $content -replace 'side:\s*const BorderSide\(\s*\n\s*color:\s*Theme\.of\(context\)', 'side: BorderSide(color: Theme.of(context)'
    
    # Fix const EdgeInsets with Theme.of(context) nearby
    $content = $content -replace 'padding:\s*const EdgeInsets\.([a-zA-Z]+)\(([^)]+)\),\s*\n\s*\),\s*\n\s*\),\s*\n(?:[^}]*Theme\.of\(context\))', 'padding: EdgeInsets.$1($2)),'
    
    # Fix any remaining const with Theme.of(context) in same block
    # Remove const from Decoration, TextStyle, Icon, etc. that have Theme.of(context)
    $lines = $content -split "`r?`n"
    $newLines = @()
    $bracketDepth = 0
    $constLineIndex = -1
    $hasTheme = $false
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Track if we start a const declaration
        if ($line -match '^\s*(const\s+(BorderSide|EdgeInsets|TextStyle|Icon|BoxDecoration|LinearGradient|Text|Padding|SizedBox|Container))\(') {
            $constLineIndex = $i
            $bracketDepth = 1
            $hasTheme = $false
        }
        elseif ($constLineIndex -ge 0) {
            # Count brackets to know when the const block ends
            $openBrackets = ($line.ToCharArray() | Where-Object { $_ -eq '(' }).Count
            $closeBrackets = ($line.ToCharArray() | Where-Object { $_ -eq ')' }).Count
            $bracketDepth += $openBrackets - $closeBrackets
            
            # Check if this line has Theme.of(context)
            if ($line -match 'Theme\.of\(context\)') {
                $hasTheme = $true
            }
            
            # If we've closed all brackets and found Theme.of(context), remove const
            if ($bracketDepth -le 0 -and $hasTheme) {
                $newLines[$constLineIndex] = $newLines[$constLineIndex] -replace '\bconst\s+', ''
                $constLineIndex = -1
            }
            elseif ($bracketDepth -le 0) {
                $constLineIndex = -1
            }
        }
        
        $newLines += $line
    }
    
    $content = $newLines -join "`r`n"
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Done!"
