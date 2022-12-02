# vm-backup-prune

Automatically prune backup files created by VMs.<br><br><br>

**Make the following modifications to the file:**<br><br>

<code>$keepbackup = int</code><br>
Number of backups to keep, default 24. If script runs once per week, this is 6 months worth of backups before any pruning occurs. Once this number is met, the oldest backup will be pruned. Set to arbitrarily large number to disable pruning.<br><br>

<code>$ht.Add('repo-name", 'file-mask')</code><br>
Add a backup to the prune list. These are explicitly named, so no unintentional backups occur. The hashtable value tells the script which files to consider for pruning.
