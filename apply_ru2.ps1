$ErrorActionPreference = 'Stop'
$dictPath = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\cline_ru_dict.json'
$outPath  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\apply_report2.txt'

$cfg   = Get-Content $dictPath -Raw -Encoding UTF8 | ConvertFrom-Json
$file  = $cfg.file
$backup = $file + '.bak-ru'
$enc = New-Object System.Text.UTF8Encoding($false)

# reset to pristine file from backup
if (Test-Path $backup) { Copy-Item $backup $file -Force }
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$props = @($cfg.props) + @('"aria-label"')
function CountOf([string]$s, [string]$n) { return ([regex]::Matches($s, [regex]::Escape($n))).Count }

$report = New-Object System.Collections.Generic.List[string]
$applied = 0; $manual = New-Object System.Collections.Generic.List[string]; $total = 0

foreach ($p in $cfg.map.PSObject.Properties) {
    $en = $p.Name; $ru = $p.Value; $R1 = 0

    foreach ($prop in $props) {
        $needle = $prop + ':"' + $en + '"'
        $repl   = $prop + ':"' + $ru + '"'
        $c = CountOf $text $needle
        if ($c -gt 0) { $text = $text.Replace($needle, $repl); $R1 += $c }
    }

    $rest = CountOf $text ('"' + $en + '"')
    if ($rest -eq 0) { if ($R1 -gt 0) { $applied++; $total += $R1; $report.Add(("prop {0,3}  {1}" -f $R1, $en)) }; continue }

    # extra safe positions: ="...", ,"...", ["...", :"...", ?"..."
    $extra = @(
        @{ rx = '(?<![=!<>])="'   + [regex]::Escape($en) + '"'; ph = '="' },
        @{ rx = ',"'              + [regex]::Escape($en) + '"'; ph = ',"' },
        @{ rx = '\["'             + [regex]::Escape($en) + '"'; ph = '["' },
        @{ rx = ':"'              + [regex]::Escape($en) + '"'; ph = ':"' },
        @{ rx = '\?"'             + [regex]::Escape($en) + '"'; ph = '?"' }
    )
    $sum = 0
    foreach ($e in $extra) { $sum += ([regex]::Matches($text, $e.rx)).Count }

    if ($sum -eq $rest) {
        foreach ($e in $extra) {
            $text = [regex]::Replace($text, $e.rx, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $e.ph + $ru + '"' })
        }
        $applied++; $total += ($R1 + $rest)
        $report.Add(("expr {0,3} (+prop {1})  {2}" -f $rest, $R1, $en))
    } else {
        $manual.Add(("{0,3} remaining, {1,3} in safe positions  ->  {2}" -f $rest, $sum, $en))
    }
}

# pairs
foreach ($pair in $cfg.pairs) {
    $needle = '?"' + $pair.en[0] + '":"' + $pair.en[1] + '"'
    $repl   = '?"' + $pair.ru[0] + '":"' + $pair.ru[1] + '"'
    $c = CountOf $text $needle
    if ($c -gt 0) { $text = $text.Replace($needle, $repl); $total += $c; $report.Add(("pair {0,3}  {1}" -f $c, $needle)) }
}

# bare message strings, only if every occurrence is a standalone literal
foreach ($b in $cfg.bare.PSObject.Properties) {
    $needle = '"' + $b.Name + '"'
    $repl   = '"' + $b.Value + '"'
    $c = CountOf $text $needle
    if ($c -gt 0) { $text = $text.Replace($needle, $repl); $total += $c; $report.Add(("bare {0,3}  {1}" -f $c, $b.Name)) }
}

[System.IO.File]::WriteAllText($file, $text, $enc)

$summary = "TOTAL replaced: {0} (entries used: {1}/{2})" -f $total, $applied, @($cfg.map.PSObject.Properties).Count
$report.Insert(0, $summary)
$report.Add('')
$report.Add(('=== LEFT IN ENGLISH - needs manual review ({0}) ===' -f $manual.Count))
foreach ($m in $manual) { $report.Add($m) }
[System.IO.File]::WriteAllLines($outPath, $report, $enc)
Write-Output ("done. total={0} applied={1} manualReview={2}" -f $total, $applied, $manual.Count)
