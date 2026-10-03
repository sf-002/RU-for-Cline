$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)

$jobs = @(
    @{ name = 'WEBVIEW'; file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js' },
    @{ name = 'HOST';    file = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\dist\extension.js' }
)

$kw = '(?i)(cline|task|file|command|browser|context|token|model|server|rule|skill|workflow|checkpoint|diff|image|approv|reject|error|failed|not found|unable|cannot|please|click|select|choose|settings|configure|provider|history|message)'
$bad = '(var\(--|\d+px|codicon|url\(|https?://|^M\d|rgba?\(|--vscode|sha256|^\.[a-z-]|translate|\\u|node_modules|\.js|\.ts|localhost|127\.0\.0\.1)'

foreach ($j in $jobs) {
    $text = [System.IO.File]::ReadAllText($j.file, [System.Text.Encoding]::UTF8)
    $counts = @{}
    foreach ($m in [regex]::Matches($text, '"([^"\\]{12,250})"')) {
        $v = $m.Groups[1].Value
        if ($v -notmatch ' ') { continue }
        if ($v -notmatch '[A-Za-z]{2}') { continue }
        if ($v -notmatch $kw) { continue }
        if ($v -match $bad) { continue }
        if ($v -match '^[a-z0-9 ._-]+$') { continue }
        if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 }
    }
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add(('### ' + $j.name + ' candidate UI sentences: ' + $counts.Count))
    foreach ($e in ($counts.GetEnumerator() | Sort-Object -Property @{Expression='Key';Descending=$false})) {
        $lines.Add(("{0,3}  {1}" -f $e.Value, $e.Key))
    }
    $out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\cand_' + $j.name.ToLower() + '.txt'
    [System.IO.File]::WriteAllLines($out, $lines, $enc)
    Write-Output ("{0}: {1} -> {2}" -f $j.name, $counts.Count, $out)
}
