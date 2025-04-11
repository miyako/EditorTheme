property defaultThemesFolder : 4D:C1709.Folder
property defaultThemes : Collection
property editorThemes : Collection
property themes : Collection
property themeSchema : Object
property VSCodeSettings : Object
property VSCodeSettingsFile : 4D:C1709.File
property preferencesFile : 4D:C1709.File

Class constructor
	
	var $defaultThemesFolder : 4D:C1709.Folder
	
	Case of 
		: (Is macOS:C1572)
			$defaultThemesFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).folder("Contents/Resources/EditorTheme")
		: (Is Windows:C1573)
			$defaultThemesFolder:=File:C1566(Application file:C491; fk platform path:K87:2).parent.folder("Resources/EditorTheme")
	End case 
	
	If ($defaultThemesFolder=Null:C1517) || (Not:C34($defaultThemesFolder.exists))
		//for example, tool4d does not have Folder(fk editor theme folder)
		$defaultThemesFolder:=Folder:C1567("/RESOURCES/EditorTheme")
	End if 
	
	//%W-550.26
	This:C1470._defaultThemesFolder:=$defaultThemesFolder
	This:C1470._themeSchema:=JSON Parse:C1218(File:C1566("/RESOURCES/JSONSchemas/themeSchema.json").getText())
	This:C1470._VSCodeSettingsFile:=Folder:C1567(fk user preferences folder:K87:10).parent.file("Code/User/settings.json")
	//%W+550.26
	
	This:C1470._loadDefaultThemes()._loadEditorThemes()._loadVSCodeSettings()
	
	var $version; $fileName : Text
	$version:=Application version:C493
	$fileName:="4D Preferences v"+Substring:C12($version; 1; 2)+".4DPreferences"
	
	//%W-550.26
	This:C1470._preferencesFile:=Folder:C1567(fk user preferences folder:K87:10).file($fileName)
	//%W+550.26
	
	//MARK: preferences
	
Function currentEditorThemeName() : Text
	
	var $color_scheme_name : Text
	
	var $file : 4D:C1709.File
	$file:=This:C1470.preferencesFile
	
	If ($file.exists)
		var $dom : Text
		$dom:=DOM Parse XML source:C719($file.platformPath)
		If (OK=1)
			$theme:=DOM Find XML element:C864($dom; "/preferences/com.4d/method_editor/theme[@light]")
			If (OK=1)
				DOM GET XML ATTRIBUTE BY NAME:C728($theme; "light"; $color_scheme_name)
			End if 
			If (Is macOS:C1572)
				$general:=DOM Find XML element:C864($dom; "/preferences/com.4d/general[@color_scheme]")
				If (OK=1)
					var $color_scheme : Text
					DOM GET XML ATTRIBUTE BY NAME:C728($general; "color_scheme"; $color_scheme)
					Case of 
						: (Is Windows:C1573)
							$color_scheme:="light"
						: ($color_scheme="inherited")
							$color_scheme:=Get Application color scheme:C1763(*)
					End case 
					If ($color_scheme="inherited")
						$color_scheme:=This:C1470._isSystemDarkMode() ? "dark" : "light"
					End if 
					$theme:=DOM Find XML element:C864($dom; "/preferences/com.4d/method_editor/theme[@"+$color_scheme+"]")
					If (OK=1)
						DOM GET XML ATTRIBUTE BY NAME:C728($theme; $color_scheme; $color_scheme_name)
					End if 
				End if 
			End if 
			DOM CLOSE XML:C722($dom)
		End if 
	End if 
	
	return $color_scheme_name
	
Function _currentEditorThemeName($color_scheme : Text) : Text
	
	var $color_scheme_name : Text
	
	var $file : 4D:C1709.File
	
	$file:=This:C1470.preferencesFile
	
	If ($file.exists)
		var $dom : Text
		$dom:=DOM Parse XML source:C719($file.platformPath)
		If (OK=1)
			$theme:=DOM Find XML element:C864($dom; "/preferences/com.4d/method_editor/theme[@"+$color_scheme+"]")
			If (OK=1)
				DOM GET XML ATTRIBUTE BY NAME:C728($theme; $color_scheme; $color_scheme_name)
			End if 
		End if 
		DOM CLOSE XML:C722($dom)
	End if 
	
	return $color_scheme_name
	
Function currentEditorThemeNameLight() : Text
	
	return This:C1470._currentEditorThemeName("light")
	
Function currentEditorThemeNameDark() : Text
	
	return This:C1470._currentEditorThemeName("dark")
	
	//MARK: preferences subroutines
	
