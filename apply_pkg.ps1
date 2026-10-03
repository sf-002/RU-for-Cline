$ErrorActionPreference = 'Stop'
$dictPath = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\cline_pkg_dict.json'
$outPath  = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\apply_pkg_report.txt'
$cfg  = Get-Content $dictPath -Raw -Encoding UTF8 | ConvertFrom-Json
$file = $cfg.file
$backup = $file + '.bak-ru'
$enc = New-Object System.Text.UTF8Encoding($false)
if (Test-Path $backup) { Copy-Item $backup $file -Force; Write-Output "restored from backup" } else { Copy-Item $file $backup -Force; Write-Output "backup: $backup" }

$text = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
$report = New-Object System.Collections.Generic.List[string]
$total = 0; $missed = New-Object System.Collections.Generic.List[string]

foreach ($p in $cfg.map.PSObject.Properties) {
    $en = $p.Name; $ru = $p.Value; $hits = 0
    foreach ($prop in $cfg.props) {
        foreach ($sep in @('": "', '": "')) {
            $needle = '"' + $prop + $sep + $en + '"'
            $repl   = '"' + $prop + $sep + $ru + '"'
            $c = ([regex]::Matches($text, [regex]::Escape($needle))).Count
            if ($c -gt 0) { $text = $text.Replace($needle, $repl); $hits += $c }
        }
    }
    if ($hits -gt 0) { $total += $hits; $report.Add(("ok   {0,2}  {1}" -f $hits, $en)) }
    else {
        # enumDescriptions: standalone string literal line in an array
        $rxLine = '(?m)^(\s*)"' + [regex]::Escape($en) + '"(,?)$'
        $c = ([regex]::Matches($text, $rxLine)).Count
        $all = ([regex]::Matches($text, [regex]::Escape('"' + $en + '"'))).Count
        if ($c -gt 0 -and $c -eq $all) {
            $text = [regex]::Replace($text, $rxLine, '$1"' + $ru + '"$2')
            $total += $c; $report.Add(("line {0,2}  {1}" -f $c, $en))
        } else { $missed.Add($en) }
    }
}

[System.IO.File]::WriteAllText($file, $text, $enc)

# validate JSON
$check = 'FAIL'
try { $null = Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json; $check = 'JSON VALID' } catch { $check = 'JSON BROKEN: ' + $_.Exception.Message }

$report.Insert(0, ("TOTAL: {0} replacements; {1}; missed: {2}" -f $total, $check, $missed.Count))
$report.Add('')
$report.Add('=== NOT FOUND ===')
foreach ($m in $missed) { $report.Add($m) }
[System.IO.File]::WriteAllLines($outPath, $report, $enc)
Write-Output ("done. total={0} missed={1} check={2}" -f $total, $missed.Count, $check)
