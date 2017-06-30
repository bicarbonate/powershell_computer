#Set-ADComputerDescription.ps1
#
# Ben Hart 6/8/2015
#
#Script sets teh Description attribute in AD to the currently logged on user's name to help associate computer objects to it's user
#
#
Import-Module ActiveDirectory

$computer = $env:computername
$username = $env:USERNAME
set-adcomputer $computer -description $username

