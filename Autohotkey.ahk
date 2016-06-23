#SingleInstance force

; Put this in documents dir to autorun on startup

; Disable capslock key
$Capslock::
; Use shift + caps for actual caps
+Capslock::Capslock
; Uncomment to use capslock as backspace (disabled for now)
; $Backspace::
; $Capslock::Backspace
; $^Capslock::^Backspace

; Quick access to up/down without moving hands of home row
#j::Send {Down}
#k::Send {Up}

; Programming-friendly mapping to alt+letter for swedish keybaords (especially Kinesis)
!j::Send (
!k::Send )
!u::Send {{}
!i::Send {}}
!m::Send [
!,::Send ]
!y::Send '
!o::Send ~{Space} ; space after key is required on swedish keyboard layouts

; mac-style same-application-window switch, forwards and backwards
!?:: ; Next window
WinGetClass, ActiveClass, A
WinGet, WinClassCount, Count, ahk_class %ActiveClass%
IF WinClassCount = 1
    Return
Else
WinGet, List, List, % "ahk_class " ActiveClass
Loop, % List
{
    index := List - A_Index + 1
    WinGet, State, MinMax, % "ahk_id " List%index%
    if (State <> -1)
    {
        WinID := List%index%
        break
    }
}
WinActivate, % "ahk_id " WinID
return

!^?:: ; Last window
WinGetClass, ActiveClass, A
WinGet, WinClassCount, Count, ahk_class %ActiveClass%
IF WinClassCount = 1
    Return
Else
WinGet, List, List, % "ahk_class " ActiveClass
Loop, % List
{
    index := List - A_Index + 1
    WinGet, State, MinMax, % "ahk_id " List%index%
    if (State <> -1)
    {
        WinID := List%index%
        break
    }
}
WinActivate, % "ahk_id " WinID
return
