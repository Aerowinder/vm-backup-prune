#User customizable variables#
#[string]$base = $PSScriptRoot
$dir_base = '\\10.10.2.1\VMStore\Backup'
$dir_log = $dir_base + '\_logs'
$file_log = $dir_log + '\' + (Get-Date -Format yyyy-MM-dd) + '.txt'
$keepbackup = 24
#############################

if (-Not(Test-Path -Path $dir_log)) {Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('Log folder not found (' + $dir_log + '), script will terminate.','VM Backup Prune Script','Ok','Error'); break} #If $dir_log does not exist, show messagebox then terminate script.

function LogWrite{ # We don't need to verify $dir_log exists, since the script will exit before it gets to this point if it doesn't exist.
    param([string]$message)

    $time = Get-Date -Format HH:mm:ss
    Add-Content $file_log -Value ($time + ':   ' + $message + "`n")
}

$list_backup = "technitium1","nginx-int","librenms","dokuwiki","unifi","dashy","technitium2","nginx-ext","plex","usenet"

foreach ($entry in $list_backup) {
    $path_backup = $dir_base + '\' + $entry

    if (-Not(Test-Path -Path $path_backup)) {LogWrite ("Error: Path not found. `n            Folder: " + $path_backup); continue} #If $path_backup does not exist, write log file and skip to next iteration of loop.

    $files = Get-ChildItem -Path ($path_backup + '\*') -Include ($entry + '*') #Grab complete list of files in the subfolder.

    if (-Not $null -eq $files) { #At least one backup exists for this entry.
        $newestfile = $files | Sort-Object -Property Name -Descending | Select-Object -First 1 #Select newest file from the list of files in the subfolder
        if (Test-Path $newestfile -OlderThan (Get-Date).AddDays(-7)) {LogWrite ("Error: No new backups found. `n            Folder: " + $path_backup); continue} #If newest log file is older than 7 days, write log file and skip to next iteration of loop.
    }

    if ($files.Count -gt $keepbackup) {
        $prune = $files | Sort-Object -Property Name -Descending | Select-Object -Last ($files.Count - $keepbackup) #Must check file count before processing as a negative number results in exception.
        $prune | ForEach-Object { Remove-Item $_ }#-WhatIf # WhatIf is for testing, dry run.
    }
    
    $files = $null #Clearing these variables (resetting to $null) should not be necessary, it is here just in case.
    $prune = $null #There could be an edge case where these variables don't get emptied upon error, and could consequently fail to fire off an email.
}

if (Test-Path $file_log) {Invoke-Item $file_log} #If log file exists, open it up and leave it on screen.

#Changelog
#2022-12-02 - AS - v1, Updated for Git, refactored to match new requirements.
#2022-12-03 - AS - v2, Removed hash table. Submitted v1 to code-dump. Removed Mask text from logs.
