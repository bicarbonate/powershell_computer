$computers = Get-ADComputer -Properties  OperatingSystem -Filter "OperatingSystem -Like 'Windows 7*'" -erroraction SilentlyContinue  | select -expandproperty Name
#$computers = Get-ADComputer -filter * -searchbase "CN=workstations,CN=machines,dc=difc,dc=root01,dc=org" -erroraction SilentlyContinue | select -expandproperty Name

foreach ($computer in $computers) {


$username = (get-wmiobject Win32_ComputerSystem -computername $computer | select -expandProperty username)
#$descr = $username
set-adcomputer -identity $computer -Description $username

    }
    


