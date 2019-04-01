# Table des matières

- [Présentation rapide](#présentation-rapide)
- [Installation](#installation)
- [Paramétrage](#paramétrage)
- [Mode d'emploi](#mode-demploi)
- [Dépannage](#dépannage)

# Présentation rapide

Crée un rapport hebdomadaire en puisant dans les données créées par le programme de rejet.

# Installation

- Télécharger les fichiers depuis le répositoire

# Paramétrage 

## Répertoires

- `rejectProjDir`. Répertoire principal du programme de rejet. Dans le chemin, utiliser des slashs au lieu des anti-slashs. En plus, terminer le chemin avec un slash. Par exemple: `C:/mon/chemin/`.
- `reportProjDir`. Répertoire principal du programme de rapport hebdomadaire. Concernant le chemin, suivre les instructions du point ci-haut.

## Titre

- `reportTitle`. Titre du rapport. Figure en haut du rapport
- `reportProjDir` Sous-titre du rapport. Figure juste en dessous du titre.

## Période du rapport

- `reportWeek`. Semaine de la fin de la période du rapport. Par défaut, prend la semaine de l'exécution du programme. Pour ce comportement de défaut, laisser la valeur telle quelle: `reportWeek <- NA`. Si souhaité, indiquer une autre semaine (ou date dans cette semaine). Pour indiquer une date, suivre ce modèle: `ymd("YYYY-MM-DD")`. Par exemple, le 15 avril, 2019 devient: `ymd("2019-04-15")`
- `numWeeks`. Indiquer le début de la période du rapport par une nombre de semaine avant la date du fin de rapport. 

# Mode d'emploi

- Ouvrir RStudio
- Ouvrir `generateReport.R`
- Lancer le programme en appuyant sur le bouton `Source` en haut et à droite du programme

# Dépannage
