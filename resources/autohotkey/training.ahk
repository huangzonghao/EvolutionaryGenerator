#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
MsgBox, Press OK to Launch Training

WinActivate, Evolutionary_Generator - Microsoft Visual Studio
Sleep 500
Send {F5 Down}
Sleep 100
Send {F5 Up}

Loop, 10
{
    Sleep 3600000 ; sleep 3600s (1h)
    WinActivate, Evolutionary_Generator - Microsoft Visual Studio
    Sleep 500
    Send {Ctrl Down}{Shift Down}{F5 Down}
    Sleep 200
    Send {Ctrl Up}{Shift Up}{F5 Up}
}
