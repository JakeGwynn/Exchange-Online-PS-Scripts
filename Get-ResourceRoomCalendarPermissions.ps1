Connect-ExchangeOnline

$ExportFileName = "C:\Temp\AllResourceRoomCalendarPermissions.csv"

# Full list of possible AccessRights exclusions here: https://docs.microsoft.com/en-us/powershell/module/exchange/set-mailboxfolderpermission?view=exchange-ps
# List all AccessRights types that you DON'T want to report on
[array]$AccessRightsExclusions = @(
    "None"
    "CreateSubfolders"
    "FolderContact"
    "FolderOwner"
    "FolderVisible"
    "ReadItems"
    "Contributor"
    "Reviewer"
    "AvailabilityOnly"
    "LimitedDetails"
)

[System.Collections.Generic.List[psobject]]$AllRoomCalendarPermissions = @()
$AllMailboxes = Get-EXOMailbox -ResultSize unlimited
$MailboxesToSearch = $AllMailboxes | Where-Object {$_.RecipientTypeDetails -in @("RoomMailbox","SharedMailbox")}

foreach ($Mailbox in $MailboxesToSearch) {
    $RoomPermissions = $null
    $RoomPermissions = Get-EXOMailboxFolderPermission -Identity "$($Mailbox.UserPrincipalName):\Calendar"
    foreach ($PermissionSet in $RoomPermissions) {
        foreach ($AccessRight in $PermissionSet.AccessRights) {
            If($AccessRight -notin $AccessRightsExclusions) {
                $DelegateMailbox = $null
                $DelegateMailbox = $AllMailboxes | Where-Object {$_.PrimarySmtpAddress -eq $PermissionSet.User}
                $PermissionObject = [PSCustomObject]@{}
                $PermissionObject = [PSCustomObject]@{
                    MailboxUPN = $Mailbox.UserPrincipalName
                    MailboxDisplayName = $Mailbox.DisplayName
                    DelegateUPN = $DelegateMailbox.UserPrincipalName
                    DelegateDisplayName = $DelegateMailbox.DisplayName
                    AccessRights = $AccessRight
                    SharingPermissionFlags = $Permission.SharingPermissionFlags
                    RecipientTypeDetails = $Mailbox.RecipientTypeDetails
                }
                $AllRoomCalendarPermissions.Add($PermissionObject)
            }
        }
    }
} 

$AllRoomCalendarPermissions | Export-Csv -Path $ExportFileName -NoTypeInformation
