Import-Module HPEOneView.850
Import-Module HPEiLOCmdlets

$username = "Administrator"
$IP = "xxxx.xxxx.local"

$secpasswd = read-host  "Please enter the OneView password" -AsSecureString
 
$credentials = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)
Connect-OVMgmt -Hostname $IP -Credential $credentials | Out-Null


Clear-Host

#$ServerList = Get-OVServer -name "ILODL380Gen11"

#$ServerList = Get-OVServer | Where-Object ServerName -eq DL380Gen11
$ServerList = Get-OVServer | Where-Object mpModel -EQ "iLO6"

foreach ($Server in $ServerList)
{
    $Server.mpHostInfo.mpHostName
    $Token = $Server | Get-OVIloSso -SkipCertificateCheck -IloRestSession  
    $IloCon = Connect-HPEiLO -XAuthToken $Token.'X-Auth-Token' -Address $Server.mpHostInfo.mpHostName -DisableCertificateAuthentication
    $IloCon | Get-HPEiLOSNMPAlertSetting
    $IloCon | Get-HPEiLOSecurityDashboardInfo

    #Set-HPEiLOSNMPAlertSetting -Connection $IloCon -SNMPv1Enabled Disabled
    #Enable-HPEiLOSecurityDashboardSetting -Connection $IloCon -IgnoreSecureBoot

    if($IloCon -ne $null) {
        Reset-HPEiLO -Connection $IloCon -Device iLO -ResetType GracefulRestart
        # $disconnect = $IloCon | Disconnect-HPEiLO
        # $disconnect | Format-List
    }

    
}


#Clear-Host

write-host ""
Read-Host -Prompt "Operation done ! Hit return to close" 
Disconnect-OVMgmt
