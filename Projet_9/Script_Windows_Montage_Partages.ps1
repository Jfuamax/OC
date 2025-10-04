<#
.SYNOPSIS
    Effectue le montage des dossiers partagés accessibles à l'utilisateur qui exécute le script.

.DESCRIPTION
    Ce script supprime tous les partages qui utilisent les lettres reservées pour les dossiers des services et le dossier personnel (définies dans les variables $Letter_Perso et $MapDriveLetter) puis réalise les montages du dossier personnel et des dossiers des services accessibles à l'utilisateur (suivant son appartenance aux différents groupes GDL_DATA_XXX_RO/RW).

.EXAMPLE
    PS C:\> .\Script_Windows_Montage_Partages.ps1

.NOTES
    Version		: 1.0
    Auteur		: Maxime Lusseau
    Date de création	: 09/2025
    Organisation	: Barzini
    Github		: https://github.com/Jfuamax/OC/tree/main/Projet_9

.REMARQUES
    Une GPO est configurée pour activer la transcription Powershell et les fichiers de transcription sont stockés dans le dossier : \\SRV-TST-001\Transcripts$

.HISTORIQUE DES VERSIONS
    1.0		09/2025		Version initiale
#>

#Variables
$Username = (Get-ChildItem Env:USERNAME).Value
$UserGroups = whoami /groups | Select-String "BARZINI\\"
$Path_Perso = "\\srv-tst-001\" + $Username + "$"
$Letter_Perso = "P"
$MapDriveLetter = @{
    "DATA_ADM" = "T"
    "DATA_DEV" = "U"
    "DATA_GPH" = "V"
    "DATA_SND" = "W"
    "DATA_TST" = "X"
    "DATA_SIT" = "Y"
    "DATA_RH" = "Z"
}
$ReservedDriveLetters = $MapDriveLetter.Values + $Letter_Perso


## Supprimer tous les partages montés avec les lettres réservées
Foreach($DriveLetter in $ReservedDriveLetters){
	$mapping = Get-SmbMapping -LocalPath "${DriveLetter}:" -ErrorAction SilentlyContinue
	if($mapping) {
		try{
			Remove-SmbMapping -LocalPath "${DriveLetter}:" -Force
			Write-Output "Suppression réussie du partage monté avec la lettre ${DriveLetter}:"
		}
		catch{
			Write-Error "Erreur lors de la suppression du partage sur la lettre $DriveLetter : $_"
		}
	}
	else {
		Write-Output "Aucun partage monté avec la lettre ${DriveLetter}:"
	}
}

## Montage du partage Perso
# Montage du partage
try{
	New-PSDrive -Name $Letter_Perso -PSProvider "FileSystem" -Root $Path_Perso -Persist
	Write-Output "Création réussie du partage pour le dossier Perso avec la lettre $Letter_Perso."
}
catch{
	Write-Error "Erreur lors de la création du partage pour le dossier Perso avec la lettre $Letter_Perso : $_"
}

# Changer le nom du disque Perso
$shell = New-Object -ComObject Shell.Application
$shell.NameSpace("${Letter_Perso}:").Self.Name = "Perso"

## Montage des partages des Services
Foreach($DriveName in $MapDriveLetter.Keys){
	$GroupName = "BARZINI\\GDL_" + $DriveName
	$DrivePath = "\\srv-tst-001\" + $DriveName + "$"
	if ($UserGroups -match $GroupName) {
		try{
			New-PSDrive -Name $($MapDriveLetter.$DriveName) -PSProvider "FileSystem" -Root $DrivePath -Persist
			$shell.NameSpace("$($MapDriveLetter.$DriveName):").Self.Name = $DriveName
			Write-Output "Création réussie du partage de $DriveName avec la lettre $($MapDriveLetter.$DriveName)."
		}
		catch{
			Write-Error "Erreur lors de la création du partage pour $DriveName avec la lettre $($MapDriveLetter.$DriveName) : $_"
		}
	}

}
