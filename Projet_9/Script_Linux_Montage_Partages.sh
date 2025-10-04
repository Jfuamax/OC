#!/bin/bash

# ===================================================================================================
# Synopsis
#	Effectue le montage des dossiers partagés accessibles à l'utilisateur qui exécute le script.
#
# Description
#	Ce script réalise les montages du dossier personnel et des dossiers des services accessibles
#	à l'utilisateur (suivant son appartenance aux différents groupes GDL_DATA_XXX_RO/RW).
#
# Usage
#	./Script_Linux_Montage_Partages.sh
# Notes
#	Version 		: 1.0
# 	Auteur 			: Maxime Lusseau
# 	Date 			: 09/2025
#	Organisation	: Barzini
#   Github			: https://github.com/Jfuamax/OC/tree/main/Projet_9
#
# Historique des versions
#	1.0		09/2025		Version initiale
#
# Dépendances
#	- krb5-user
#	- cifs-utils
#	- keyutils
# ===================================================================================================

## Variables générales
username=$(whoami)
server="srv-tst-001.barzini.internal"
mount_cruid=0
mount_uid=$(id -u)
mount_gid=0

list_services="DATA_ADM DATA_DEV DATA_GPH DATA_SND DATA_TST DATA_SIT DATA_RH"


## Configuration d'un fichier de logs pour le script
# Récupérer le nom du script sans extension
script_name_ext=$(basename "$0")
script_name="${script_name_ext%.*}"

# Dossier contenant les logs des scripts
log_folder="/var/log/barzini_scripts"

# Fichier pour stocker les logs de l'exécution du script
log_file="${log_folder}/${script_name}.log"

# Ajouter une démarcation dans le fichier de logs avant le début de l'exécution du script
echo "############## [$(date +'%Y-%m-%dT %H:%M:%S')] Exécution du script par l'utilisateur : $username ##############" >> "$log_file"

# Redirection vers le fichier de logs
exec 3>&1 1>>"$log_file" 2>&1

# Affichage du messge d'erreur dans le terminal si erreur
trap "echo 'ERREUR: vérifier $log_file pour plus de détails.' >&3" ERR

# Enregistrement des commandes avec la date dans le fichier de logs
trap '{ set +x; } 2>/dev/null; echo -n "[$(date +"%Y-%m-%dT %H:%M:%S")]  "; set -x' DEBUG


## Montage du dossier Perso
# Construction du chemin du dossier partagé et du montage
path_perso="//${server}/${username}\$"
path_perso_mount="/home/BARZINI/${username}/Perso"

# Création du dossier de montage
mkdir -p $path_perso_mount

# Montage du dossier partagé
sudo mount -t cifs $path_perso $path_perso_mount -o sec=krb5,cruid=$mount_cruid,uid=$mount_uid,gid=$mount_gid,vers=3.1.1,noperm,dir_mode=0770,file_mode=0770,iocharset=utf8
echo "Montage réussi pour le dossier Perso." >&3


## Montages des dossiers des services
for service in $list_services; do
	if id -nG | tr ' ' '\n' | grep -i $service; then
		# Construction des chemins du dossier partagé et du montage
		path_service="//${server}/${service}\$"
		path_service_mount="/home/BARZINI/${username}/Services/${service}"

		# Création du dossier de montage
		mkdir -p $path_service_mount

		# Montage du dossier partagé
		sudo mount -t cifs $path_service $path_service_mount -o sec=krb5,cruid=$Mount_CRUID,uid=$Mount_UID,gid=$Mount_GID,vers=3.1.1,noperm,dir_mode=0770,file_mode=0770,iocharset=utf8
		echo "Montage réussi pour le dossier $service." >&3
	fi
done
