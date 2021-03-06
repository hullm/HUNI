<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<%
'Created by Matthew Hull on 3/8/16
'Last Updated 1/14/18

'This page displays the sites log

'Option Explicit

On Error Resume Next

Dim strSiteVersion, bolShowLogout, strUser, objReports, strReport, strSubmitTo, strColumns
Dim objLog

'See if the user has the rights to visit this page
If AccessGranted Then
	ProcessSubmissions 
Else
	DenyAccess
End If %>

<%Sub ProcessSubmissions  

	Dim strSQL

	'Check and see if anything was submitted to the site
	Select Case Request.Form("Submit")
	
	End Select
	
	'Get the URL used to submit forms
	If Request.ServerVariables("QUERY_STRING") = "" Then
		strSubmitTo = "log.asp"
	Else   
		strSubmitTo = "log.asp?" & Request.ServerVariables("QUERY_STRING")
	End If
	
	strSQL = "SELECT TOP 100 LGTag,UserName,EventNumber,Type,OldValue,NewValue,UpdatedBy,LogDate,LogTime,OldNotes,NewNotes" & vbCRLF
	strSQL = strSQL & "FROM Log WHERE Active=True AND Deleted=False AND ("
	strSQL = strSQL & "Type <> 'ExternalIPChange' And "
	strSQL = strSQL & "Type <> 'InternalIPChange')"
	strSQL = strSQL & "ORDER BY ID DESC"
	Set objLog = Application("Connection").Execute(strSQL)
	
	'Set up the variables needed for the site then load it
	SetupSite
	DisplaySite
	
End Sub%>

<%Sub DisplaySite %>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html>
	<head>
		<title><%=Application("SiteName")%></title> 
		<link rel="stylesheet" type="text/css" href="../style.css" /> 
		<link rel="apple-touch-icon" href="../images/inventory.png" /> 
		<link rel="shortcut icon" href="../images/inventory.ico" />
		<meta name="viewport" content="width=device-width,user-scalable=0" />
		<meta name="theme-color" content="#333333">
		<link rel="stylesheet" href="../assets/css/jquery-ui.css">
		<script src="../assets/js/jquery.js"></script>
		<script src="../assets/js/jquery-ui.js"></script>
		<link rel="stylesheet" href="../assets/css/jquery.dataTables.min.css">
		<link rel="stylesheet" href="../assets/css/buttons.dataTables.min.css">
		<script src="../assets/js/jquery.dataTables.min.js"></script>
		<script src="../assets/js/dataTables.buttons.min.js"></script>
		<script src="../assets/js/buttons.colVis.min.js"></script>
		<script src="../assets/js/buttons.html5.min.js"></script>
		<script src="../assets/js/jszip.min.js"></script>
		<script type="text/javascript">
			$(document).ready( function () {
			
			<%	If Not IsMobile And Not IsiPad Then%>
					$( document ).tooltip({track: true});
			<%	End If %>
			
				var table = $('#ListView').DataTable( {
					paging: false,
					"info": false,
					"autoWidth": false,
					dom: 'Bfrtip',
					"order": [],
					// stateSave: true,
					buttons: [
						{
							extend: 'colvis',
							text: 'Show/Hide Columns'
						}
				<%	If Not IsMobile Then %>		
						,
						{
							extend: 'csvHtml5',
							text: 'Download CSV',
							title: 'Inventory System Log'
						}
				<%	End If %>
					]
				
				});
		<%	If IsMobile Then %>
				table.columns([1,3,4,5,7,8]).visible(false);	
		<%	Else %>		
				table.columns([5,8]).visible(false);
		<%	End If %>

			} );
		</script>
	</head>
	
	<body class="<%=strSiteVersion%>">
	
		<div class="Header"><%=Application("SiteName")%></div>
		<div>
			<ul class="NavBar" align="center">
				<li><a href="index.asp"><img src="../images/home.png" title="Home" height="32" width="32"/></a></li>
				<li><a href="search.asp"><img src="../images/search.png" title="Search" height="32" width="32"/></a></li>
				<li><a href="stats.asp"><img src="../images/stats.png" title="Stats" height="32" width="32"/></a></li>
				<li><a href="log.asp"><img src="../images/log.png" title="System Log" height="32" width="32"/></a></li>
				<li><a href="add.asp"><img src="../images/add.png" title="Add Person or Device" height="32" width="32"/></a></li>
				<li><a href="login.asp?action=logout"><img src="../images/logout.png" title="Log Out" height="32" width="32"/></a></li>
			</ul>
		</div>
		
	<%	If Not objLog.EOF Then
			ShowLogTable
		End If %>
		
		<div class="Version">Version <%=Application("Version")%></div>
		<div class="CopyRight"><%=Application("Copyright")%></div>
	</body>

	</html>

