$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$base = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859'
$dicts = @("$base\cline_ru_dict.json", "$base\cline_ru_dict2.json", "$base\cline_ru_dict3.json", "$base\cline_ru_dict4.json")
$outPath = "$base\apply_report3.txt"

$file = (Get-Content $dicts[0] -Raw -Encoding UTF8 | ConvertFrom-Json).file
$backup = $file + '.bak-ru'
if (Test-Path $backup) { Copy-Item $backup $file -Force } else { Copy-Item $file $backup -Force }
$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

function CountOf([string]$s, [string]$n) { return ([regex]::Matches($s, [regex]::Escape($n))).Count }

$report = New-Object System.Collections.Generic.List[string]
$grand = 0; $manualAll = New-Object System.Collections.Generic.List[string]

foreach ($dp in $dicts) {
    $cfg = Get-Content $dp -Raw -Encoding UTF8 | ConvertFrom-Json
    $props = @($cfg.props) + @('"aria-label"')
    $tag = [System.IO.Path]::GetFileName($dp)
    $applied = 0; $sub = 0

    if ($cfg.regex) {
        foreach ($r in $cfg.regex) {
            $c = ([regex]::Matches($text, $r.find)).Count
            if ($c -gt 0) { $text = [regex]::Replace($text, $r.find, $r.repl); $sub += $c; $report.Add(("regex {0,3}  {1}" -f $c, $r.find)) }
        }
    }

    if ($cfg.raw) {
        foreach ($r in $cfg.raw) {
            $c = CountOf $text $r.find
            if ($c -gt 0) { $text = $text.Replace($r.find, $r.repl); $sub += $c; $report.Add(("raw  {0,3}  {1}" -f $c, $r.find)) }
        }
    }

    foreach ($p in $cfg.map.PSObject.Properties) {
        $en = $p.Name; $ru = $p.Value; $R1 = 0
        foreach ($prop in $props) {
            $needle = $prop + ':"' + $en + '"'
            $repl   = $prop + ':"' + $ru + '"'
            $c = CountOf $text $needle
            if ($c -gt 0) { $text = $text.Replace($needle, $repl); $R1 += $c }
        }
        $rest = CountOf $text ('"' + $en + '"')
        if ($rest -eq 0) { if ($R1 -gt 0) { $applied++; $sub += $R1 } ; continue }

        $extra = @(
            @{ rx = '(?<![=!<>])="' + [regex]::Escape($en) + '"'; ph = '="' },
            @{ rx = ',"'            + [regex]::Escape($en) + '"'; ph = ',"' },
            @{ rx = '\["'           + [regex]::Escape($en) + '"'; ph = '["' },
            @{ rx = ':"'            + [regex]::Escape($en) + '"'; ph = ':"' },
            @{ rx = '\?"'           + [regex]::Escape($en) + '"'; ph = '?"' }
        )
        $sum = 0
        foreach ($e in $extra) { $sum += ([regex]::Matches($text, $e.rx)).Count }
        if ($sum -eq $rest) {
            foreach ($e in $extra) {
                $text = [regex]::Replace($text, $e.rx, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $e.ph + $ru + '"' })
            }
            $applied++; $sub += ($R1 + $rest)
        } else {
            $manualAll.Add(("$tag  |  {0} left, {1} safe  |  {2}" -f $rest, $sum, $en))
        }
    }
    $report.Add(("### {0}: replaced {1}, entries used {2}" -f $tag, $sub, $applied))
    $grand += $sub
}

# pairs and bare literals (per dict file, order preserved)
foreach ($dp in $dicts) {
    $cfg = Get-Content $dp -Raw -Encoding UTF8 | ConvertFrom-Json
    $tag = [System.IO.Path]::GetFileName($dp)
    if ($cfg.pairs) {
        foreach ($pair in $cfg.pairs) {
            $needle = '?"' + $pair.en[0] + '":"' + $pair.en[1] + '"'
            $repl   = '?"' + $pair.ru[0] + '":"' + $pair.ru[1] + '"'
            $c = CountOf $text $needle
            if ($c -gt 0) { $text = $text.Replace($needle, $repl); $grand += $c; $report.Add(("pair {0,3}  {1}" -f $c, $needle)) }
        }
    }
    if ($cfg.bare) {
        foreach ($b in $cfg.bare.PSObject.Properties) {
            $needle = '"' + $b.Name + '"'
            $repl   = '"' + $b.Value + '"'
            $c = CountOf $text $needle
            if ($c -gt 0) { $text = $text.Replace($needle, $repl); $grand += $c; $report.Add(("bare {0,3}  {1}" -f $c, $b.Name)) }
            else { $manualAll.Add("$tag  |  BARE not found  |  " + $b.Name) }
        }
    }
}

[System.IO.File]::WriteAllText($file, $text, $enc)
$report.Insert(0, ("GRAND TOTAL: {0}   file: {1}" -f $grand, $file))
$report.Add('')
$report.Add(('=== LEFT IN ENGLISH ({0}) ===' -f $manualAll.Count))
foreach ($m in $manualAll) { $report.Add($m) }
[System.IO.File]::WriteAllLines($outPath, $report, $enc)
Write-Output ("done. total={0} manual={1}" -f $grand, $manualAll.Count)
