$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$f = 'c:\Users\User\.vscode\extensions\saoudrizwan.claude-dev-4.1.20\next\webview-ui\build\assets\index.js'
$t = [System.IO.File]::ReadAllText($f, [System.Text.Encoding]::UTF8)
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv4.txt'

$noise = '(?i)(aws|region|apac|sovereign|gpt|claude|gemini|qwen|llama|mistral|deepseek|kimi|glm|grok|gemma|seed\d|doubao|minimax|nano banana|solar|nova |magistral|devstral|codestral|voxtral|abliterated|sakana|trinity|mimo|laguna|mercury|step \d|ling \d|fugu|inkling|muse |arcee|kwaikat|perplexity|z\.ai|kilo|shape|node |edge |subgraph|diagram|flowchart|sequence|entity|arrow|dasharray|grammar|lexer|parser|abnf|ebnf|peg |railroad|wardley|treemap|unexpected|katex|latex|render display|macro expansion|iso |utf|regex|ipv4|ipv6|uuid|guid|ksuid|nanoid|ulid|cuid|oracle|arcmap|deployed models|privacy filter|flux|gliner|elevenlabs|toponym|abnf|conllu|latex)'

$counts = @{}
foreach ($m in [regex]::Matches($t, '"([^"\\]{10,220})"')) {
    $v = $m.Groups[1].Value
    if ($v -notmatch '[\u0400-\u04FF]' -eq $false) { continue }   # skip cyrillic (already russian)
    if ($v -match '[\u0400-\u04FF]') { continue }
    if ($v -notmatch ' ') { continue }
    if (($v -split '\s+').Count -lt 3) { continue }
    if ($v -match '[={}()<>\\/_`|$\[\]#*;~@^%&+]') { continue }
    if ($v -match '^\d') { continue }
    if ($v -match $noise) { continue }
    if ($v -match '^\s|\s$') { continue }
    if ($counts.ContainsKey($v)) { $counts[$v]++ } else { $counts[$v] = 1 }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add(('prose-like remaining English strings: ' + $counts.Count))
foreach ($e in ($counts.GetEnumerator() | Sort-Object -Property @{Expression='Key';Descending=$false})) {
    $lines.Add(("{0,3}  {1}" -f $e.Value, $e.Key))
}
[System.IO.File]::WriteAllLines($out, $lines, $enc)
Write-Output ('prose-like: ' + $counts.Count)
