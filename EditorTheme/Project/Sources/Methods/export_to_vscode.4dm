//%attributes = {"invisible":true,"preemptive":"capable"}
var $EditorTheme : cs:C1710.EditorTheme
$EditorTheme:=cs:C1710.EditorTheme.new()

$names:=$EditorTheme.allThemes().extract("name")

//$EditorTheme.exportToVSCode("defaultTheme"; "defaultDarkTheme")
$EditorTheme.exportToVSCode("custom"; "custom_1")