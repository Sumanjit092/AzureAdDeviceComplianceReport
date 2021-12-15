Write-Host "####################################################################################################################"
Write-Host "####################################################################################################################"
Write-Host "###                            AAD Intune Device Compliance Report from a Group                                  ###"
Write-Host "###                                             Version: 1.2                                                     ###"
Write-Host "###                                        Date: 16th December, 2021                                             ###"
Write-Host "###                                        Script by: Sumanjit Pan                                               ###"
Write-Host "####################################################################################################################"
Write-Host "####################################################################################################################"

$ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
''
Write-Host "Checking AzureAd Module..." -ForegroundColor Yellow
                            
    if (Get-Module -ListAvailable | where {$_.Name -like "*AzureAD*"}) 
    {
    Write-Host "AzureAD Module has installed." -ForegroundColor Green
    Import-Module AzureAD
    Write-Host "AzureAD Module has imported." -ForegroundColor Cyan
    ''
    ''
    } else 
    {
    Write-Host "AzureAD Module is not installed." -ForegroundColor Red
    ''
    Write-Host "Installing AzureAD Module....." -ForegroundColor Yellow
    Install-Module AzureAD -Force
                                
    if (Get-Module -ListAvailable | where {$_.Name -like "*AzureAD*"}) {                                
    Write-Host "AzureAD Module has installed." -ForegroundColor Green
    Import-Module AzureAD
    Write-Host "AzureAD Module has imported." -ForegroundColor Cyan
    ''
    ''
    } else
    {
    ''
    ''
    Write-Host "Operation aborted. AzureAD Module was not installed." -ForegroundColor Red
    Exit}
    }

Write-Host "Connecting to AzureAD PowerShell..." -ForegroundColor Magenta
$AzureAd = Connect-AzureAD
Write-Host "User $($AzureAd.Account) has connected to $($AzureAd.TenantDomain) AzureCloud tenant successfully." -ForegroundColor Green

[string] $OrgName = Read-Host -Prompt "Enter Organization Name"
$DataPath = "C:\Temp\$($OrgName)_DeviceReport_Count_$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$Report = @()
# Group Name to Get Device Compliance Report #
[string] $GrpName = Read-Host -Prompt "Enter Security Device Group Name"
$Group = (Get-AzureADGroup -SearchString "$GrpName").ObjectId
$DeviceIds = (Get-AzureADGroupMember -ObjectId $Group -All $true)
Write-Host "Processed Device Information" -ForegroundColor Cyan
Write-Host "Please wait, while we are processing the report" -ForegroundColor Magenta
# Preparing Device Count Report #
$ReportLine = New-Object PSObject -Property @{
OrgName = $OrgName
NumberOfDevice = $DeviceIds.ObjectId.count
Compliant = ($DeviceIds|?{$_.IsCompliant -eq $true}).IsCompliant.count
NonCompliant = ($DeviceIds|?{$_.IsCompliant -eq $false}).IsCompliant.count
NotEnrolled = ($DeviceIds|?{$_.IsCompliant -eq $null}).IsCompliant.count}
$Report += $ReportLine
$Report | Select OrgName, NumberOfDevice, Compliant, NonCompliant, NotEnrolled | Export-Csv -Path $DataPath -NoTypeInformation
Write-Host "Report is Generated & Ready to view" -ForegroundColor Yellow
Write-Host "The Report File available in $DataPath" -ForegroundColor Green

Start-Sleep -Seconds 10
Clear

Write-Host "Please wait while we are processing a detail report of Device Compliance" -ForegroundColor Magenta
$Data_Path = "C:\Temp\$($OrgName)_DeviceComplianceReport_$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$ReportCompliance = @()

$Group = (Get-AzureADGroup -SearchString "$GrpName").ObjectId
$DeviceIds = (Get-AzureADGroupMember -ObjectId $Group -All $true)

$i= 1
ForEach ($DeviceId in $DeviceIds) {
$i++
$Percent = (($i/$DeviceIds.ObjectId.Count)*100)
Write-Progress -Activity "Processing Report for Device: $($DeviceId.DisplayName)" -Status Progress:$($Percent.ToString('#') + "% Complete") -PercentComplete $Percent
$Devices = (Get-AzureADDevice -ObjectId $DeviceId.ObjectId)

ForEach ($Device in $Devices) {
# Preparing Device Compliance Complete Report #
$ReportLineCompliance = New-Object PSObject -Property @{
SecurityGroup = $Group.DisplayName
DeviceName = $Device.DisplayName
DeviceId = $Device.DeviceId
ObjectID =$Device.ObjectID
AccountEnabled = $Device.AccountEnabled
OperatingSystem = $Device.DeviceOSType
OperatingSystemVersion = $Device.DeviceOSVersion
DeviceTrustType = $Device.DeviceTrustType
Compliant = $Device.IsCompliant
DirSyncEnabled = $Device.DirSyncEnabled
LastDirSyncTime = $Device.LastDirSyncTime
RegisteredOwnerName = (Get-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId).DisplayName
RegisteredOwnerUPN = (Get-AzureADDeviceRegisteredOwner -ObjectId $Device.ObjectId).UserPrincipalName}

$ReportCompliance += $ReportLineCompliance }
}

$ReportCompliance | Select DeviceName, DeviceId, ObjectID, AccountEnabled, OperatingSystem, OperatingSystemVersion, DeviceTrustType, Compliant, DirSyncEnabled, LastDirSyncTime, RegisteredOwnerName, RegisteredOwnerUPN|Export-Csv -Path $Data_Path -NoTypeInformation
Write-Host "Report is Generated and ready to view" -ForegroundColor Yellow
Write-Host "The Report File available in $Data_Path" -ForegroundColor Green