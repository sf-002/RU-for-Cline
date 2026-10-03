$ErrorActionPreference = 'Stop'
$dictPath = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\cline_ru_dict.json'
$outPath  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\apply_report.txt'

$cfg  = Get-Content $dictPath -Raw -Encoding UTF8 | ConvertFrom-Json
$file = $cfg.file
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$backup = $file + '.bak-ru'
if (-not (Test-Path $backup)) {
    Copy-Item $file $backup -Force
    Write-Output "backup created: $backup"
}

$report = New-Object System.Collections.Generic.List[string]
$total = 0; $entries = 0; $missed = New-Object System.Collections.Generic.List[string]

foreach ($p in $cfg.map.PSObject.Properties) {
    $en = $p.Name; $ru = $p.Value
    $hits = 0
    foreach ($prop in $cfg.props) {
        $needle = $prop + ':"' + $en + '"'
        $repl   = $prop + ':"' + $ru + '"'
        $c = ([regex]::Matches($text, [regex]::Escape($needle))).Count
        if ($c -gt 0) { $text = $text.Replace($needle, $repl); $hits += $c }
    }
    if ($hits -gt 0) { $entries++; $total += $hits; $report.Add(("ok   {0,3}  {1}  ->  {2}" -f $hits, $en, $ru)) }
    else { $missed.Add($en) }
}

foreach ($pair in $cfg.pairs) {
    $needle = '?"' + $pair.en[0] + '":"' + $pair.en[1] + '"'
    $repl   = '?"' + $pair.ru[0] + '":"' + $pair.ru[1] + '"'
    $c = ([regex]::Matches($text, [regex]::Escape($needle))).Count
    if ($c -gt 0) { $text = $text.Replace($needle, $repl); $total += $c; $report.Add(("pair {0,3}  {1} -> {2}" -f $c, $needle, $repl)) }
    else { $missed.Add('PAIR ' + $needle) }
}

foreach ($b in $cfg.bare.PSObject.Properties) {
    $needle = '"' + $b.Name + '"'
    $repl   = '"' + $b.Value + '"'
    $c = ([regex]::Matches($text, [regex]::Escape($needle))).Count
    if ($c -gt 0) { $text = $text.Replace($needle, $repl); $total += $c; $report.Add(("bare {0,3}  {1}" -f $c, $b.Name)) }
    else { $missed.Add('BARE ' + $b.Name) }
}

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($file, $text, $enc)
$report.Insert(0, ("TOTAL replacements: {0} in {1} dictionary entries" -f $total, $entries))
$report.Insert(1, ("file: {0}  size now: {1} MB" -f $file, [math]::Round((Get-Item $file).Length / 1MB, 2)))
$report.Add('')
$report.Add(('=== NOT FOUND ({0}) ===' -f $missed.Count))
foreach ($m in $missed) { $report.Add($m) }
[System.IO.File]::WriteAllLines($outPath, $report, $enc)
Write-Output ("done. total={0} entries={1} notFound={2}" -f $total, $entries, $missed.Count)