<%End Sub%>

<%Sub ShowLogTable %>

	<div>
		<br />
		System Log | <a href="purchased.asp">Purchase Log</a>
		<table align="center" Class="ListView" id="ListView">
			<thead>
				<th>Date</th>
				<th>Time</th>
				<th>Type</th>
				<th>Asset Tag</th>
				<th>User</th>
				<th>Event</th>
				<th>Performed By</th>
				<th>New Value</th>
				<th>Old Value</th>
			</thead>		
			<tbody>
	<%	Do Until objLog.EOF %>
				<tr>
					<td id="center"><%=ShortenDate(objLog(7))%></td>
					<td id="center"><%=ShortenTime(objLog(8))%></td>
					<td><%=LogEntryType(objLog(3))%></td>
					<td id="center"><a href="device.asp?Tag=<%=objLog(0)%>"><%=objLog(0)%></a></td>
					<td id="center"><a href="user.asp?UserName=<%=objLog(1)%>"><%=LCase(objLog(1))%></a></td>
				
				<%	If objLog(2) = 0 Then %>
						<td></td>
				<%	Else %>
						<td id="center"><%=objLog(2)%></td>
				<%	End If %>
				
					<td id="center"><%=LCase(objLog(6))%></td>
					
				<%	If InStr(objLog(3),"Notes") = 0 And InStr(objLog(3),"DeviceReturned") = 0 Then %>
						<td><%=objLog(5)%></td>
						<td><%=objLog(4)%></td>
				<%	Else %>
				
					<%	If NOT IsNull(objLog(10)) Then %>
							<td <%=strRowClass%>><%=Replace(objLog(10),vbCRLF,"<br />")%></td>
					<%	Else %>
							<td <%=strRowClass%>><%=objLog(10)%></td>
					<%	End If%>
					
					<%	If NOT IsNull(objLog(9)) Then %>
							<td <%=strRowClass%>><%=Replace(objLog(9),vbCRLF,"<br />")%></td>
					<%	Else %>
							<td <%=strRowClass%>><%=objLog(9)%></td>
					<%	End If%>
				
				<%	End If %>
				
				</tr>
		<%	objLog.MoveNext
		Loop %>
			</tbody>
		</table>
	</div>
	
<%End Sub%>

