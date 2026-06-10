Write-Host -ForegroundColor Blue "To edit Current User Current Host Profile"
Write-Host "& 'C:\Program Files\Notepad++\notepad++.exe' C:\Users\admgpennings\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

start-transcript C:\ProgramData\PowerShellTranscripts\"$((Get-Date).ToString("yyyyMMdd_HHmmss"))_Log.txt"

function prompt {"PS " + "$(get-date -Format "yy.MM.dd HH:mm")" + " $(get-location)> "}

# $SecurePasswordToFile = Read-Host "Enter Password" -AsSecureString
# HCI password for ADMGPennings
# $SecurePasswordToFile | ConvertFrom-SecureString | Out-File "C:\ProgramData\PowerShellTranscripts\spw.txt"
# RT Password for ADMGPennings
# $SecurePasswordToFile | ConvertFrom-SecureString | Out-File "C:\ProgramData\PowerShellTranscripts\spw2.txt"

$PWord = Get-Content C:\ProgramData\PowerShellTranscripts\spw.txt | ConvertTo-SecureString
$PWord2 = Get-Content C:\ProgramData\PowerShellTranscripts\spw2.txt | ConvertTo-SecureString

$cred = New-Object System.Management.Automation.PSCredential("Huntoil\ADMGpennings", $PWord)
$rtcred = New-Object System.Management.Automation.PSCredential("rt.local\ADMGpennings", $PWord2)
$cred2 = New-Object System.Management.Automation.PSCredential("ADMGpennings@huntoil.com", $PWord) 

#Connect to all the vCenters
if (test-Credential $RTCred) {connect-viServer 10.10.201.33 -Credential $RTCred -Force} else {Write-Host "Bad password for" $RTCred.UserName}
if(test-credential $cred) {Connect-VIServer hcidalvc01.hci.pvt,hcibsvco-vm.hci.pvt,DA7-VC04.int.huntoil.com -Force -cred $cred} else {Write-Host "Bad password for" $cred.UserName}

#Connect to Prism Central
import-Module Nutanix.Cli
connect-PrismCentral -Server prismcentral.huntoil.com -Credential $cred2 -SessionTimeoutSeconds 12000 -ForcedConnection

$env:path = "$env:path;C:\Program Files\OpenSSL\bin"
$env:OPENSSL_CONF = "C:\Program Files\OpenSSL\openssl.cnf"

$13DaysAgo = (get-date).adddays(-13)
$ActiveServers = Get-ADComputer -Filter {(modified -gt $13DaysAgo) -and (operatingsystem -like "*server*") -and (enabled -eq $TRUE)} -properties canonicalname | sort name
$Query = "select Version from Win32_Product where Name like '%Tivoli%'"
