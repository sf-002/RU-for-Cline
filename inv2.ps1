$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv2.txt'

$props = 'children|title|aria-label|placeholder|label|shortName|description|tooltip|tooltipText|headerText|primaryText|secondaryText|helpText|name|buttonText|emptyText|notFoundText|searchPlaceholder|confirmText|"aria-label"'
$rx = [regex]('(?:[{,\s])?' + '(?:' + $props + ')\s*:\s*"([^"\\]{2,250})"')
$bad = '(var\(--|\d+px|codicon|url\(|https?://|^M\d|rgba?\(|--vscode|sha256|^\.[a-z-]|translate\(|\\u|^[a-z][a-z0-9 _.-]{0,40}$)'

$counts = @{}
foreach ($m in $rx.Matches($t)) {
    $v = $m.Groups[1].Value
    if ($v -notmatch '[A-Za-z]{2}') { continue }      # must have latin letters
    if ($v -match '[\u0400-\u04FF]') { continue }     # skip already-translated (cyrillic)
    if ($v -match $bad) { continue }
    if ($v -match '^\s|\s$') { continue }
    if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add(('unique remaining English display strings: ' + $counts.Count))
foreach ($e in ($counts.GetEnumerator() | Sort-Object -Property @{Expression='Key';Descending=$false})) {
    $lines.Add(("{0,3}  {1}" -f $e.Value, $e.Key))
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output ("unique: {0} -> {1}" -f $counts.Count, $out)