<%Function LogEntryType(EntryType)

	Select Case EntryType
		Case "AccountDisabledAUP"
			LogEntryType = "Account Disabled - AUP Not Turned In"
		Case "AccountDisabledSchoolTool"
			LogEntryType = "Account Disabled - Student Left District"
		Case "AccountEnabledAUP"
			LogEntryType = "Account Enabled - AUP Turned In"
		Case "AccountEnabledSchoolTool"
			LogEntryType = "Account Enabled - Student Returned To District"
		Case "AUPDisabled"
			LogEntryType = "AUP Not Turned In"
		Case "AUPEnabled"
			LogEntryType = "AUP Turned In"
		Case "AutoLogOut"
			LogEntryType = "Logout"
		Case "CaseFound"
			LogEntryType = "Case Found"
		Case "CasePurchased"
			LogEntryType = "Case Purchased"
		Case "ComputerNameChange"
			LogEntryType = "Computer Name Changed"
		Case "ComputerImaged"
			LogEntryType = "Computer Imaged"
		Case "ComputerPollinated"
			LogEntryType = "Computer Pollinated"
		Case "DatabaseUpgraded"
			LogEntryType = "Database Upgraded"
		Case "DebtForgiven"
			LogEntryType = "Debt Forgiven"
		Case "DeviceAssigned"
			LogEntryType = "Device Assigned"
		Case "DeviceAdded"
			LogEntryType = "New Device Added"
		Case "DeviceDecommissioned"
			LogEntryType = "Device Decommissioned"
		Case "DeviceDisabled"
			LogEntryType = "Device Decommissioned"
		Case "DeviceRestored"
			LogEntryType = "Device Restored to Active Status"
		Case "DeviceReturned"
			LogEntryType = "Device Returned"
		Case "DeviceReturnedAdapterMissing"
			LogEntryType = "Device Returned without Adapter"
		Case "DeviceReturnedCaseMissing"
			LogEntryType = "Device Returned without Case"
		Case "DeviceReturnedDamaged"
			LogEntryType = "Device Returned Damaged"
		Case "DeviceUpdatedAssetTag"
			LogEntryType = "Device Asset Tag Updated"
		Case "DeviceUpdatedBOCESTag"
			LogEntryType = "Device BOCES Tag Updated"
		Case "DeviceUpdatedInsurance"
			LogEntryType = "Insurance Updated"
		Case "DeviceUpdatedMACAddress"
			LogEntryType = "MAC Address Updated"
		Case "DeviceUpdatedMake"
			LogEntryType = "Device Make Updated"
		Case "DeviceUpdatedModel"
			LogEntryType = "Device Model Updated"
		Case "DeviceUpdatedNotes"
			LogEntryType = "Device Notes Updated"
		Case "DeviceUpdatedPurchased"
			LogEntryType = "Device Purchase Date Updated"
		Case "DeviceUpdatedRoom"
			LogEntryType = "Device Room Updated"
		Case "DeviceUpdatedSerial"
			LogEntryType = "Device Serial Number Updated"
		Case "DeviceUpdatedSite"
			LogEntryType = "Device Site Updated"
		Case "DeviceUpdatedTagAdded"
			LogEntryType = "Device Tag Added"
		Case "DeviceUpdatedTagDeleted"
			LogEntryType = "Device Tag Deleted"
		Case "EmailedTeachersAssignment"
			LogEntryType = "EMail Sent about Assignment"
		Case "EventAdded"
			LogEntryType = "Event Added"
		Case "EventClosed"
			LogEntryType = "Event Closed"
		Case "EventDeleted"
			LogEntryType = "Event Deleted"
		Case "EventUpdatedCategory"
			LogEntryType = "Event Category Updated"
		Case "EventUpdatedNotes"
			LogEntryType = "Event Notes Updated"
		Case "EventUpdatedType"
			LogEntryType = "Event Type Updated"
		Case "EventUpdatedWarranty"
			LogEntryType = "Event Warranty Updated"
		Case "ExternalIPChange"
			LogEntryType = "External IP Changed"
		Case "InternalIPChange"
			LogEntryType = "Internal IP Changed"
		Case "ItemPaidFor"
			LogEntryType = "Equipment Paid Off"
		Case "ItemReturned"
			LogEntryType = "Billed Equipment Returned"
		Case "InternetAccessChanged"
			LogEntryType = "Internet Access Changed"
		Case "LastUserChange"
			LogEntryType = "Different User Signed In"
		Case "LoanedItemBilled"
			LogEntryType = "Billed for Loaned Equipment"
		Case "LoanedOutItem"
			LogEntryType = "Equipment Loaned Out"
		Case "LoanedOutItemReturned"
			LogEntryType = "Equipment Returned"
		Case "MoneyOwed"
			LogEntryType = "Billed for Equipment"
		Case "NewADAccountCreated"
			LogEntryType = "Account Created in Active Directory"
		Case "NewStudentDetected"
			LogEntryType = "New Student Detected"
		Case "NewStudentPasswordSet"
			LogEntryType = "Password Entered for New Student"
		Case "NewStudentReady"
			LogEntryType = "New Student Activated"
		Case "NotificationEMailSent"
			LogEntryType = "Notification EMail Sent"
		Case "OSVersionChange"
			LogEntryType = "Operating System Updated"
		Case "PasswordExpiresSet"
			LogEntryType = "Password Expires"
		Case "PasswordNeverExpiresSet"
			LogEntryType = "Password Doesn't Expire"
		Case "PurchasedByUser"
			LogEntryType = "Device Purchased"
		Case "PurchasedByUserDeleted"
			LogEntryType = "Device No Longer Purchased"
		Case "PurchasedDevicePickedUp"
			LogEntryType = "Purchased Device Picked Up"
		Case "ReturnedMissingAdapter"
			LogEntryType = "Returned Missing Adapter"
		Case "ReturnedMissingCase"
			LogEntryType = "Returned Missing Case"
		Case "SearchSaved"
			LogEntryType = "New Search Created"
		Case "StudentGradeChange"
			LogEntryType = "Student Changed Grade"
		Case "UserAdded"
			LogEntryType = "New User Added"
		Case "UserDisabled"
			LogEntryType = "User Disabled"
		Case "UserUpdatedAUP"
			LogEntryType = "User AUP Status Updated"
		Case "UserLogin"
			LogEntryType = "Login"
		Case "UserLoginAdmin"
			LogEntryType = "Admin Login"
		Case "UserLogout"
			LogEntryType = "Logout"
		Case "UserRestored"
			LogEntryType = "User Restored"
		Case "UserUpdatedDescription"
			LogEntryType = "User's Description Updated"
		Case "UserUpdatedFirstName"
			LogEntryType = "User's First Name Updated"
		Case "UserUpdatedLastName"
			LogEntryType = "User's Last Name Updated"
		Case "UserUpdatedNotes"
			LogEntryType = "User's Notes Updated"
		Case "UserUpdatedPassword"
			LogEntryType = "User's Password Updated"
		Case "UserUpdatedPhone"
			LogEntryType = "User's Phone Update"
		Case "UserUpdatedPhotoID"
			LogEntryType = "User's Photo ID Update"
		Case "UserUpdatedRole"
			LogEntryType = "User's Role Update"
		Case "UserUpdatedRoom"
			LogEntryType = "User's Room Update"
		Case "UserUpdatedSite"
			LogEntryType = "User's Site Update"
		Case "UserUpdatedUserName"
			LogEntryType = "User's Username Updated"
		Case Else
			LogEntryType = EntryType
	End Select

