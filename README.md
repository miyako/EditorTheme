![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/EditorTheme)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/EditorTheme/total)

# EditorTheme
Convert 4D editor theme to 3rd party code editor theme

## usage

```4d
var $EditorTheme : cs.EditorTheme
$EditorTheme:=cs.EditorTheme.new()
$EditorTheme.exportToVSCode("MyCustomLightTheme"; "MyCustomDarkTheme")
```

## remarks

there exists an undocumented constant for `4D.Folder`: 

```4d
Folder(fk editor theme folder)
```

there are some unsused? language properties 

for `4D`

* indexed-fields
* thread-safe-commands
* thread-safe-methods

for `otherStyles`

* protected_color
