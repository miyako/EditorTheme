//%attributes = {"invisible":true,"preemptive":"capable"}
var $EditorTheme : cs:C1710.EditorTheme
$EditorTheme:=cs:C1710.EditorTheme.new()

$themes:=$EditorTheme.allThemes()
$themes:=$EditorTheme.allThemesExpanded()
$themes.extract("name")

//$EditorTheme.exportToVSCode("defaultTheme"; "defaultDarkTheme")

$EditorTheme.exportToVSCode("a"; "custom_1")