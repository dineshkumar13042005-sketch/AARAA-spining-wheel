$out = Join-Path (Get-Location) "assets\live_screenshot.png"
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$userDir = Join-Path (Get-Location) ".temp_chrome_desktop"
if (Test-Path $userDir) {
    Remove-Item -Recurse -Force $userDir -ErrorAction SilentlyContinue
}
$proc = Start-Process -FilePath $chrome -ArgumentList "--headless=new --no-sandbox --disable-gpu --disk-cache-size=0 --disable-cache --user-data-dir=`"$userDir`" --screenshot=`"$out`" --window-size=1280,820 http://localhost:5173" -PassThru -Wait
if (Test-Path $out) {
    Write-Output "Fresh desktop screenshot saved: $((Get-Item $out).Length) bytes"
}
