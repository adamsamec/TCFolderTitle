; =============================================================================
; Displays the names of the currently opened folders in Total Commander window title.
; =============================================================================
; Requires AutoHotkey v2.0+
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; =============================================================================
; CONFIGURATION
; =============================================================================
global Config := {
  TCClass: "TTOTAL_CMD", ; Total Commander window class
  CheckInterval: 200, ; Check every this number of milliseconds for folder changes
  FolderSeparator: " | ", ; Separator between current left and right panel folders
  SuffixSeparator: " - ", ; Separator between panel folders and suffix
  Suffix: "Total commander", ; Text appended after folders
  NetworkSuffix: " [net]", ; Text appended after network folders, e.g. FTP
  ShowFullPath: false, ; true = full path, false = folder name only
  ShowBothPanels: true ; Show both panel folders or just left
}

; Store last known paths per window to detect changes (Map: hwnd => {left, right})
global LastPaths := Map()

; =============================================================================
; SETUP
; =============================================================================
SetTimer(UpdateTCTitle, Config.CheckInterval)

; =============================================================================
; MAIN UPDATE FUNCTION - Updates only the active Total Commander window
; =============================================================================
UpdateTCTitle() {
  global LastPaths

  ; Check if the active window is a Total Commander window
  if !WinActive("ahk_class " Config.TCClass)
    return

  ; WinSetTitle("test")

  ; Get the active TC window handle
  hwnd := WinGetID("A")

  ; Get paths from both panels using ControlGetText
  leftPath := GetPanelPath(hwnd, "left")
  rightPath := GetPanelPath(hwnd, "right")

  ; Get last known paths for this window
  hwndKey := String(hwnd)

  lastLeft := ""
  lastRight := ""
  if LastPaths.Has(hwndKey) {
    lastLeft := LastPaths[hwndKey].left
    lastRight := LastPaths[hwndKey].right
  }

  ; Build the new title
  newTitle := BuildFolderTitle(leftPath, rightPath)

  ; Check if paths changed for this window
  if (leftPath != lastLeft || rightPath != lastRight) {
    ; Store new paths
    LastPaths[hwndKey] := { left: leftPath, right: rightPath }
  } else if (WinGetTitle(hwnd) = newTitle) {
    ; Don't change title if it hasn't changed
    return
  }

  ; Change the window title
  if (newTitle != "") {
    WinSetTitle(newTitle, hwnd)
  }
}

; =============================================================================
; Retrieves the panel path controls in the given window
; =============================================================================
GetPanelPath(hwnd, panel) {
  path := ""
  if (panel = "left") {
path := GetPanelPathFromControls(hwnd, "TPathPanel1", "Window10", "Window11")
  } else if (panel = "right") {
path := GetPanelPathFromControls(hwnd, "TPathPanel2", "Window15", "Window16")
  }
  return path
}

; =============================================================================
; Retrieves the panel path using the given controls in the given window
; =============================================================================
GetPanelPathFromControls(hwnd, control32, control64local, control64net) {
  path := ""
      try {
      path := ControlGetText(control32, hwnd)
  path := CleanPath(path)
    } catch {
      try {
        path := ControlGetText(control64local, hwnd)
  path := CleanPath(path)
        if !IsDrivePath(path)
          path := ControlGetText(control64net, hwnd)
  path := CleanPath(path)
      }
    }
    return path
}

; =============================================================================
; CLEAN PATH - Remove TC-specific prefixes/suffixes
; =============================================================================
CleanPath(path) {
  if (path = "")
    return ""

  ; Remove common TC prefixes both from start and end, like ">", "*", "[", "]"
  path := RegExReplace(path, "^[\s>\*\[\]]+", "")
  path := RegExReplace(path, "(\*\.\*)|([\s>\*\[\]]+)$", "")

  ; Trim whitespace
  path := Trim(path)

  return path
}

; =============================================================================
; Determines if the given path is a drive path
; =============================================================================
IsDrivePath(path) {
  return RegExMatch(path, "^[A-Za-z]:")
  ; return SubStr(path, -1) = "/"
}

; =============================================================================
; BUILD TITLE FROM PATHS
; =============================================================================
BuildFolderTitle(leftPath, rightPath) {
  leftName := GetDisplayName(leftPath)
  if !IsDrivePath(leftPath)
    leftName := leftName Config.NetworkSuffix

  rightName := GetDisplayName(rightPath)
  if !IsDrivePath(rightPath)
    rightName := rightName Config.NetworkSuffix

  if Config.ShowBothPanels {
    if (leftName != "" && rightName != "")
      title := leftName Config.FolderSeparator rightName
    else if (leftName != "")
      title := leftName
    else if (rightName != "")
      title := rightName
    else
      title := Config.Suffix
  } else {
    ; Show only left (source) panel
    if (leftName != "")
      title := leftName
    else
      return Config.Suffix
  }

  return title Config.SuffixSeparator Config.Suffix
}

GetDisplayName(path) {
  if (path = "")
    return ""

  ; Replace forward slashes with backslashes. Forward slashes are used in network paths
  path := RegExReplace(path, "/", "\")

  ; Remove trailing backslash
  path := RTrim(path, "\")

  if Config.ShowFullPath
    return path

  ; Check if it's a drive root (e.g., "C:")
  if RegExMatch(path, "^[A-Za-z]:$")
    return path "\"

  ; Extract folder name from path
  SplitPath(path, &folderName)

  ; result := folderName

  ; If folder name is empty, e.g., FTP root, use forward slash only
  if (folderName = "")
    folderName := "/"

  return folderName
}

; =============================================================================
; CLEANUP
; =============================================================================
OnExit(CleanupExit)

CleanupExit(*) {
  SetTimer(UpdateTCTitle, 0)
  return 0
}