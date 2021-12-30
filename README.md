# Azure-AD-Device-Compliance-Report-from-Single-Or-Multiple-Device-Group #

.\DeviceComplianceReport.ps1 provides the capability to Extract Device Compliance Report from Single or Mutiple Azure AD Device Group.

Mobile Device Management (MDM) solutions like Intune can help protect organizational data by requiring users and devices to meet some requirements. In Intune, this feature is called compliance policies. 

When a device enrolls in Intune it registers in Azure AD. The compliance status for devices is reported to Azure AD. For more information, kindly visit the link: https://docs.microsoft.com/en-us/mem/intune/protect/device-compliance-get-started

As a Administrator, you have created a device group for each region during Intune Deployment. You would like to track device compliance Status and Enrollment progress for each region device. 

.\DeviceComplianceReport.ps1 will provide you the capabity to export device compliance report and enrollment progress report.

Run Powershell as Elevated User.
To run the PowerShell window with elevated permissions just click Start then type PowerShell then Right-Click on PowerShell icon and select Run as Administrator.

.\DeviceComplianceReport.ps1 will check for AzureAD Module. If module is not installed it will Install module.

.\DeviceComplianceReport.ps1 will prompt you to enter your AzureAD Tenant credentials.

After successful login, .\DeviceComplianceReport.ps1 will ask you Enter your Organization Name.

.\DeviceComplianceReport.ps1 will ask you Enter Device Group Name. If you have opt for report from Csv file, it will ask you to upload a Csv file contains Device Group. (Prepare a .Csv file like the Sample File)

.\DeviceComplianceReport.ps1 will Export two .Csv Report under "C:\Temp\" Folder.

One Report contains Compliant, Non-Complaint and Not-Enroll Device Count and another report contains complete device report.

Important Notes:
This source code is freeware and is provided on an "as is" basis without warranties of any kind, whether express or implied, including without limitation warranties that the code is free of defect, fit for a particular purpose or non-infringing. The entire risk as to the quality and performance of the code is with the end user.

If you have any question, suggestion or issue with this script please feel free to leave comments.

