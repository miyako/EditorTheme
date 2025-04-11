# _EditorTheme

## .currentEditorThemeName()

**.currentEditorThemeName**() : Text

The current active theme name. Takes into account the platform and appearance.

## .exportToVSCode()

**.exportToVSCode**() : cs._EditorTheme  
**.exportToVSCode**($lightTheme : Text) : cs._EditorTheme  
**.exportToVSCode**($lightTheme : Text; $darkTheme : Text) : cs._EditorTheme

Convert and export editor themes to VS Code settings file.

When no themes are specified, the current editor themes are used.

The current theme is applied to the active VS Code theme (`workbench.colorTheme`).

The light and dark themes are applied to `Default Light+` and `Default Dark+`.

## .exportToFile()

**.exportToFile**({$folder : 4D.Folder}) : 4D.File

Export editor themes from `Folder(fk editor theme folder)` in `.zip` format.

Pass the destination folder in `$folder`. `Folder(fk desktop folder)` is used if omitted. the folder is created if it doesn't exist.

A numeric suffix is added if a file already exists in destination.

On success, the `.zip` file is returned.

## .allThemes()

**.allThemes**() : Collection

Theme with `__inheritedFrom__` unresolved. The parent theme might also have inheritance.

## .allThemesExpanded()

**.allThemesExpanded**() : Collection

Theme with `__inheritedFrom__` resolved.
