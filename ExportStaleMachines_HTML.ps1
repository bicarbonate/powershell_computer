Import-Module ActiveDirectory
$layout = "<style>"
$layout = $layout + "BODY{background-color:White;}"
$layout = $layout + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$layout = $layout + "TH{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:LightGrey}"
$layout = $layout + "TD{border-width: 1px;padding: 5px;border-style: solid;border-color: black;background-color:ForalWhite}"
$layout = $layout + "</style>"
$d = [DateTime]::Today.AddDays(-90)  
$stale = Get-ADComputer -Filter  'lastlogon -le $d' -SearchBase "OU=Machines,DC=difc,DC=root01,DC=org" -properties lastlogon
$liststale = $stale | Sort Name | ConvertTo-HTML -Head $layout Name, DistinguishedName, LastLogon -Body "<H2>The Following Machines Have Not Contacted the Domain in the Past 90 Days:</H2>"
$countstale = $stale | group-object computer | ConvertTo-HTML -Head $layout Count -Body "<H2>Total Stale Machine Count</H2>" 
                
  $messageParameters = @{                        
                Subject = "Stale Computer Report from $env:ComputerName.$env:USERDNSDOMAIN - $((Get-Date).ToShortDateString())"                    
                Body = $countstale, $liststale |
                Out-String                    
                From = "StaleMachines@unifiedbrands.net"                        
                To = "bhart@unifiedbrands.net"                        
                SmtpServer = "smtp.dovercorporation.com"                        
            }                        
            Send-MailMessage @messageParameters -BodyAsHtml 