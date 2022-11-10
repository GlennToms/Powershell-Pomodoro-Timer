function Start-Pomodoro {
    <#
        .SYNOPSIS
        Powershell based Pomodoro Timer with 3 short breaks and 1 long break before resetting
        
        .DESCRIPTION
        Powershell based Pomodoro Timer with 3 short breaks and 1 long break before resetting

        .PARAMETER Pomodoro
        Specifies the length of time for working

        .PARAMETER ShortBreak
        Specifies the length of time for a short break
        
        .PARAMETER LongBreak
        Specifies the length of time for a long break

        .PARAMETER DisableNotifications
        Disables Windows Toast Notifications

        .EXAMPLE
        PS> Start-Pomodoro -Pomodoro 20 -ShortBreak 3 -LongBreak 10 -DisableNotifications
        Set work time to 20 minutes, short breaks at 3 minutes, a long break at 10 minutes, and disabled notifications

        .EXAMPLE
        PS> Start-Pomodoro -DisableNotifications
        Uses defaul timings and disabled notifications

        .LINK
        https://github.com/GlennToms/Powershell-Pomodoro-Timer
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [Int]
        $Pomodoro = 25,
        [Parameter()]
        [Int]
        $ShortBreak = 5,
        [Parameter()]
        [Int]
        $LongBreak = 15,
        [Parameter()]
        [String]
        $PlayPauseKey = "SpaceBar",
        [Parameter()]
        [switch]
        $DisableNotifications
    )
    $IsBreak = $false
    $SessionCount = 0
    $Minutes = 0

    while ($true) {
        if ($IsBreak) {
            Write-Host ""
            if ($SessionCount -lt 3) {
                $Minutes = $ShortBreak
                $SessionCount += 1
                Write-Host -ForegroundColor Cyan "Press 'Enter' to start short break #$SessionCount for $(Convert-FromSeconds -Seconds ($Minutes * 60)) minutes"
                Wait-KeyPress -Key 'Enter'
            }
            else {
                $Minutes = $LongBreak
                $SessionCount = 0
                Write-Host -ForegroundColor Green "Press 'Enter' to start long break #4 for $(Convert-FromSeconds -Seconds ($Minutes * 60)) minutes"
                Wait-KeyPress -Key 'Enter'
            }
        }
        else {
            $Minutes = $Pomodoro
            Write-Host ""
            Write-Host -ForegroundColor Magenta "Press 'Enter' to start deep work for $(Convert-FromSeconds -Seconds ($Pomodoro * 60)) minutes"
            Wait-KeyPress -Key 'Enter'
        }
        $IsBreak = !$IsBreak

        Write-Host "Press '$PlayPauseKey' to Pause"
        for ($SecondsLeft = $Minutes * 60; $SecondsLeft -gt 0; $SecondsLeft--) {
            Write-Host -ForegroundColor Yellow "`r$(Convert-FromSeconds -Seconds $SecondsLeft) left of $(Convert-FromSeconds -Seconds ($Minutes * 60))" -NoNewline
            for ($k = 0; $k -lt 10; $k++) {
                Start-Sleep -Milliseconds 1
                Test-KeyPressed -Key $PlayPauseKey
            }
        }
        
        if ($DisableNotifications -eq $false) {
            if ($IsBreak) {
                Show-ToastNotification -ApplicationTitle 'PomodoroTimer' -Text "Deep work ended"
            }
            else {
                Show-ToastNotification -ApplicationTitle 'PomodoroTimer' -Text "Break ended"
            }
        }
    }
}

function Convert-FromSeconds {
    param (
        $Seconds
    )
    $ts = [timespan]::fromseconds($Seconds)
    return ("{0:mm\:ss}" -f $ts)
}

function Wait-KeyPress {
    param (
        $Key
    )
    $KeyNotPressed = $true
    $dots = ""
    while ($KeyNotPressed) {
        Write-Host "`rWaiting   " -NoNewline -ForegroundColor Red
        for ($i = 0; $i -lt 4; $i++) {
            Write-Host "`rWaiting$dots" -NoNewline -ForegroundColor Red
            for ($k = 0; $k -lt 10; $k++) {
                Start-Sleep -Milliseconds 100
                if ([Console]::KeyAvailable) {
                    if ([Console]::ReadKey($true).Key -eq $Key) {
                        $KeyNotPressed = $false
                        break
                    }
                }
                if ($KeyNotPressed -eq $false) {
                    break
                }
            }
            if ($KeyNotPressed -eq $false) {
                break
            }
            $dots += "."
        }
        $dots = ""
    }
}

function Test-KeyPressed {
    param (
        $Key
    )
    if ([Console]::KeyAvailable) {
        if ([Console]::ReadKey($true).Key -eq $Key) {
            Write-host  ""
            Read-Host "Press 'Enter' to Unpause"
        }
    }
}

function Show-ToastNotification {
    <#
        .SYNOPSIS
        Creates custom Windows Toast notifications with title and text
        
        .DESCRIPTION
        Creates custom Windows Toast notifications with title and text

        .PARAMETER ApplicationTitle
        Specifies the title of the application that created the Toast notification

        .PARAMETER ToastTitle
        Specifies the title of the Toast notification 

        .PARAMETER ToastBody
        Specifies the text of the Toast notification 
        
        .EXAMPLE
        PS> Show-ToastNotification -Title 'PomodoroTimer' -Text "Deep work ended"
        
        .EXAMPLE
        PS> "This is body text" | Show-ToastNotification

        .LINK
        https://github.com/GlennToms/Powershell-Pomodoro-Timer

        .LINK
        https://den.dev/blog/powershell-windows-notification/

        .NOTES
        Updated for use with Pomodoro Timer

    #>
    [cmdletbinding()]
    Param (
        [string]
        $ApplicationTitle = "Powershell",
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline, Mandatory = $true)]
        $ToastBody
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastBody)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = $ApplicationTitle
    $Toast.Group = $ApplicationTitle
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($ApplicationTitle)
    $Notifier.Show($Toast);
}

# Start-Pomodoro
