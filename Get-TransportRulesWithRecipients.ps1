$CsvExportPath = "C:\temp\TransportRulesWithRecipients.csv"
$RulesWithRecipients = Get-TransportRule | Where-Object {$null -ne $_.AddToRecipients -or $null -ne $_.CopyTo -or $null -ne $_.BlindCopyTo}
$RuleTable = New-Object 'System.Collections.Generic.List[PSObject]'
foreach ($Rule in $RulesWithRecipients) {
    $RuleTable.Add(
        [PSCustomObject]@{
            RuleName = $Rule.Name
            To = $Rule.AddToRecipients -join ", "
            CC = $Rule.CopyTo -join ", "
            BCC = $Rule.BlindCopyTo -join ", "
        }
    )
}
$RuleTable | Export-Csv -Path $CsvExportPath -NoTypeInformation