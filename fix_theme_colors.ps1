# Fix theme colors script
$files = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Remove const from BoxDecoration that contains Theme.of(context)
    if ($content -match 'const BoxDecoration\([^)]*Theme\.of\(context\)') {
        $content = $content -replace '(\s+)decoration: const BoxDecoration\(', '$1decoration: BoxDecoration('
        $modified = $true
    }
    
    # Remove const from LinearGradient that contains Theme.of(context)
    if ($content -match 'const LinearGradient\([^)]*Theme\.of\(context\)') {
        $content = $content -replace 'gradient: const LinearGradient\(', 'gradient: LinearGradient('
        $modified = $true
    }
    
    # Remove const from Icon that contains Theme.of(context)
    if ($content -match 'const Icon\([^)]*Theme\.of\(context\)') {
        $content = $content -replace 'const Icon\(([^,]+),\s*color:\s*Theme\.of\(context\)', 'Icon($1, color: Theme.of(context)'
        $modified = $true
    }
    
    # Remove const from TextStyle that contains Theme.of(context)
    if ($content -match 'const TextStyle\([^)]*Theme\.of\(context\)') {
        $content = $content -replace 'style: const TextStyle\(', 'style: TextStyle('
        $modified = $true
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Done!"
