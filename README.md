# Table des matières

- [Présentation rapide](#présentation-rapide)
- [Guide de lecture du rapport](#guide-de-lecture-du-rapport)
    + [Graphiques](#graphiques)
    + [Tableaux](#tableaux)
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

# Guide de lecture du rapport

Le rapport contient deux grands chaptitres. Le premier porte sur les indicateurs de progrès et de performance de la collecte. Le second concerne les indicateurs de qualité des données.

Dans chaque chapitre se trouvent des graphiques et des tableaux sur les indicateurs choisis. Les graphiques concernent les équipes. Les tableaux concernent les enquêteurs.

## Graphiques

Les graphiques concernent toute la période du rapport.

Dans les graphiques, l'on voit des informations différentes selon que le rapport concerne une seule semaine ou plusieurs semaines. Voici une explication de chaque cas :

- **Une seule semaine.** Affiche la moyenne de chaque équipe, classe les équipes par la moyenne (en ordre décroissant), et donne la moyenne globale comme une ligne rouge verticale.
- **Plusieurs semaines.** Donne l'évolution de la moyenne de chaque équipe (par rapport à l'évolution des autres). La graphique est composée d'une sous-graphique par équipe. Chaque sous-graphique affiche la courbe de l'équipe concernée en couleur, pour la mettre en exergue, et affiche la courbe des autres équipe en gris, pour faciliter les comparaisons. L'axe Y donne le niveau de l'indicateur. L'axe X donne la semaine (ou le jour) de collecte.

Les exceptions à cette description sont les graphiques sur:

- Les motifs de non-réponse. 
- Calories par personne par jour.

Ces graphiques donnent des statistiques au niveau global.

Pour le motif de non-réponse, la graphique donne le pourcentage pour chaque motif.

Pour les calories par personne par jour, la graphique donne pour chaque semaine de collecte les informations suivantes concernant les calories :

- Distribution de calories. Les points représentent le niveau de calories pour un entretien. Les lignes qui entourent les point représentent la distribution de calories.
- Moyenne de calories. La ligne rouge tracent la moyenne globale.
- Vraisemblance. La couleur des points indique la vraisemblance. Le rouge désigne des points aberants--en dessous de 800 ou en dessus de 4000 calories par personne par jour. L'orange désigne des niveaux de consommation acceptables mais légèrement doubteux. Le gris désigne des niveaux acceptables. 

## Tableaux

Les tableaux concernent la dernière semaine du rapport, mais également les trois dernières semaines à commencer par la dernière semaine.

Les tableaux concernent les enquêteurs avec les moyennes les plus basses/hautes (selon l'indicateur)--formellement les enquêteurs dans la 1ière/10ième décile (selon l'indicateur). Ils sont composés des colonnes suivantes:

- **Enquêteur.** Nom d'utilisateur de l'enquêteur concerné.
- **Moyenne cette semaine.** Moyenne pour l'enquêteur pendant la semaine concernée.
- **Moyenne cumulative.** Moyenne pour l'enquêteur pendant la période du rapport. 
- **Écart de la moyenne globale.** Différence pour l'enquêteur entre sa moyenne cette semaine et la moyenne globale pendant la période du rapport.
- **N. semaines à l'extrême.** Nombre de semaine pendant les trois dernière que l'enquêteur a été dans la 1ière/10ième décile (selon l'indicateur).

En comparant la moyenne cette semaine et la moyenne cumulative pour un enquêteur donné, on peut voir l'écart entre la moyenne actuelle et la moyenne habituelle.

En comparant la moyenne cette semaine (pour un enquêteur donné) et l'écart de la moyenne globale (pour la collecte), on peut voir l'écart entre l'enquêteur et les autres enquêteurs.

En consultant la colonne sur le nombre de semaines à l'extrême, on peut voir si l'enquêteur a souvent des moyennes extrêmes par rapport à la distribution des moyennes des enquêteurs.

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

## Générer le rapport standard

Pour créer le rapport :

- Ouvrir RStudio
- Ouvrir `generateReport.R`
- Lancer le programme en appuyant sur le bouton `Source` en haut et à droite du programme
- Retrouver dans le répertoire du projet un rapport HTML.
- Cliquer sur ce document HTML pour l'ouvrir dans un navigateur web (sans besoin d'internet)

Le rapport aura un nom qui indique la fin de la période du rapport (ou la date de création). Si l'on crée le rapport le 1er avril, il aura le nom `rapport-2019-04-01.html`.

## Ajouter du contenu qui n'est pas créé par le rapport

Pour ajouter du contenu qui n'est pas envisagé par le rapport standard, l'approche est simple, mais diffère légèrement selon que l'on veut intégrer du texte ou des graphiques.

Mais le flux de travail pour le faire, grosso modo, consiste des étapes suivantes:

- Créer le rapport en lançant `generateReport.R`
- Identifier là où intégrer du contenu supplémentaire
- Ouvrir le document `rapport_hebdomadiare_EHCVM.Rmd`
- Ajouter le contenu
- Sauvegarder `rapport_hebdomadiare_EHCVM.Rmd`
- Créer le rapport à nouveau en lançant `generateReport.R`

En ce faisant, évitez de toucher aux blocs de code. Dans le document, il y a deux types de blocs. Le premier, trouvé au tout début du document entre `---` et `---`, donne le titre, le sous-titre, et le format du document. Les second, semé tout au long du document, contient des syntaxes R pour transformer des données, créer des graphiques, et afficher des tableaux. Ces blocs se trouvent entre les clôtures du sytle suivant :

````
```{r numIntCompleted, echo = FALSE, warning = FALSE, message = FALSE}

# le nom numIntCompleted indique le nom interne du bloc

# les options pour comment gérer le produit du bloc sont indiquées par la suite
# par exemple, message = FALSE empêche l'affichage dans le document de
# messages affichés lors de l'exécution du code

```
````

Pour chaque type, veuillez ne pas toucher au contenu. Sinon, on peut créer des problèmes avec le rapport qui peuvent être difficiles à résoudre. 

## Du texte

Pour ajouter du texte, il suffit de 

- Choisir le type de text
- Composer le texte
- Ajouter la syntaxe nécessaire pour obtenir l'affichage voulu

Pour l'essentiel, il y a trois types de textes:

1. Texte simple
2. Texte dans une liste
3. Texte des titres de section

Pour le premier, le texte est écrit comme il apparaît sur le papier. Pour le second type, il suffit de taper `-` devant chaque élément de la liste (ou un chiffre pour les listes chiffrées). Pour le troisième le nombre de `#` indique l'importance du titre de section: `#` indique un titre de premier plan (H1 en Word ou `<h1>` en HTML),  `##` indique un titre de second plan (H2 en Word ou `<h2>` en HTML), et ainsi de suite. 

Pour en savoir plus, lire [ici](https://bookdown.org/yihui/rmarkdown/markdown-syntax.html)

## Des graphiques

Pour ajouter des graphiques, la démarche consiste à

- Créer la graphique avec des outils externes (e.g., Stata)
- Sauvegarder la graphique comme image (e.g., format PNG, JPEG, etc.)
- Créer un lien vers l'image dans le document 

Pour en savoir plus, lire le troisième paragraphe [ici](https://bookdown.org/yihui/rmarkdown/markdown-syntax.html#inline-formatting) et l'explication plus détaillée [ici](https://pandoc.org/MANUAL.html#images) 

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
