Get-ADComputer -SearchBase 'difc.root01.org/machines/workstations' -InactiveFor 90 -IncludeAllProperties |
	#sort lastlogontimestamp | Format-Table -Property computername, lastlogontimestamp, osname
	ForEach-Object {
	#Set-QADComputer -Description "inactive for 120 days on $(get-date)" $_
	ping $_
	}
	