Class constructor($theme : Object; $superTheme : Object)
	
	If ($theme=Null:C1517)
		$theme:={}
	End if 
	
	If ($superTheme=Null:C1517)
		$superTheme:={}
	End if 
	
	This:C1470.__inheritedFrom__:=$superTheme.__inheritedFrom__
	
	This:C1470["4D"]:={}
	This:C1470.SQL:={}
	This:C1470.JSON:={}
	This:C1470.otherStyles:={}
	
	var $fontName : Text
	var $fontSize; $fontStyle : Integer
	GET STYLE SHEET INFO:C1256(Automatic style sheet:K14:12; $fontName; $fontSize; $fontStyle)
	
	This:C1470.fontName:=$fontName
	This:C1470.fontSize:=$fontSize
	
	var $property : Text
	For each ($property; ["fontName"; "fontSize"])
		If ($theme[$property]#Null:C1517)
			This:C1470[$property]:=$theme[$property]
			continue
		End if 
		If ($superTheme[$property]#Null:C1517)
			This:C1470[$property]:=$superTheme[$property]
			continue
		End if 
	End for each 
	
	If (This:C1470.fontName="default_font")
		This:C1470.fontName:=$fontName
	End if 
	
	$properties:=\
		["back_color"; \
		"cursor_line_back_color"; \
		"cursor_line_color"; \
		"execution_line_back_color"; \
		"execution_line_frame_color"; \
		"hilite_back_color"; \
		"hilite_block_back_color"; \
		"matching_parenthesis_color"; \
		"protected_color"; \
		"same_word_back_color"; \
		"suggestion_color"; \
		"selection_back_color"]
	
	This:C1470._setup("otherStyles"; $properties; $theme; $superTheme)
	
	$properties:=[\
		"commands"; \
		"comments"; \
		"constants"; \
		"entity_member"; \
		"errors"; \
		"fields"; \
		"indexed-fields"; \
		"interprocess_variables"; \
		"keywords"; \
		"local_variables"; \
		"member"; \
		"memberFunc"; \
		"methods"; \
		"parameters"; \
		"plain_text"; \
		"plug_ins"; \
		"process_variables"; \
		"tables"; \
		"thread-safe-commands"; \
		"thread-safe-methods"]
	
	This:C1470._setup("4D"; $properties; $theme; $superTheme)
	
	$properties:=[\
		"comparisons"; \
		"debug"; \
		"function_keywords"; \
		"keywords"; \
		"names"; \
		"normal"; \
		"numbers"; \
		"strings"]
	
	This:C1470._setup("SQL"; $properties; $theme; $superTheme)
	
	$properties:=["errors"; \
		"escapeSequences"; \
		"identifiers"; \
		"keywords"; \
		"normal"; \
		"numbers"; \
		"strings"]
	
	This:C1470._setup("JSON"; $properties; $theme; $superTheme)
	
Function _setup($scope : Text; $properties : Collection; $theme : Object; $superTheme : Object)
	
	var $target; $source; $superSource : Object
	
	$target:=This:C1470[$scope]
	$source:=$theme[$scope]
	$superSource:=$superTheme[$scope]
	
	var $property : Text
	For each ($property; $properties)
		If ($source[$property]#Null:C1517)
			$target[$property]:=$source[$property]
			continue
		End if 
		If ($superSource[$property]#Null:C1517)
			$target[$property]:=$superSource[$property]
			continue
		End if 
		Case of 
			: ($scope="otherStyles")
				//$target[$property]:={color: "#000000"}
			Else 
				//$target[$property]:={color: "#000000"; style: {bold: False; italic: False; underline: False}}
		End case 
/*
the following properties seems to be on the cutting floor
4D:indexed-fields,thread-safe-commands,thread-safe-methods
otherStyles:protected_color
*/
	End for each 