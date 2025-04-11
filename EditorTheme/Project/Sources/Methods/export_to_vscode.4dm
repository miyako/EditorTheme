//%attributes = {"invisible":true,"preemptive":"capable"}
var $EditorTheme : cs:C1710.EditorTheme
$EditorTheme:=cs:C1710.EditorTheme.new()

Case of 
	: (True:C214)
		$EditorTheme.exportToVSCode()
	: (False:C215)
		$EditorTheme.exportToVSCode("MyCustomLight")
	: (False:C215)
		$EditorTheme.exportToVSCode("MyCustomLight"; "MyCustomDark")
End case 

//utilities
$lightTheme:=$EditorTheme.currentEditorThemeNameLight()
$darkTheme:=$EditorTheme.currentEditorThemeNameDark()
$currentTheme:=$EditorTheme.currentEditorThemeName()