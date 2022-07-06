param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}
'running with full privileges'
set-executionpolicy remotesigned
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
Write-host "My directory is $dir"
$title    = 'Installation de poste'
$question = 'Voulez-vous commencer l''installation ?'
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
Write-Host 'Installation démarré'
winget install --accept-source-agreements 7zip
winget install -e --accept-source-agreements --id Adobe.Acrobat.Reader.32-bit
winget install -e --accept-source-agreements --id Mozilla.Firefox
winget install -e --accept-source-agreements --id Fortinet.FortiClientVPN
$title    = 'Confirmation de l''installation des logiciels'
$question = 'Les logiciels ont-ils tous été installés ?'
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
Write-Host 'Les logiciels ont étés installés.'
$wshShell = New-Object -ComObject "WScript.Shell"
$files = Get-ChildItem (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "Adobe Acrobat DC.lnk")
$files = Get-ChildItem (Join-Path $wshShell.SpecialFolders.Item("AllUsersDesktop") "HP Support Assistant.lnk")
foreach ($file in $files) {
$shortcut = $wshShell.CreateShortcut($file.FullName)
if ($shortcut.TargetPath -eq "whatever") {
Remove-Item $file
}
Powercfg /Change monitor-timeout-ac 0
Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0
& $Env:WinDir\system32\useraccountcontrolsettings.exe
}
$title    = 'Debug'
$title    = 'Dossier-Technique'
$question = 'Le dossier technique est-il complet ? Si oui, nous passons à la suite.'
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
cmd.exe /c 'MD D:/%COMPUTERNAME%-DossierTechnique'
Timeout /T 1
cmd.exe /c "wmic csproduct> D:/%COMPUTERNAME%-DossierTechnique\Numero_de_serie.txt"
Write-Host 'Dossier technique confirmé'
Start-Process "https://ftp.hp.com/pub/caps-softpaq/cmit/HPIA.html"
Add-Computer -DomainName ufse.local -Restart
} else {
Write-Host 'Annulé'
}
}
}
