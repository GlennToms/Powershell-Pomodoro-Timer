function Start-Pomodoro {
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
        $PlayPauseKey = "SpaceBar"
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
                Start-Sleep -Milliseconds 100
                Test-KeyPressed -Key $PlayPauseKey
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

Start-Pomodoro