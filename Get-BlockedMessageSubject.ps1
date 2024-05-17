param (
    [string]$MessageTraceId
)

[System.Net.ServicePointManager]::SecurityProtocol = 'TLS12'

$TenantId = ""
$AppId = ""
$ClientSecret = ""
$Thumbprint = ""

Connect-ExchangeOnline -CertificateThumbprint $Thumbprint -AppId $AppId -Organization $TenantId -ShowBanner:$false

$TokenTimer = $null
$Token = $null

function Get-RestApiError ($RestError) {
    if ($RestError.Exception.GetType().FullName -eq "System.Net.WebException") {
        $ResponseStream = $null
        $Reader = $null
        $ResponseStream = $RestError.Exception.Response.GetResponseStream()
        $Reader = New-Object System.IO.StreamReader($ResponseStream)
        $Reader.BaseStream.Position = 0
        $Reader.DiscardBufferedData()
        return $Reader.ReadToEnd();
    }
}

function Connect-GraphApiWithClientSecret ($TenantId, $AppId, $ClientSecret) {
    if($global:TokenTimer -eq $null -or $global:TokenTimer.elapsed.minutes -gt '55'){
        try{
            Write-Host "Authenticating to Graph API"
            $Body = @{
                Grant_Type    = "client_credentials"
                Scope         = "https://graph.microsoft.com/.default"
                client_Id     = $AppId
                Client_Secret = $ClientSecret
                }
            $ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $Body
            $global:TokenTimer =  [system.diagnostics.stopwatch]::StartNew()
            $global:GraphToken = $ConnectGraph.access_token
            return $ConnectGraph.access_token
        }
        catch {
            $RestError = $null
            $RestError = Get-RestApiError -RestError $_
            Write-Host $_ -ForegroundColor Red
            return Write-Host $RestError -ForegroundColor Red
        }
    }
    else {
        return $global:GraphToken
    }
}

$Token = Connect-GraphApiWithClientSecret -TenantId $TenantId -AppId $AppId -ClientSecret $ClientSecret

$headers = @{
    "Authorization" = "Bearer $Token"
    "Content-type" = "application/json"
}

$MessageTrace = Get-Messagetrace -MessageTraceId $MessageTraceId

$InternetMessageId = $MessageTrace[0].MessageId
$UserSMTPAddress = $MessageTrace[0].SenderAddress

try{
    $uri = "https://graph.microsoft.com/v1.0/users/$UserSMTPAddress/messages?`$filter=internetMessageId eq '$InternetMessageId'"
    $messages = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
}
catch {
    $RestError = $null
    $RestError = Get-RestApiError -RestError $_
    Write-Host $_ -ForegroundColor Red
    return Write-Host $RestError -ForegroundColor Red 
}


Write-Host "Message Subject: $($messages.value.subject)"
