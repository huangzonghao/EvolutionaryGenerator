#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

; Set up constants
class_time := 2400000 ; 2400s (40min)
counter := 1

MsgBox % "Press OK to Launch Training"
WinActivate % "Evolutionary_Generator - Microsoft Visual Studio"
Sleep 500
Send {F5 Down}
Sleep 100
Send {F5 Up}

Traytip % "EvoGen Training", % Format("Training started. Current class time {1:d}min", class_time / 60 / 1000)
Loop
{
    Sleep %class_time%
    WinActivate % "Evolutionary_Generator (Running) - Microsoft Visual Studio"
    Sleep 500
    Send {Ctrl Down}{Shift Down}{F5 Down}
    Sleep 200
    Send {Ctrl Up}{Shift Up}{F5 Up}
    Traytip % "EvoGen Training", % Format("{1:d} classes done, class time {2:d}min", counter, class_time / 60 / 1000)
    counter := counter + 1
}