Function _isSystemDarkMode() : Boolean
	
	If (Is Windows:C1573)
		return False:C215
	End if 
	
	$command:="defaults read -g AppleInterfaceStyle"
	var $stdIn; $stdOut; $stdErr : Text
	LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr)
	
	If ($stdOut="")
		return False:C215
	End if 
	
	return True:C214
	
	//MARK: export
	
Function exportToFile($folder : 4D:C1709.Folder) : 4D:C1709.File
	
	If ($folder=Null:C1517) || (Not:C34(OB Instance of:C1731($folder; 4D:C1709.Folder)))
		$folder:=Folder:C1567(fk desktop folder:K87:19)
	End if 
	
	If (Not:C34($folder.exists))
		$folder.create()
	End if 
	
	var $file : 4D:C1709.File
	$file:=This:C1470._newFile($folder; Folder:C1567(fk editor theme folder:K87:23).name; ".zip")
	
	var $zip : Object
	$zip:={\
		files: This:C1470.editorThemes.extract("file"); \
		compression: ZIP Compression standard:K91:1}
	
	var $status : Object
	$status:=ZIP Create archive:C1640($zip; $file)
	
	If ($status.success)
		return $file
	End if 
	
Function exportToVSCode($lightTheme : Text; $darkTheme : Text) : cs:C1710.EditorTheme
	
	$lightTheme:=($lightTheme="") ? This:C1470.currentEditorThemeNameLight() : $lightTheme
	$darkTheme:=($darkTheme="") ? This:C1470.currentEditorThemeNameDark() : $darkTheme
	$currentTheme:=This:C1470.currentEditorThemeName()
	
	var $theme : Object
	var $settings; $node : Object
	$settings:=This:C1470.VSCodeSettings
	
	var $allThemes : Collection
	$allThemes:=This:C1470.allThemesExpanded()
	
	var $colorTheme : Text
	If ($settings#Null:C1517)
		If ($settings["workbench.colorTheme"]#Null:C1517)
			$colorTheme:=$settings["workbench.colorTheme"]
		End if 
		$node:=$settings["editor.semanticTokenColorCustomizations"]
		If ($node=Null:C1517)
			$node:={}
			$settings["editor.semanticTokenColorCustomizations"]:=$node
		End if 
		If ($node#Null:C1517)
			//active theme
			If ($colorTheme#"")
				$theme:=$allThemes.query("name == :1"; $currentTheme).first()
				If ($theme#Null:C1517)
					$node["["+$colorTheme+"]"]:=This:C1470._convertToVSCodeTheme($theme.theme)
				End if 
			End if 
			//light theme
			$theme:=$allThemes.query("name == :1"; $lightTheme).first()
			If ($theme#Null:C1517)
				$node["[Default Light+]"]:=This:C1470._convertToVSCodeTheme($theme.theme)
			End if 
			//dark theme
			$theme:=$allThemes.query("name == :1"; $darkTheme).first()
			If ($theme#Null:C1517)
				$node["[Default Dark+]"]:=This:C1470._convertToVSCodeTheme($theme.theme)
			End if 
			This:C1470.VSCodeSettingsFile.setText(JSON Stringify:C1217($settings; *))
		End if 
	End if 
	
	return This:C1470
	
	//MARK: export subroutines
	
Function _convertToVSCodeTheme($theme : Object) : Object
	
	$map:={}
	$map["*:4d"]:="plain_text"
	$map["method:4d"]:="methods"
	$map["method.defaultLibrary:4d"]:="commands"
	$map["method.plugin:4d"]:="plug_ins"
	$map["property:4d"]:="member"
	$map["function:4d"]:="memberFunc"
	$map["parameter:4d"]:="parameters"
	$map["variable.interprocess:4d"]:="interprocess_variables"
	$map["variable.process:4d"]:="process_variables"
	$map["variable.local:4d"]:="local_variables"
	$map["keyword:4d"]:="keywords"
	$map["table:4d"]:="tables"
	$map["field:4d"]:="fields"
	$map["comment:4d"]:="comments"
	$map["type:4d"]:="commands"
	$map["constant:4d"]:="constants"
	$map["string:4d"]:="plain_text"
	$map["error:4d"]:="errors"
	
	$rules:={}
	
	var $scope : Object
	$scope:=$theme["4D"]
	var $key; $property : Text
	For each ($key; $map)
		$property:=$map[$key]
		$src:=$scope[$property]
		$rules[$key]:={}
		$dst:=$rules[$key]
		If ($src.color#Null:C1517)
			$dst.foreground:=$src.color
		End if 
		$src:=$src.style
		For each ($property; ["bold"; "italic"; "underline"])
			If ($src[$property]#Null:C1517)
				$dst[$property]:=$src[$property]
			End if 
		End for each 
	End for each 
	
	return {enabled: True:C214; rules: $rules}
	
Function _newFile($folder : 4D:C1709.Folder; $name : Text; $extension : Text) : 4D:C1709.File
	
	$file:=$folder.file($name+$extension)
	
	var $i : Integer
	$i:=0
	
	If ($file.exists)
		Repeat 
			$i+=1
			$file:=$folder.file([$name; " "; $i; $extension].join(""))
		Until (Not:C34($file.exists))
	End if 
	
	return $file
	
	//MARK: read only properties
	
Function get preferencesFile : 4D:C1709.File
	
	//%W-550.26
	return This:C1470._preferencesFile
	//%W+550.26
	
Function get VSCodeSettings() : Object
	
	//%W-550.26
	return This:C1470._VSCodeSettings
	//%W+550.26
	
Function get VSCodeSettingsFile() : 4D:C1709.File
	
	//%W-550.26
	return This:C1470._VSCodeSettingsFile
	//%W+550.26
	
Function get defaultThemesFolder() : 4D:C1709.Folder
	
	//%W-550.26
	return This:C1470._defaultThemesFolder
	//%W+550.26
	
Function get themeSchema() : Object
	
	//%W-550.26
	return This:C1470._themeSchema
	//%W+550.26
	
Function get defaultThemes() : Collection
	
	//%W-550.26
	return This:C1470._defaultThemes
	//%W+550.26
	
Function get editorThemes() : Collection
	
	//%W-550.26
	return This:C1470._editorThemes
	//%W+550.26
	
Function get themes() : Collection
	
	//%W-550.26
	return This:C1470._themes
	//%W+550.26
	
Function allThemes() : Collection
	
	//%W-550.26
	return This:C1470.defaultThemes.copy().combine(This:C1470.editorThemes)
	//%W+550.26
	
Function allThemesExpanded() : Collection
	
	//%W-550.26
	return This:C1470.defaultThemes.copy().combine(This:C1470.themes)
	//%W+550.26
	
	//MARK: constructor subroutines
	
Function _getThemes($folder : 4D:C1709.Folder) : Collection
	
	var $theme; $status : Object
	var $themes : Collection
	$themes:=[]
	
	var $files : Collection
	var $file : 4D:C1709.File
	$files:=$folder.files().query("extension == :1"; ".json")
	For each ($file; $files)
		$theme:=JSON Parse:C1218($file.getText(); Is object:K8:27)
		If ($theme#Null:C1517)
			$status:=JSON Validate:C1456($theme; This:C1470.themeSchema)
			If ($status.success)
				$themes.push({name: $file.name; theme: $theme; file: $file})
			End if 
		End if 
	End for each 
	
	return $themes
	
Function _loadDefaultThemes() : cs:C1710.EditorTheme
	
	//%W-550.26
	This:C1470._defaultThemes:=This:C1470._getThemes(This:C1470._defaultThemesFolder)
	//%W+550.26
	
	return This:C1470
	
Function _loadEditorThemes() : cs:C1710.EditorTheme
	
	//%W-550.26
	This:C1470._editorThemes:=This:C1470._getThemes(Folder:C1567(fk editor theme folder:K87:23))
	//%W+550.26
	
	var $theme : Object
	var $themes : Collection
	$themes:=[]
	
	For each ($theme; This:C1470.editorThemes)
		$themes.push({name: $theme.name; theme: This:C1470._expand($theme.theme)})
	End for each 
	
	//%W-550.26
	This:C1470._themes:=$themes
	//%W+550.26
	
	return This:C1470
	
Function _loadVSCodeSettings() : cs:C1710.EditorTheme
	
	var $settings : Object
	
	If (This:C1470.VSCodeSettingsFile.exists)
		$settings:=JSON Parse:C1218(This:C1470.VSCodeSettingsFile.getText(); Is object:K8:27)
	End if 
	
	//%W-550.26
	This:C1470._VSCodeSettings:=$settings
	//%W+550.26
	
	return This:C1470
	
Function _expand($theme : Object) : Object
	
	If ($theme=Null:C1517)
		return 
	End if 
	
	var $allThemes : Collection
	$allThemes:=This:C1470.allThemes()
	
	While ($theme.__inheritedFrom__#Null:C1517)
		var $__inheritedFrom__ : Text
		$__inheritedFrom__:=$theme.__inheritedFrom__
		var $defaultTheme : Object
		$defaultTheme:=$allThemes.query("name == :1"; $__inheritedFrom__).first()
		If ($defaultTheme#Null:C1517)
			$theme:=cs:C1710._Theme.new($theme; $defaultTheme.theme)
		Else 
			break
		End if 
	End while 
	
	return $theme