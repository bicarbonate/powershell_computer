'set up some varaibles
bDisable = 0							'do you want to disable and move the accounts?
strFileName = "c:\users.txt"					'the file where the tab delimited results are saved

strUserDN = "domaincontroller/OU=All Users, dc=yourdomain, dc=com"  	'initial OU where the users are located
strNewParentDN = "OU=Inactive Users, dc=yourdomain, dc=com"  	'location where disabled users are moved to
strDomain = "yourdomain.com"				'FQDN
iDayThreshold = 180						'number of days without logging in

strOut = ""							'tmp string
strOut2 = ""						'another tmp string
Main()

Sub Main()
'get the initial data then ask some questions
	EnumOUs("LDAP://" & strUserDN)

	'yes=6, no=7, cancel=2
	answer = MsgBox(strOut & vbCrLf & "Disable and move these users?", vbYesNoCancel)
	If answer=2 Then
		Exit Sub
	ElseIf answer=6 Then
		bDisable = 1
		EnumOUs("LDAP://" & strUserDN)
	End If

	answer = MsgBox("Save the data to " & strFileName & "?", vbYesNoCancel)

	If answer = 6 Then
		strOut = "username" & vbTab & "Name" & vbTab & "Last Logon" & vbTab & "Days" & vbCrLf & strOut
		strOut2 = "These users have never logged in:" & vbCRLF _
				& "username" & vbTab & "Name" & vbTab & "Creation Date" & vbCRLF & strOut2
		strOut = strOut & vbCRLF & vbCRLF & strOut2
		SaveToFile strOut
	End If
End Sub

Function EnumOUs(sADsPath)
'recursively finds all of the OU's and users in the given AD path

	Set oContainer = GetObject(sADsPath)
	oContainer.Filter = Array("OrganizationalUnit")
	For Each oOU in oContainer
		EnumUsers(oOU.ADsPath)
		EnumOUs(oOU.ADsPath)
	Next
End Function

Function EnumUsers(sADsPath)
'finds all of the users' last login time

	Set oContainer = GetObject(sADsPath)
	oContainer.Filter = Array("User")
	For Each oADobject in oContainer
		Set objLogon = oADobject.Get("lastLogon")
		intLogonTime = objLogon.HighPart * (2^32) + objLogon.LowPart 
		intLogonTime = intLogonTime / (60 * 10000000)
		intLogonTime = intLogonTime / 1440
		intLogonTime = intLogonTime + #1/1/1601#
		inactiveDays = Fix(Now() - intLogonTime)

		'adds a list of people who have never logged on.
		If intLogonTime = "1/1/1601" Then strOut2 = strOut2 & oADobject.sAMAccountName & vbTab & oADobject.DisplayName & vbTab & oADobject.whencreated & vbCRLF
		
		'if they are beyond the threshhold, it will add them to the output string
		If inactiveDays > iDayThreshold And intLogonTime <> "1/1/1601" Then
			strOut = strOut & oADobject.sAMAccountName _
				& vbTab & oADobject.displayName _
				& vbTab & intNewTime _
				& vbTab & intLogonTime _
				& vbTab & intMaxTime _
				& vbTab & inactiveDays & vbCRLF

			'if disabling was requested, it will move them to a new folder and disable the account
			If bDisable = 1 Then
				If strNewParentDN <> "" Then MoveUser oADobject.Name, oADobject.ADsPath
				Set objUser = GetObject("WinNT://" & strDomain & "/" & oADobject.sAMAccountName)
				objUser.AccountDisabled = True
				objUser.SetInfo
			End If
		End If
	Next
End Function

Sub MoveUser(sName, sPath)
'moves the user from the given OU to a new OU
	Set objUser = GetObject("LDAP://" & strNewParentDN)
	objUser.MoveHere sPath, sName
End Sub

Sub SaveToFile(strData)
'writes the given data to a text file
	Dim objFSO
	Set objFSO = CreateObject("Scripting.FileSystemObject") 
	If objFSO.FileExists(strFileName) Then
		Set objTextStream = objFSO.OpenTextFile(strFileName, 2)
		
		objTextStream.Write strData
		objTextStream.Close
		Set objTextStream = Nothing
	Else
		Set objTextStream = objFSO.CreateTextFile(strFileName, True)		
		objTextStream.Write strData
		objTextStream.Close
		Set objTextStream = Nothing
	End If
End Sub
