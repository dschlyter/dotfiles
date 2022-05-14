#SingleInstance force

; Put this in documents dir to autorun on startup
; Keep this in dotfiles and then: cp Autohotkey.ahk /mnt/c/Users/dschl/Documents
; Don't forget to reload

; legend: # win ! alt ^ ctrl + shift

; Temporarily pause media, to pause background podcast during game cutscenes (I always forget to start again)
^!p::
Send {Media_Stop}
Sleep 120000
Send {Media_Play_Pause}
return

; Disable capslock key
; $Capslock::
; Use shift + caps for actual caps
; +Capslock::Capslock
; Uncomment to use capslock as backspace (disabled for now)
; $Backspace::
; $Capslock::Backspace
; $^Capslock::^Backspace

; Quick access to up/down without moving hands of home row
; #j::Send {Down}
; #k::Send {Up}

; Programming-friendly mapping to alt+letter for swedish keybaords (especially Kinesis)
; !j::Send (
; !k::Send )
; !u::Send {{}
; !i::Send {}}
; !m::Send [
; !,::Send ]
; !y::Send '
; !o::Send ~{Space} ; space after key is required on swedish keyboard layouts

; Toggle sound between first two outputs (like external TV)
!^b::
; Run, mmsys.cpl
; WinWait,Sound
; ControlSend,SysListView321,{Down}
; ControlGet, isEnabled, Enabled,,&Set Default
; if(!isEnabled)
; {
; ControlSend,SysListView321,{Down}
; }
; ControlClick,&Set Default
; ControlClick,OK
; WinWaitClose
; SoundPlay, *-1
; return

; mac-style same-application-window switch, forwards and backwards
; !?:: ; Next window
; WinGetClass, ActiveClass, A
; WinGet, WinClassCount, Count, ahk_class %ActiveClass%
; IF WinClassCount = 1
    ; Return
; Else
; WinGet, List, List, % "ahk_class " ActiveClass
; Loop, % List
; {
    ; index := List - A_Index + 1
    ; WinGet, State, MinMax, % "ahk_id " List%index%
    ; if (State <> -1)
    ; {
        ; WinID := List%index%
        ; break
    ; }
; }
; WinActivate, % "ahk_id " WinID
; return
; 
; !^?:: ; Last window
; WinGetClass, ActiveClass, A
; WinGet, WinClassCount, Count, ahk_class %ActiveClass%
; IF WinClassCount = 1
    ; Return
; Else
; WinGet, List, List, % "ahk_class " ActiveClass
; Loop, % List
; {
    ; index := List - A_Index + 1
    ; WinGet, State, MinMax, % "ahk_id " List%index%
    ; if (State <> -1)
    ; {
        ; WinID := List%index%
        ; break
    ; }
; }
; WinActivate, % "ahk_id " WinID
; return
