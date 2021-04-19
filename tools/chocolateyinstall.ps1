$ErrorActionPreference = 'Stop'
$url64 = 'https://sourceforge.net/projects/pymca/files/pymca/PyMca5.6.5/pymca5.6.5-win64.exe'
$version = [version]'5.6.5'

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'EXE'
    url64bit       = $url64
    softwareName   = 'pymca*'
    checksum64     = '3C1B110725D1219AAAAC2C33287BECC4047A92173D1345B91E58222768DCC6AD'
    checksumType64 = 'sha256'
    silentArgs     = '/S'
    validExitCodes = @(0)
}

#Uninstalls the previous version of PyMca if either version exists
Write-Output "Searching if the previous version exists..."

[array]$checkreg = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

if ($checkreg.Count -eq 0) {
    Write-Output 'No installed old version. Process to install PyMca.'
    # No version installed, process to install
    Install-ChocolateyPackage @packageArgs
} elseif ($checkreg.count -ge 1) {
    $checkreg | ForEach-Object {
        if ($null -ne $_.PSChildName) {
            if ([version]$_.DisplayVersion -lt $version) {
                Write-Output "Uninstalling PyMca previous version : $($_.DisplayVersion)"
                $packageArgs['file'] = "$($_.UninstallString)"

                # Uninstall previous version
                Uninstall-ChocolateyPackage @packageArgs
        

                # Process to install
                Write-Output "Installing new version of PyMca"
                Install-ChocolateyPackage @packageArgs
            } elseif (([version]$_.DisplayVersion -eq $version) -and ($env:ChocolateyForce)) {
                Write-Output "PyMca $version already installed, but --force option is passed, download and install"
                Install-ChocolateyPackage @packageArgs
            }
        }
    }
}