End Function%>

<%Function ShortenDate(strDate)
	
	If Not IsNull(strDate) Then
		If strDate <> "" Then
			ShortenDate = Left(strDate,Len(strDate) - 4) & Right(strDate,2)
		End If
	End If

End Function %>

<%Function ShortenTime(strTime)
	
	If Not IsNull(strTime) Then
		If strTime <> "" Then
			ShortenTime = Left(strTime,Len(strTime) - 6) & " " & Right(strTime,2)
		End If
	End If

End Function %>

<%Function GetUserName(UserID)

	Dim strSQL, objUserInfo
	
	If UserID <> "" Then
		
		strSQL = "SELECT UserName FROM People WHERE ID=" & UserID
		Set objUserInfo = Application("Connection").Execute(strSQL)
		
		If Not objUserInfo.EOF Then
			GetUserName = objUserInfo(0)
		Else
			GetUserName = UserID
		End If
	Else
		GetUserName = UserID
	End If

End Function%>

<%Function GetDisplayName(Username)

	Dim strSQL, objUserInfo

	If Username <> "" Then
		
		strSQL = "SELECT FirstName,LastName FROM People WHERE UserName='" & Username & "'"
		Set objUserInfo = Application("Connection").Execute(strSQL)
		
		If Not objUserInfo.EOF Then
			GetDisplayName = objUserInfo(1) & ", " & objUserInfo(0)
		Else
			GetDisplayName = Username
		End If
	Else
		GetDisplayName = Username
	End If

End Function%>

<%
' Anything below here should exist on all pages 
%>

<%Sub DenyAccess 

	'If we're not using basic authentication then send them to the login screen
	If bolShowLogout Then
		Response.Redirect("login.asp?action=logout")
	Else
	
	SetupSite
	
	%>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html>
	<head>
		<title><%=Application("SiteName")%></title>
		<link rel="stylesheet" type="text/css" href="../style.css" /> 
		<link rel="apple-touch-icon" href="../images/inventory.png" /> 
		<link rel="shortcut icon" href="../images/inventory.ico" />
		<meta name="viewport" content="width=device-width" />
	</head>
	<body>
		<center><b>Access Denied</b></center>
	</body>
	</html>
	
<%	End If

End Sub%>

