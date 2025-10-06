:: =============================================
:: SCRIPT : Lancer_script.bat
:: DESCRIPTION : Lancer les scripts ci-dessous au démarrage
::
:: AUTEUR     : Maxime Lusseau
:: VERSION    : 1.0
:: DATE       : 09/2025
::
:: HISTORIQUE DES VERSIONS
:: 1.0        : Version initiale
:: =============================================

:: Désactiver l'affichage des commandes exécutées
@echo off

:: Exécution du script PowerShell pour le montage des dossiers partagés
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "\\barzini.internal\SYSVOL\barzini.internal\scripts\Script_Windows_Montage_Partages.ps1"
