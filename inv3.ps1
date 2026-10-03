$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)
$src = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv2.txt'
$out = 'c:\Users\User\.trae\work\6ab428af56852fb50bf60859\inv3.txt'

$noise = '(?i)(aws|region|apac|sovereign|us iso|iso east|iso west|\d+px|gpt-?\d|claude|gemini|qwen|llama|mistral|deepseek|kimi|glm|grok|gemma|seed\b|doubao|minimax|nano banana|solar|nova |command |magistral|devstral|codestral|voxtral|abliterated|sakana|trinity|mimo|laguna|mercury|step \d|ling \d|^hy|fugu|inkling|muse |arcee|kwaikat|writer|perplexity|z\.ai|kilo|shape|node\b|edge\b|subgraph|diagram|flowchart|sequence diagram|entity|rect\b|circle\b|arrow|marker|dasharray|grammar|token\b|lexer|parser|abnf|ebnf|peg\b|railroad|wardley|treemap|pie\b|xy\b|architecture|\bAPI\b$|json|xml|yaml|utf|csv|regex|http|ipv|uuid|guid|ksuid|nanoid|ulid|cuid)'

$lines = Get-Content $src -Encoding UTF8 | Where-Object { $_ -match '^\s*\d+\s{2}' }
$keep = New-Object System.Collections.Generic.List[string]
foreach ($l in $lines) {
    $v = ($l -replace '^\s*\d+\s\s', '')
    if ($v -match $noise) { continue }
    if ($v -notmatch ' ') { continue }
    if ($v.Length -lt 4) { continue }
    $keep.Add($l)
}
$head = 'filtered UI-ish strings: ' + $keep.Count
[System.IO.File]::WriteAllLines($out, (@($head) + $keep), $enc)
Write-Output $head
