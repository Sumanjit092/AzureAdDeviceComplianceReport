<#
 
.SYNOPSIS:
    AzureAD Device Compliance Report PowerShell script. Applicable for Single or multiple Device Secuirty Group. 
    Script input requires a .Csv Files. Sample File is available in the Media Folder.

.Description:
    DeviceComplianceReport.ps1 is a PowerShell script find AzureAD Device information from Security Group and analyse them. 
    Generates Dashboard and Complete device compliance report in Csv Format.

.AUTHOR:
    Sumanjit Pan

.Version:
    1.2 

.Date: 
    26th December, 2021

.First Publish Date:
    10th October, 2021

#>

Function CheckAzureAd{
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
}

Cls
'===================================================================================================='
Write-Host '                               Azure AD Devices Compliance Report                                    ' -ForegroundColor Green 
'===================================================================================================='
''                    
Write-Host "                                          IMPORTANT NOTES                                           " -ForegroundColor red 
Write-Host "===================================================================================================="
Write-Host "This source code is freeware and is provided on an 'as is' basis without warranties of any kind," -ForegroundColor yellow 
Write-Host "whether express or implied, including without limitation warranties that the code is free of defect," -ForegroundColor yellow 
Write-Host "fit for a particular purpose or non-infringing. The entire risk as to the quality and performance of" -ForegroundColor yellow 
Write-Host "the code is with the end user." -ForegroundColor yellow 
''
Write-Host "Mobile Device Management (MDM) solutions like Intune can help protect organizational data by requiring" -ForegroundColor yellow 
Write-Host "users and devices to meet some requirements. In Intune, this feature is called compliance policies. " -ForegroundColor yellow 
''
Write-Host "When a device enrolls in Intune it registers in Azure AD. The compliance status for devices is " -ForegroundColor yellow 
Write-Host "reported to Azure AD. " -ForegroundColor yellow
''
Write-Host "For more information, kindly visit the link:" -ForegroundColor yellow 
Write-Host "https://docs.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started" -ForegroundColor yellow 

"===================================================================================================="
''
CheckAzureAd

''
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
[string] $OrgName = Read-Host -Prompt "Enter Organization Name"
''
$DataPath = "C:\Temp\$($OrgName)_DeviceReport_Count_$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$Report = @()

Write-Host "Please upload your Csv file" -ForegroundColor Cyan
''
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'Csv Files (*.Csv)|*.Csv'
}
$Loop = $true
    while($Loop)
    {
        if ($FileBrowser.ShowDialog() -eq "OK")
        {
        $loop = $false
        } else
        {
$Res = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again?", "Status" , 4, 64)
If($Res -eq "No"){
Exit}
  }
}

$Path = $FileBrowser.FileNames
$Mode = [System.Windows.Forms.MessageBox]::Show("We are proceeding with File Path: $($Path)" , "Status" , 4, 64)
If ($Mode -eq "Yes"){
Write-Host "Importing Information from File $($Path)" -ForegroundColor Green
$Groups = Import-Csv -Path $Path
     }
If ($Mode -eq "No"){
Exit
}
''
Write-Host "Please wait while we are processing report" -ForegroundColor Magenta
$i=1
ForEach ($Group in $Groups) {
$i++
$Percent = (($i/$Groups.ObjectId.Count)*100)
Write-Progress -Activity "Processing Report for Device Group: $($Group.GroupName)" -Status Progress:$($Percent.ToString('#') + "% Complete") -PercentComplete $Percent
$DeviceIds = (Get-AzureADGroupMember -ObjectId $Group.ObjectId -All $true)
$ReportLine = New-Object PSObject -Property @{
OrgName = $Group.OpCoName
SecurityGroup = $Group.GroupName
NumberOfDevice = $DeviceIds.ObjectId.count
Compliant = ($DeviceIds|?{$_.IsCompliant -eq $true}).IsCompliant.count
NonCompliant = ($DeviceIds|?{$_.IsCompliant -eq $false}).IsCompliant.count
NotEnrolled = ($DeviceIds|?{$_.IsCompliant -eq $null}).IsCompliant.count}
$Report += $ReportLine
}
$Report | Select OrgName, SecurityGroup, NumberOfDevice, Compliant, NonCompliant, NotEnrolled | Export-Csv -Path $DataPath -NoTypeInformation
''
Write-Host "Report is Generated and ready to view" -ForegroundColor Yellow
Write-Host "The Report File available in $DataPath" -ForegroundColor Green
''

Start-Sleep -Seconds 10

''
Write-Host "Please wait while we are processing a detail report" -ForegroundColor Magenta
''
$Data_Path = "C:\Temp\$($OrgName)_DeviceComplianceReport_$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).csv"
$ReportCompliance = @()

$i=1
ForEach ($Group in $Groups) {
$i++
$Percent = (($i/$Groups.ObjectId.Count)*100)
Write-Progress -Activity "Processing Report for Device Group: $($Group.GroupName)" -Status Progress:$($Percent.ToString('#') + "% Complete") -PercentComplete $Percent
$DeviceIds = (Get-AzureADGroupMember -ObjectId $Group.ObjectId -All $true)

$j=1
ForEach ($DeviceId in $DeviceIds) {
$j++
$Percentage = (($j/$DeviceIds.ObjectId.Count)*100)
Write-Progress -Id 1 -Activity "Processing Report for Device: $($DeviceId.DisplayName)" -Status Progress:$($Percentage.ToString('#') + "% Complete") -PercentComplete $Percentage
$Devices = (Get-AzureADDevice -ObjectId $DeviceId.ObjectId)

ForEach ($Device in $Devices) {
# Preparing Device Compliance Deatail Report #
$ReportLineCompliance = New-Object PSObject -Property @{
OrgName = $Group.OpCoName
SecurityGroup = $Group.GroupName
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
}

$ReportCompliance | Select OrgName, SecurityGroup, DeviceName, DeviceId, ObjectID, AccountEnabled, OperatingSystem, OperatingSystemVersion, DeviceTrustType, Compliant, DirSyncEnabled, LastDirSyncTime, RegisteredOwnerName, RegisteredOwnerUPN|Export-Csv -Path $Data_Path -NoTypeInformation
''
Write-Host "Report is Generated and ready to view" -ForegroundColor Yellow
Write-Host "The Report File available in $Data_Path" -ForegroundColor Green
''
Write-Host "Script completed successfully." -ForegroundColor Cyan
''
Exit