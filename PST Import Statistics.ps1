Connect-ExchangeOnline

[System.Collections.Generic.List[psobject]]$MailboxImportRequestStatistics = @()

$Mailboxes = Get-ExoMailbox -ResultSize Unlimited
[array]$MailboxImportRequests = Get-MailboxImportRequest -ResultSize Unlimited

foreach ($input in $MailboxImportRequests){
    $RequestStatistic = $null
    $PstImportRequestData = [PSCustomObject]@{}
    $RequestStatistic = Get-MailboxImportRequestStatistics -Identity $input.RequestGuid

    if ($RequestStatistic.WorkloadType -like "RemotePstIngestion") {
        $PstImportRequestData = [PSCustomObject]@{
            "PST Filename" = $RequestStatistic.AzureBlobStorageAccountUri.Split("/")[-1]
            "Target Mailbox" = ($Mailboxes.Where({$_.Name -eq $RequestStatistic.TargetAlias})).UserPrincipalName
            "Batch Name" = $RequestStatistic.BatchName
            "Import Status" = $RequestStatistic.Status
            "Error" = $RequestStatistic.FailureType
            "Total Items" = $RequestStatistic.EstimatedTransferItemCount
            "Items Imported" = $RequestStatistic.ItemsTransferred
            "Target Folder" = $RequestStatistic.TargetRootFolder
            "Skipped Item Count" = $RequestStatistic.SkippedItemRecords
            "Last Failure" = $RequestStatistic.LastFailure
            "Total Item Size" = $RequestStatistic.EstimatedTransferSize
            "Imported Item Size" = $RequestStatistic.BytesTransferred
        }
        $MailboxImportRequestStatistics.Add($PstImportRequestData)
    }
}

<#
Start-RobustCloudCommand -UserPrincipalName jakegwynn@jakegwynndemo.com -recipients $MailboxImportRequests -IdentifyingProperty Mailbox -logfile C:\temp\out.log -ScriptBlock {
    $RequestStatistic = $null
    $PstImportRequestData = [PSCustomObject]@{}
    $RequestStatistic = Get-MailboxImportRequestStatistics -Identity $input.RequestGuid

    if ($RequestStatistic.WorkloadType -like "RemotePstIngestion") {
        $PstImportRequestData = [PSCustomObject]@{
            "PST Filename" = $RequestStatistic.AzureBlobStorageAccountUri.Split("/")[-1]
            "Target Mailbox" = ($Mailboxes.Where({$_.Name -eq $RequestStatistic.TargetAlias})).UserPrincipalName
            "Import Status" = $RequestStatistic.Status
            "Error" = $RequestStatistic.FailureType
            "Total Items" = $RequestStatistic.EstimatedTransferItemCount
            "Items Imported" = $RequestStatistic.ItemsTransferred
            "Target Folder" = $RequestStatistic.TargetRootFolder
            "Skipped Item Count" = $RequestStatistic.SkippedItemRecords
            "Last Failure" = $RequestStatistic.LastFailure
            "Total Item Size" = $RequestStatistic.EstimatedTransferSize
            "Imported Item Size" = $RequestStatistic.BytesTransferred
        }
        $MailboxImportRequestStatistics.Add($PstImportRequestData)
    }
}
#>

$MailboxImportRequestStatistics | Export-Csv -NoTypeInformation -Path "C:\Temp\PstImportReport.csv"