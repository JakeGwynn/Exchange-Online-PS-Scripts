Connect-ExchangeOnline

$ExportFileName = "C:\Temp\AllResourceRoomCalendarPermissions.csv"

# Full list of possible AccessRights exclusions here: https://docs.microsoft.com/en-us/powershell/module/exchange/set-mailboxfolderpermission?view=exchange-ps
# List all AccessRights types that you DON'T want to report on
[array]$AccessRightsExclusions = @(
    "None"
    "CreateItems"
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
$Mailboxes = get-EXOmailbox -RecipientTypeDetails RoomMailbox,SharedMailbox

foreach ($Mailbox in $Mailboxes) {
    $RoomPermissions = $null
    $RoomPermissions = Get-EXOMailboxFolderPermission -Identity "$($Mailbox.UserPrincipalName):\Calendar"
    foreach ($PermissionSet in $RoomPermissions) {
        foreach ($AccessRight in $PermissionSet.AccessRights) {
            If($AccessRight -notin $AccessRightsExclusions) {
                $PermissionObject = [PSCustomObject]@{}
                $PermissionObject = [PSCustomObject]@{
                    RoomMailbox = $Mailbox.UserPrincipalName
                    UserWithAccess = $PermissionSet.User
                    AccessRights = $AccessRight
                    SharingPermissionFlags = $Permission.SharingPermissionFlags
                    RecipientTypeDetails = $Mailbox.RecipientTypeDetails
                }
                $AllRoomCalendarPermissions.Add($PermissionObject)
            }
        }
    }
} 

$AllRoomCalendarPermissions | Export-csv -Path $ExportFileName -NoTypeInformation