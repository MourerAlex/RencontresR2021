# RencontresR2021

Ce répertoire contient le code qui a été utilisé pour illustrer notre méthode intitulée "Sparse k-means for mixed data via group-sparse
clustering" [1] lors des RencontresR2021.

Des explications plus spécifiques du code et de la méthode sont disponibles dans les vignettes du package R de la méthode:
https ://cran.r-project.org/web/packages/vimpclust/index.html

Pour les impatients, voici un court exemple d'utilisation de notre code:

```R  
# Packages
## Notre Package
library(vimpclust)
## Packages pour la visualisation
library(ggplot2)
library(gridExtra)
## Package pour le clustering de variables et pour le dataset wine
library(ClustOfVar)

# Première partie : Sparse K means sur données mixtes wine
## Chargement des données
data(wine)
## Run la fonction sparsewkm avec 4 clusters
res <- sparsewkm(X = wine, centers = 4, verbose=0)
## chemins de régularisation
plot(res, what="weights.features", showlegend = FALSE) + geom_vline(xintercept=res$lambda[17], linetype="dashed")
## chemin de variance expliquée
plot(res, what="expl.var") + geom_vline(xintercept=res$lambda[17], linetype="dashed")
## quelles sont les variables sélectionnées (cad avec poids != 0)
rownames(res$W)[which(res$W[,17]!=0)]
```

Toutefois, le code présenté aux RencontresR2021 présente une subtilité. On applique notre méthode `groupsparsewkm`(voir `help(groupsparsewkm)` pour plus de détails) à des groupes de variables trouvés grâce à un clustering de variables effectué avec le package `ClustOfVar` [2]. `ClustOfVar` trouve des groupes de variables mixtes, or notre clustering de données mixtes s'effectue sur des données catégorielles sont recodées par modalités (et non pas sur les variables). Le code qui implémente cette subtilité est disponible dans la "Troisième partie" du fichier "CodeRR2021_SparseKmeansMixData.R".


# Références 
* [1] Chavent, M., Lacaille, J., Mourer, A., Olteanu, M. (2020).Sparse k-means for mixed data viagroup-sparse clustering. In ESANN 2020 proceedings, i6doc.com publ., ISBN 978-2-87587-074-2
* [2] Chavent, M., Kuentz, V., Liquet B., Saracco, J. (2012), ClustOfVar : An R Package for theClustering of Variables.Journal of Statistical Software50, 1-16
