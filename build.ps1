
##### LOAD CONFIGS ######
$Config = Get-Content config.json | ConvertFrom-Json

$AppName = $Config.APP_NAME

$Version = $Config.VERSION
$Build = $Config.BUILD
$Interface = $Config.INTERFACE
$script:Build++ 

$WowInstallDir = $Config.WOW_INSTALL_DIR
$validInstallDir = $WowInstallDir.EndsWith('Interface\AddOns\')
if (!$validInstallDir) {
    Write-Error 'INVALID_WOW_INSTALL_DIR: WoW install directory does not end with Interface\Addons\.'
    return;
}
$WowDst = $WowInstallDir + $AppName

$Version = $Version + '.' + $Build

Write-Host Build: $Version


$Src = $Config.SRC_DIR
$Dst = $Config.BUILD_DIR

$TocFile = $AppName + '.toc'
$TocPath = $Dst + '/' + $TocFile

##### UPDATE INCREMENTED BUILD NUMBER ######

$Config.BUILD = $Build
$Config | ConvertTo-Json | Out-File -FilePath config.json


# BUILD 

try {
    # Clean target folder
    $exists = Test-Path $Dst
    if ( $exists) {
        $CleanDst = $Dst + '/*'
        Remove-Item -Recurse -Force $CleanDst
    }
    else {
        New-Item -ItemType "directory" -Path $Dst
    }
    # Copy README, CHANGELOG
    $filter = [regex] ".*(README|CHANGELOG)"
    $bin = Get-ChildItem -Path '.' | Where-Object { $_.Name -match $filter }
    foreach ($item in $bin) {
        Copy-Item -Path $item.FullName -Destination $Dst
    }
    # Copy src into build (or dest)
    $BuildSrc = $Src + '/*'

    Copy-Item -Path $BuildSrc -Destination $Dst -Recurse -Force
}
catch {
    Write-Host $PSItem.Exception.Message -ForegroundColor RED
}
finally {
    $Error.Clear()
}


##### Increment Build Number and Replace in Files #####


$old = '{{VERSION}}'
$new = $Version

Get-ChildItem $Config.BUILD_DIR -recurse -include *.toc, *.lua | 
Select-Object -expand fullname |
ForEach-Object {
  (Get-Content $_) -replace $old, $new | Set-Content $_
}

$old = '{{INTERFACE}}'
$new = $Interface

Get-ChildItem $Config.BUILD_DIR -recurse -include *.toc | 
Select-Object -expand fullname |
ForEach-Object {
  (Get-Content $_) -replace $old, $new | Set-Content $_
}

## INSTALL IN LOCAL WOW ADDONS ##

try {
    # Clean target wow install folder
    $exists = Test-Path $WowDst
    if ( $exists) {
        $CleanWowDst = $WowDst + '/*'
        Remove-Item -Recurse -Force $CleanWowDst
    }
    else {
        New-Item -ItemType "directory" -Path $WowDst
    }

    # Install the TOC file

    Copy-Item -Path $TocPath  -Destination $WowDst -Recurse -Force
    # Copy src into build (or dest)
    $BuildDst = $Dst + '/*'
    Copy-Item -Path $BuildDst -Destination $WowDst -Recurse -Force
}
catch {
    Write-Host $PSItem.Exception.Message -ForegroundColor RED
}
finally {
    $Error.Clear()
}
