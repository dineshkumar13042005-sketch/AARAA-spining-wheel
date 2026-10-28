$html = Get-Content "index.html" -Raw
$startTag = "<style>"
$endTag = "</style>"
$startIndex = $html.IndexOf($startTag) + $startTag.Length
$endIndex = $html.IndexOf($endTag)
if ($startIndex -gt 0 -and $endIndex -gt $startIndex) {
    $css = $html.Substring($startIndex, ($endIndex - $startIndex)).Trim()
    $header = "/* Synchronized luxury stylesheet for Aaraa Boutique Spin Wheel */`n`n"
    Set-Content -Path "style.css" -Value ($header + $css) -Encoding UTF8
    Write-Output "Successfully synchronized style.css!"
}
