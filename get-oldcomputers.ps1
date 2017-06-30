#finding and removing AD computer accounts older than 12 months
import-module activedirectory
$comparedate=get-date
$numberdays=Read-Host "enter the number of days for the account to be older than"
$csvfilelocation='c:\oldcomps.csv'


Get-ADComputer -filter * -Properties lastlogontimestamp | where { ($comparedate-$_.lastlogontimestamp).days -gt $numberdays } | select-object name, lastlogontimestamp | Sort-Object modificationdate, name | Export-Csv $csvfilelocation