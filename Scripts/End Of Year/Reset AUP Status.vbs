'Created by Matthew Hull 7/8/16

'On Error Resume Next

'Get the inventory database path
Set objFSO = CreateObject("Scripting.FileSystemObject")
strCurrentFolder = objFSO.GetAbsolutePathName(".")
strCurrentFolder = strCurrentFolder & "\..\..\Database"
strInventoryDatabase = strCurrentFolder & "\Inventory.mdb"

'Create the connection to the inventory database
Set objConnection = CreateObject("ADODB.Connection")
strConnection = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & strInventoryDatabase & ";"
objConnection.Open strConnection

strCurrentYear = Year(Date)

'Disable AUP for High School students
strSQL = "UPDATE People Set AUP=False WHERE ClassOf<=" & strCurrentYear + 6
objConnection.Execute(strSQL)

MsgBox "Done"