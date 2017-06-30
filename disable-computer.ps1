# Establish AD session as Admin
connect-QADService -credential $cred
$Computer = Read-Host "Enter the host name"
$time = Read-Host "Enter InactiveFor time in days"
# Disabling and moving computer accounts to Disabled Workstation OU
Get-QADComputer $Computer -InactiveFor $time

Read-Host "Ok to continue?"
$x = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Set-QADComputer $Computer -Description "Disabled on $(Get-Date)"
   
# Disable the account
Disable-QADComputer $Computer

# Move the account
Move-QADObject $Computer -NewParentContainer "difc.root01.org/disabled workstations"

"Accounts disabled, moved and password changed"
"Have a nice day"