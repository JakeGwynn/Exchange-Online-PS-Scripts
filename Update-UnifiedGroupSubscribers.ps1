# Turn on logging
$LogFile = "FixOffice365GroupSubscriptions-$(Get-Date -Format yyyymmdd-HH-mm-ss)"

Start-Transcript -Path C:\Temp\$LogFile.log -NoClobber

Connect-ExchangeOnline -CertificateThumbPrint "012THISISADEMOTHUMBPRINT" -AppID "36ee4c6c-0812-40a2-b820-b22ebd02bce3" -Organization "contosoelectronics.onmicrosoft.com"

# Get list of all Office 365 Groups
$groups = Get-UnifiedGroup -ResultSize Unlimited | Where-Object {$_.SubscriptionEnabled -eq $true -and $_.Alias -like "DDL-*"}

foreach ($group in $groups) {
    $unsubscribedMembers = $null
    $members = $null
    $subscribers = $null
    Try {
        Write-Host "Group Name: ""$($group.DisplayName)""" -ForegroundColor Yellow

        # Get list of all members and subscribers
        [array]$members = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Members
        [array]$subscribers = Get-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers
        Write-Host "$($members.count)-Members  |  $($subscribers.count)-Subscribers" -ForegroundColor White

        $unsubscribedMembers = $members | Where-Object {$_.Name -notin $subscribers.Name}
 
        if ($unsubscribedMembers) {
            Write-Host "Subscribing all members not currently subscribed..."

            Add-UnifiedGroupLinks -Identity $group.Name -LinkType Subscribers -Links $unsubscribedMembers.Name

            Write-Host "All members successfully subscribed!" -ForegroundColor Green
            Write-Host "`r`n"
        }
        else {
            Write-Host "All members already subscribed to group" -ForegroundColor Green
            Write-Host "`r`n"
        }

    }
    Catch {
        Write-Host "There was an error subscribing all members to the group" -ForegroundColor Red
        Write-Host $($Error[0].Exception) -ForegroundColor Red
        Write-Host "`r`n"
        Continue
    }
}

Disconnect-ExchangeOnline

# End logging
Stop-Transcript