$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$hb = [System.IO.File]::ReadAllText('c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\dist\extension.js', [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\host_probe.txt'
$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('host length: ' + $hb.Length)

$phrases = @('wants to', 'Cline read', 'Cline is', 'would you like', 'The user', 'please', 'Failed to', 'Unable to', 'not allowed', 'Auto-approve', 'auto-approve', 'task', 'Checkpoint', 'API Request')
foreach ($p in $phrases) {
    $c = ([regex]::Matches($hb, [regex]::Escape($p), 'IgnoreCase')).Count
    $lines.Add(("{0,6}  {1}" -f $c, $p))
}

$lines.Add('')
$lines.Add('=== strings with "wants to" or starting with Cline (first 40) ===')
$i = 0
foreach ($m in [regex]::Matches($hb, '"([^"\\]{15,200})"')) {
    $v = $m.Groups[1].Value
    if ($v -notmatch '(?i)(wants to|cline |would you like|do you want)') { continue }
    if ($v -match '(var\(--|https?://|codicon|\d+px|\\u)') { continue }
    $i++
    if ($i -le 40) { $lines.Add('  ' + $v) }
}
$lines.Add(("total such strings: {0}" -f $i))

$lines.Add('')
$lines.Add('=== provider metadata: name:"..." / description:"..." (first 60) ===')
$i = 0
foreach ($m in [regex]::Matches($hb, '(?:name|description)\s*:\s*"([^"\\]{3,160})"')) {
    $v = $m.Groups[1].Value
    if ($v -match '(var\(--|https?://|codicon|\d+px|^[a-z0-9_.:-]+$)') { continue }
    $i++
    if ($i -le 60) { $lines.Add('  ' + $v) }
}
$lines.Add(("total such strings: {0}" -f $i))

[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output "written $out"