<%Function AccessGranted

	Dim objNetwork, strUserAgent, strSQL, strRole, objNameCheckSet

	'Redirect the user the SSL version if required
	If Application("ForceSSL") Then
		If Request.ServerVariables("SERVER_PORT")=80 Then
			If Request.ServerVariables("QUERY_STRING") = "" Then
				Response.Redirect "https://" & Request.ServerVariables("SERVER_NAME") & Request.ServerVariables("URL")
			Else
				Response.Redirect "https://" & Request.ServerVariables("SERVER_NAME") & Request.ServerVariables("URL") & "?" & Request.ServerVariables("QUERY_STRING")
			End If
		End If
	End If

	'Get the users logon name
	Set objNetwork = CreateObject("WSCRIPT.Network")   
	strUser = objNetwork.UserName
	strUserAgent = Request.ServerVariables("HTTP_USER_AGENT")

	'Check and see if anonymous access is enabled
	If LCase(Left(strUser,4)) = "iusr" Then
		strUser = GetUser
		bolShowLogout = True
	Else
		bolShowLogout = False
	End If

	'Build the SQL string, this will check the userlevel of the user.
	strSQL = "Select Role" & vbCRLF
	strSQL = strSQL & "From Sessions" & vbCRLF
	strSQL = strSQL & "WHERE UserName='" & strUser & "' And SessionID='" & Request.Cookies("SessionID") & "'"
	Set objNameCheckSet = Application("Connection").Execute(strSQL)
	strRole = objNameCheckSet(0)

	If strRole = "Admin" Then
		AccessGranted = True
	Else
		AccessGranted = False
	End If

End Function%>

<%Function GetUser

	Const USERNAME = 1

	Dim strUserAgent, strSessionID, objSessionLookup, strSQL
	
	'Get some needed data
	strSessionID = Request.Cookies("SessionID")
	strUserAgent = Request.ServerVariables("HTTP_USER_AGENT")
	
	'Send them to the logon screen if they don't have a Session ID
	If strSessionID = "" Then
		SendToLogonScreen

	'Get the username from the database
	Else
	
		strSQL = "SELECT ID,UserName,SessionID,IPAddress,UserAgent,ExpirationDate FROM Sessions "
		strSQL = strSQL & "WHERE UserAgent='" & Left(Replace(strUserAgent,"'","''"),250) & "' And SessionID='" & Replace(strSessionID,"'","''") & "'"
		strSQL = strSQL & " And ExpirationDate > Date()"
		Set objSessionLookup = Application("Connection").Execute(strSQL)
		
		'If a session isn't found for then kick them out
		If objSessionLookup.EOF Then
			SendToLogonScreen
		Else
			GetUser = objSessionLookup(USERNAME)
		End If
	End If  
	
End Function%>

<%Function IsMobile

	Dim strUserAgent

	'Get the User Agent from the client so we know what browser they are using
	strUserAgent = Request.ServerVariables("HTTP_USER_AGENT")

	'Check the user agent for signs they are on a mobile browser
	If InStr(strUserAgent,"iPhone") Then
		IsMobile = True
	ElseIf InStr(strUserAgent,"iPad") Then
		IsMobile = True
	ElseIf InStr(strUserAgent,"Android") Then
		IsMobile = True
	ElseIf InStr(strUserAgent,"Windows Phone") Then
		IsMobile = True
	ElseIf InStr(strUserAgent,"BlackBerry") Then
		IsMobile = True
	ElseIf InStr(strUserAgent,"Nintendo") Then
		IsMobile = True 
	ElseIf InStr(strUserAgent,"PlayStation Vita") Then
		IsMobile = True
	Else
		IsMobile = False
	End If 
	
	If InStr(strUserAgent,"Nexus 9") Then  
		IsMobile = False
	End If
End Function %>

<%Function IsiPad

	Dim strUserAgent

	'Get the User Agent from the client so we know what browser they are using
	strUserAgent = Request.ServerVariables("HTTP_USER_AGENT")

	'Check the user agent for signs they are on a mobile browser
	If InStr(strUserAgent,"iPad") Then
		IsiPad = True
	Else
		IsiPad = False
	End If
	
End Function %>

<%Sub SendToLogonScreen

	Dim strReturnLink, strSourcePage
		
	'Build the return link before sending them away.
	strReturnLink =  "?" & Request.ServerVariables("QUERY_STRING")
	strSourcePage = Request.ServerVariables("SCRIPT_NAME")
	strSourcePage = Right(strSourcePage,Len(strSourcePage) - InStrRev(strSourcePage,"/"))
	If strReturnLink = "?" Then
		strReturnLink = "?SourcePage=" & strSourcePage
	Else
		strReturnLink = strReturnLink & "&SourcePage=" & strSourcePage
	End If
	
	Response.Redirect("login.asp" & strReturnLink)
	
End Sub %>

<%Sub SetupSite
	
	If IsMobile Then
		strSiteVersion = "Mobile"
	Else
		strSiteVersion = "Full"
	End If
	
	If Application("MultiColumn") Then
		strColumns = "MultiColumn"
	End If
	
End Sub%>