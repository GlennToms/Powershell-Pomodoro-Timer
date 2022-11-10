# Powershell Pomodoro Timer
 
## .SYNOPSIS
Powershell based Pomodoro Timer with 3 short breaks and 1 long break before resetting

## .DESCRIPTION
Powershell based Pomodoro Timer with 3 short breaks and 1 long break before resetting

## .PARAMETER Pomodoro
Specifies the length of time for working

## .PARAMETER ShortBreak
Specifies the length of time for a short break

## .PARAMETER LongBreak
Specifies the length of time for a long break

## .PARAMETER NumOfShortBreaks
Specifies the number of short breaks for using long break time

## .PARAMETER DisableNotifications
Disables Windows Toast Notifications

## .EXAMPLE
PS> Start-Pomodoro -Pomodoro 20 -ShortBreak 3 -LongBreak 10 -NumOfShortBreaks 3 -DisableNotifications
Set work time to 20 minutes, short breaks at 3 minutes, a long break at 10 minutes, and disabled notifications

## .EXAMPLE
PS> Start-Pomodoro -DisableNotifications
Uses default timings and disabled notifications

## .LINK
https://github.com/GlennToms/Powershell-Pomodoro-Timer
