# Table des matières

- [Présentation rapide](#présentation-rapide)
- [Installation](#installation)
    - [Télécharger ce répositoire](#télécharger-ce-répositoire)
    - [Installer R](#installer-r)
    - [Installer RStudio](#installer-rstudio)
- [Paramétrage](#paramétrage)
    - [Répertoires](#répertoires)
    - [Titre et sous-titre](#titre-et-sous-titre)
    - [Période du rapport](#période-du-rapport)
- [Mode d'emploi](#mode-demploi)
- [Dépannage](#dépannage)
    - [Packages R manquant](#packages-R-manquant)
    - [Tout autre problème](#tout-autre-problème)

# Présentation rapide

Ce programme crée un rapport hebdomadaire standard à partir des données compilées et créées par le [programme de rejet](https://github.com/arthur-shaw/ehcvm-tri-automatique).

Pour l'utiliser, il suffit d'abord de renseigner quelques paramètres, et ensuite de lancer le programme generateReport.R.

Après exécution, on obtient un rapport qui couvre plusieurs indicateurs de suivi--de progrès, de qualité, etc.--en format HTML qui contient la date du rapport dans son nom.

Pour consulter le rapport, il suffit de cliquer dessus afin de l'ouvrir dans un navigateur web quelconque (sans besoin d'internet).

# Installation

## Télécharger ce répositoire

- Cliquer sur le bouton `Clone or download`
- Cliquer sur l'option `Download ZIP`
- Télécharger dans le dossier sur votre machine où vous voulez héberger ce projet

## Installer R

Si ceci n'a pas été fait pour le [programme de rejet](https://github.com/arthur-shaw/ehcvm-tri-automatique) :

- Suivre [ce lien](https://cran.rstudio.com/)
- Cliquer sur le lien approprié pour votre système d'exploitation
- Cliquer sur `base`
- Télécharger et installer

## Installer RStudio

Comme RStudio est requis pour ce programme : 

- Suivre [ce lien](https://www.rstudio.com/products/rstudio/download/)
- Sélectionner RStudio Desktop Open Source License
- Cliquer sur le lien approprié pour votre système d'exploitation
- Télécharger et installer

# Paramétrage 

## Répertoires

- `rejectProjDir`. Répertoire principal du programme de rejet. Dans le chemin, utiliser des slashs au lieu des anti-slashs. En plus, terminer le chemin avec un slash. Par exemple: `C:/mon/chemin/`.
- `reportProjDir`. Répertoire principal du programme de rapport hebdomadaire. Concernant le chemin, suivre les instructions du point ci-haut.

## Titre et sous-titre

Sous le "report title and subtitle", renseigner les paramètres suivants:

- `reportTitle`. Titre du rapport. Figure en haut du rapport
- `reportProjDir` Sous-titre du rapport. Figure juste en dessous du titre.

## Période du rapport

Sous le "report period", au choix, renseigner les paramètres ou laisser intact les valeurs de défaut suivants:

- `reportWeek`. Semaine de la fin de la période du rapport. Par défaut, prend la semaine de l'exécution du programme. Pour ce comportement de défaut, laisser la valeur telle quelle: `reportWeek <- NA`. Si souhaité, indiquer une autre semaine (ou date dans cette semaine). Pour indiquer une date, suivre ce modèle: `ymd("AAAA-MM-JJ")`. Par exemple, le 15 avril, 2019 devient: `ymd("2019-04-15")`.
- `numWeeks`. Indiquer le début de la période du rapport indirectement. Plutôt qu'indiquer la date de début, il faut indiquer le nombre de semaines avant la date de fin (e.g., si numWeeks = 3, les 3 semaines avant le 1er avril). Par défaut, le nombre de semaines est 12--c'est à dire la durée totale estimée de la collecte. Si l'on laisse la valeur de défaut, le rapport couvrira toute la période de collecte à tout moment de la collecte.

## Structure de l'échantillon

Sous "sample design", décrire l'échantillon en remplaçant `NA` avec des chiffres. Ces informations sont utilisées dans le calcul des statistiques de progressions (i.e, pourcentage de l'échantillon bouclés, pourcentage de DRs clôturés).

- `expectedSample`. Taille de l'échantillon (i.e. nombre d'entretiens escomptés). Remplacer `NA` avec un chiffre.
- `numPsuExpected`. Nombre d'unités primaires de sélection (i.e., districts de recensement). Remplacer `NA` avec un chiffre.
- `numIntExpectedPerPsu`. Nombre d'entriens à remplir par unité primaire de sélection (i.e., nombre d'entretiens par DR). Remplacer `NA` avec un chiffre.

# Mode d'emploi

- Ouvrir RStudio
- Ouvrir `generateReport.R`
- Lancer le programme en appuyant sur le bouton `Source` en haut et à droite du programme
- Retrouver dans le répertoire du projet un rapport HTML.
- Cliquer sur ce document HTML pour l'ouvrir dans un navigateur web (sans besoin d'internet)

Le rapport aura un nom qui indique la fin de la période du rapport (ou la date de création). Si l'on crée le rapport le 1er avril, il aura le nom `rapport-2019-04-01.html`.

# Dépannage

## Packages R manquant

Normalement, le programme s'occupe de l'installation de tous les packages nécessaires pour son exécution. Mais si un ou plusieurs packages nécessaires manquent à l'appel, on peut les installer manuellement avec les commandes suivantes (que l'on peut copier, coller, et exécuter dans R Studio). Notez que l'installation de packages nécessite une connexion internet.

```
packagesNeeded <- c(
    "rmarkdown", # to create documents via Markdown and R code blocks
    "haven",    # to injest input Stata files
    "tidyr",    # to reshape attributes data from long to wide; split reject messages
    "dplyr",    # to do basic data wrangling
    "lubridate", # to handle reporting dates and intervals
    "stringr",  # to parse strings for data wranging
    "ggplot2",  # to graph plots
    "hrbrthemes", # to have a clean graph theme
    "viridis",  # to have color-blind-friendly colors in graphs
    "rlang",    # to support tidy eval for functions
    "knitr",    # to have kable tables
    "kableExtra"
)

install.packages(packagesNeeded)
```

## Tout autre problème

Si le problème et d'intérêt général (i.e., vous soupçonnez que d'autres ont le problème), créer un "issue" [ici](https://github.com/arthur-shaw/uemoa-rapport-hebdomadaire/issues).

Si le problème est particulier, contacter l'auteur du programme.
