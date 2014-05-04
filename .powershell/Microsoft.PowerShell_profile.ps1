# This powershell profile, combined with GOW (Gnu on Windows) makes for an almost usable terminal env on windows
# Put this file in Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# Run "Set-ExecutionPolicy Unrestricted -Force" as Admin to enable loading of scripts and this profile

# Go to homedir
Function home { cd $ENV:USERPROFILE }
home

# Commands
Function pkill {
    taskkill /F /IM $Args
}

Function pgrep {
    # Requires GOW, greps for first line and any matching processes
    ps | grep -E "^Handles|$Args"
}

if ($PSVersionTable.PSVersion.Major -ge 3) { 
	# Install PSReadLine before using this
	# https://github.com/lzybkr/PSReadLine
	Import-Module PSReadLine
	Set-PSReadlineOption -EditMode Emacs
}

# Persistent history
# From: http://jamesone111.wordpress.com/2012/01/28/adding-persistent-history-to-powershell/
# View history with "h" or "history" command
# Insert command with "#<id>[tab]"

$MaximumHistoryCount = 2048
$Global:logfile = "$env:USERPROFILE\Documents\windowsPowershell\log.csv" 
$truncateLogLines = 100
$History = @()
$History += '#TYPE Microsoft.PowerShell.Commands.HistoryInfo'
$History += '"Id","CommandLine","ExecutionStatus","StartExecutionTime","EndExecutionTime"'
if (Test-Path $logfile) {$history += (get-content $LogFile)[-$truncateLogLines..-1] | where {$_ -match '^"\d+"'} }
$history > $logfile
$History | select -Unique  |
           Convertfrom-csv -errorAction SilentlyContinue |
           Add-History -errorAction SilentlyContinue

Function prompt {
	# Save history after every command
	$hid = $myinvocation.historyID
	if ($hid -gt 1) {
		$lastCommand = get-history ($myinvocation.historyID -1 )
		$lastCommand | convertto-csv | Select -last 1 >> $logfile
	}

	# Just print a normal prompt
	"PS$($PSVersionTable.psversion.major) " + $(Get-Location) + 
	$(if ($nestedpromptlevel -ge 1) { '>>' }) + '> '
}

# Search history, requires gow
Function hi {
    Get-History -count 32767 | grep -i $Args
}

# Check elapsed time AFTER running a command, pretty neat
Function time {
    <# .Synopsis Returns the time taken to run a command 
      .Description By default returns the time taken to run the last command 
      .Parameter ID The history ID of an earlier item. 
    #>
    param ( [Parameter(ValueFromPipeLine=$true)]
        $id = ($MyInvocation.HistoryId -1)
    )
    process {  foreach ($i in $id) { 
            (get-history $i).endexecutiontime.subtract(
            (get-history ($i)).startexecutiontime).totalseconds
        }
    } 
}
