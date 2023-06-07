# auditLogSearch
# coder: matt beaudin
# One Identity LLC
# 2023-06-06

# this script allows you to easily search archived audit logs from Safeguard using Powershell. Right click in a directory and you can load up all the audit logs at once. Probably okay for small to medium environments. 
# If the logs are massive, then performance parsing and searching in the grid view will be mediocre.
 
Write-Host `n
Write-Host `n
Write-Host "

                 .___.__  __    .__                                                     .__     
_____   __ __  __| _/|__|/  |_  |  |   ____   ____     ______ ____ _____ _______   ____ |  |__  
\__  \ |  |  \/ __ | |  \   __\ |  |  /  _ \ / ___\   /  ___// __ \\__  \\_  __ \_/ ___\|  |  \ 
 / __ \|  |  / /_/ | |  ||  |   |  |_(  <_> ) /_/  >  \___ \\  ___/ / __ \|  | \/\  \___|   Y  \
(____  /____/\____ | |__||__|   |____/\____/\___  /  /____  >\___  >____  /__|    \___  >___|  /
     \/           \/                       /_____/        \/     \/     \/            \/     \/ 

" -BackgroundColor Black -ForegroundColor Blue
Write-Host "a simple search tool for archived audit logs from safeguard"
Write-Host `n

$quote = Invoke-RestMethod -URI https://zenquotes.io/api/random
Write-Host $quote.q
Write-Host "-"  $quote.a 

Write-Host `n
Write-Host "====================================================================================="

#lets see how many audit log json files we want to parse. get an initial count.s

if($args[0]){
    $auditLogFiles = $args[0]
   
}else{
    $auditlogFiles = Get-ChildItem  ".\*.json"
}

$fileCount = ($auditLogFiles | Measure-Object). Count

Write-Host "messages:"
Write-Host "Found $fileCount Audit Log json files." 
$count = 0;

foreach($auditLogFile in $auditLogFiles){
    Write-Progress -Activity "Parsing audit logs" -Status "current file: $auditLogfile"

    #open a streamreader, this is more efficient than Get-Content for large files
    $streamReader = New-Object System.IO.StreamReader($auditLogFile)
    try{
        #this is in a try catch to see if we hit an error reading a json log file. If we do, let the user know, but keep going.
        if($logday = $streamreader.ReadToEnd() | ConvertFrom-Json ){
              $count++
        }
    }catch{
        Write-Host "error occurred parsing $auditLogfile"
    }
    $result += $logday
    $streamreader.Dispose()
}   
Write-Host "Parsed $count Audit Log Files successfully"
$result |Sort-Object -Property LogTime| Out-GridView -Title "AuditLogSearch"
pause