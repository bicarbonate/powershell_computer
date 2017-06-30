# Establish AD session as Admin
connect-QADService -credential $cred
#Disabling and moving ALL computer accounts older than X days
#In the MS workstation OU

$time = Read-Host "Enter InactiveFor time in days"
# Disabling and moving computer accounts to Disabled Workstation OU

$Pause = Read-Host "Hit OK to continue.."
#change the searchRoot path to suit your needs
#as well as the NewParentContainer path
Get-QADComputer -SearchRoot 'difc.root01.org/machines/workstations/ms' -Inactivefor $time | 
    ForEach-Object {
		"Disabling $_.dnshostname"
        Set-QADComputer -Description "Disabled on $(Get-Date)" -Identity $_
        Disable-QADComputer -Identity $_
        Move-QADObject -Identity $_ -NewParentContainer "difc.root01.org/disabled workstations"  
    }

"Accounts disabled, moved and password changed"
"Have a nice day"