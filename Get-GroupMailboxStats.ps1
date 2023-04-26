<#
  Copyright 2023 Jake Gwynn
  
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
  (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
  subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

# Required modules: AzureAD and Exchange Online

# Specify the Azure AD Group ID
$groupName = "<Group Name>"
$CsvExportPath = "C:\temp\$($GroupName)_Group-Mailbox-Statistics.csv"

# Connect to AzureAD
Connect-AzureAD

# Connect to Exchange Online
Connect-ExchangeOnline

# Retrieve the group ID
$groupId = (Get-AzureADGroup -Filter "DisplayName eq '$groupName'").ObjectId

# Retrieve the group members
$groupMembers = Get-AzureADGroupMember -ObjectId $groupId

# Create an empty generic list to store the combined output
$combinedOutput = New-Object 'System.Collections.Generic.List[System.Object]'

foreach ($member in $groupMembers) {
    # Get mailbox statistics for each user
    $mailboxStats = $null
    $mailboxStats = Get-MailboxStatistics -Identity $member.UserPrincipalName -ErrorAction silentlyContinue

    # Create a new object with group member and mailbox statistics information
    if ($mailboxStats) {
        $combinedInfo = [PSCustomObject]@{
            DisplayName        = $member.DisplayName
            UserPrincipalName  = $member.UserPrincipalName
            ObjectId           = $member.ObjectId
            MailboxItemCount   = $mailboxStats.ItemCount
            TotalItemSize      = $mailboxStats.TotalItemSize.Value
            LastLogonTime      = $mailboxStats.LastLogonTime
        }
    
        # Add the combined object to the generic list
        $combinedOutput.Add($combinedInfo)
    }
}
    
# Output the combined list to a CSV file
$combinedOutput | Export-Csv -Path $CsvExportPath -NoTypeInformation

Disconnect-AzureAD
Disconnect-ExchangeOnline
