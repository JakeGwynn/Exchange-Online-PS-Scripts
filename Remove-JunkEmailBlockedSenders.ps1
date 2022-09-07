Connect-ExchangeOnline
$AdminUpn = "jakegwynn@jakegwynndemo.com"
$Mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
$EmailOrDomainToRemove = "block2@gmail.com"

foreach ($input in $Mailboxes) {
    $input.Name 
    $JunkConfig = $null
    $JunkConfig = Get-MailboxJunkEmailConfiguration $input.Name
    if ($JunkConfig.BlockedSendersAndDomains -contains "$EmailOrDomainToRemove") {
        Set-MailboxJunkEmailConfiguration $input.Name -BlockedSendersAndDomains @{Remove="$EmailOrDomainToRemove"}
    }
}

<#
Start-RobustCloudCommand -UserPrincipalName $AdminUpn -Recipients $Mailboxes -LogFile C:\temp\out.log -ScriptBlock {
    $JunkConfig = $null
    $JunkConfig = Get-MailboxJunkEmailConfiguration $input.Name
    if ($JunkConfig.BlockedSendersAndDomains -contains "$EmailOrDomainToRemove") {
        Write-Host "Removing $EmailOrDomainToRemove from $($input.DisplayName)"
        Set-MailboxJunkEmailConfiguration $input.Name -BlockedSendersAndDomains @{Remove="$EmailOrDomainToRemove"}
    }
}
#>