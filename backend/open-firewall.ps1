# Run as Administrator (right-click PowerShell -> Run as administrator)
# Allows phones on your Wi-Fi to reach the backend on port 3000

Write-Host "Adding Windows Firewall rule for port 3000..."

netsh advfirewall firewall delete rule name="Cake Shop API 3000" 2>$null
netsh advfirewall firewall add rule name="Cake Shop API 3000" dir=in action=allow protocol=TCP localport=3000

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Port 3000 is now open for incoming connections."
    Write-Host "Test on phone browser: http://10.227.25.27:3000/health"
} else {
    Write-Host "FAILED: Run this script as Administrator."
}
