; This scirpt helps to start and stop obs recording automatically.
; The recording will be started once the Genotype_Visualizer.exe window shows
; up, and stopped when the windows is gone.
; Alt + F12 needs to be mapped to start recording
; Alt + F11 needs to be mapped to stop recording

#SingleInstance force

check_delay := 100
hotkey_delay := 50
is_active := false
MsgBox, hello
Loop
{
    if WinExist("ahk_exe Genotype_Visualizer.exe")
    {
        if(!is_active)
        {
            is_active := true

            Send {Alt Down}{F12 Down}
            Sleep, %hotkey_delay%
            Send {Alt Up}{F12 Up}
        }
    }
    else if(is_active)
    {
        is_active := false

        Send {Alt Down}{F11 Down}
        Sleep, %hotkey_delay%
        Send {Alt Up}{F11 Up}
    }

    Sleep, %check_delay%
}
