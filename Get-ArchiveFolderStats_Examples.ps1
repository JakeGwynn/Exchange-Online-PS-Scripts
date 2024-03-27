# If the ExchangeOnline module is not installed, install it with the following command
# Install-Module -Name ExchangeOnlineManagement

# Connect to Exchange Online with admin credentials
Connect-ExchangeOnline

$CsvExportPath = "C:\Temp\ArchiveMailboxStatistics.csv"
$Mailbox = "yourmailbox@domain.com"

# Get the statistics for all folders in the archive mailbox, and export them to a CSV file
$ArchiveFoldersStatistics = Get-MailboxFolderStatistics -Identity $Mailbox -Archive 
$ArchiveFoldersStatistics  | Export-CSV -Path $CsvExportPath -NoTypeInformation

# Get the statistics for all folders in the archive mailbox, and combine them into a total number of folders (including sub folders) and total size, and total number of items
$Mailbox = "yourmailbox@domain.com"
$ArchiveFolders = Get-MailboxFolderStatistics -Identity $Mailbox -Archive

$TotalSize = $ArchiveFolders | ForEach-Object {
    $size, $unit = $_.FolderSize -split ' ', 2
    switch ($unit) {
        'KB' { $size = [double]$size * 1KB }
        'MB' { $size = [double]$size * 1MB }
        'GB' { $size = [double]$size * 1GB }
        default { $size = [double]$size }
    }
    $size
} | Measure-Object -Sum | Select-Object -ExpandProperty Sum
$TotalSizeWithUnits = if ($TotalSize -ge 1GB) {
    "{0:N2} GB" -f ($TotalSize / 1GB)
} elseif ($TotalSize -ge 1MB) {
    "{0:N2} MB" -f ($TotalSize / 1MB)
} elseif ($TotalSize -ge 1KB) {
    "{0:N2} KB" -f ($TotalSize / 1KB)
} else {
    "{0} bytes" -f $TotalSize
}

$TotalFolders = $ArchiveFolders.Count
$TotalItems = ($ArchiveFolders | Measure-Object -Property ItemsInFolder -Sum).Sum

Write-Host "Total Folders: $TotalFolders"
Write-Host "Total Size: $TotalSizeWithUnits"
Write-Host "Total Items: $TotalItems"
