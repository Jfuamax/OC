<#
.SYNOPSIS
    Effectue la configuration pour WInRM sur l'ordinateur qui exécute le script.

.DESCRIPTION
    Ce script supprime les éventuelles configurations existantes pour WInRM et réalise la configuration pour une utilisation de WInRM en HTTPS à partir du certificat de l'ordinateur obtenu auprès du serveur ADCS.

.EXAMPLE
    PS C:\> .\Script_Config_WInRM_TLS.ps1

.NOTES
    Version				: 1.0
    Auteur				: Maxime Lusseau
    Date de création	: 09/2025
    Organisation		: Barzini
    Github				: https://github.com/Jfuamax/OC/tree/main/Projet_9
	Remarques			: Une GPO est configurée pour activer la transcription Powershell et les fichiers de transcription sont stockés dans le dossier : \\SRV-TST-001\Transcripts$

.HISTORIQUE DES VERSIONS
    1.0		09/2025		Version initiale
#>

## Variables
$port=5986
$RootCA = "Barzini-Root-CA"
$hostname = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname
$certinfo = (Get-ChildItem -Path Cert:\LocalMachine\My\ |? {($_.Subject -Like "CN=$hostname") -and ($_.Issuer -Like "CN=$RootCA*")})
$certThumbprint = $certinfo.Thumbprint

## Activer WInRM
Enable-PSRemoting -Force

## Suppression des WInRM Listener
Get-ChildItem WSMan:\Localhost\Listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse -Force
Get-ChildItem WSMan:\Localhost\Listener | Where -Property Keys -eq "Transport=HTTPS" | Remove-Item -Recurse -Force

## Création du WInRM Listener et une règle pare-feu
if ($certThumbprint){
	New-Item -Path WSMan:\Localhost\Listener -Transport HTTPS -Address * -CertificateThumbprint $certThumbprint -HostName $hostname -Force
	netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=$port
}
else {
	Write-Error "Certificat introuvable"

}
