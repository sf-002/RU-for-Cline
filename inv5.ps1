$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv5.txt'

$counts = @{}
$rxArr = [regex]'(?:children|description|title|label|helpText|tooltip)\s*:\s*\[((?:[^\[\]{}]|\{[^{}]{0,200}\}){1,600})\]'
foreach ($m in $rxArr.Matches($t)) {
    foreach ($s in [regex]::Matches($m.Groups[1].Value, '"([^"\\]{3,200})"')) {
        $v = $s.Groups[1].Value
        if ($v -match '[\u0400-\u04FF]') { continue }
        if ($v -match '[\u0590-\u05FF]') { continue }
        if ($v -notmatch '[A-Za-z]{2}') { continue }
        if ($v -match '^[a-z0-9]') { continue }
        if ($v -match '(var\(--|codicon|https?://|\\u|^\s|\s$)') { continue }
        if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 }
    }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add(('english strings inside children/description arrays: ' + $counts.Count))
foreach ($e in ($counts.GetEnumerator() | Sort-Object -Property @{Expression='Key';Descending=$false})) {
    $lines.Add(("{0,3}  {1}" -f $e.Value, $e.Key))
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output ('array strings: ' + $counts.Count)
