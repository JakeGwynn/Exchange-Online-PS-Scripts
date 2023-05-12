<#
    Copyright 2022 Jake Gwynn

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

Connect-ExchangeOnline
$AdminUpn = "jakegwynn@jakegwynndemo.com"
$Mailboxes = Get-EXOMailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
$EmailOrDomainToRemove = "block2@gmail.com"
$MoreThan10000Users = $false

if ($MoreThan10000Users -eq $false) {
    foreach ($input in $Mailboxes) {
        $input.Name 
        $JunkConfig = $null
        $JunkConfig = Get-MailboxJunkEmailConfiguration $input.Name
        if ($JunkConfig.BlockedSendersAndDomains -contains "$EmailOrDomainToRemove") {
            Set-MailboxJunkEmailConfiguration $input.Name -BlockedSendersAndDomains @{Remove="$EmailOrDomainToRemove"}
        }
    }
}
else {
    Start-RobustCloudCommand -UserPrincipalName $AdminUpn -Recipients $Mailboxes -LogFile C:\temp\out.log -ScriptBlock {
        $JunkConfig = $null
        $JunkConfig = Get-MailboxJunkEmailConfiguration $input.Name
        if ($JunkConfig.BlockedSendersAndDomains -contains "$EmailOrDomainToRemove") {
            Write-Host "Removing $EmailOrDomainToRemove from $($input.DisplayName)"
            Set-MailboxJunkEmailConfiguration $input.Name -BlockedSendersAndDomains @{Remove="$EmailOrDomainToRemove"}
        }
    }
}
