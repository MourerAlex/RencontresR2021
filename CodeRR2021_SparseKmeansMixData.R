
# Packages
## Notre Package
library(vimpclust)
## Packages pour la visualisation
library(ggplot2)
library(gridExtra)
## Package pour le clustering de variables et pour le dataset wine
library(ClustOfVar)
## Package pour la fonction splitmix, qui sépare un jeu de données mixtes en 2 jeux de données: variables quanti et variables quali
library(PCAmixdata)
## Package pour la visu de dendogramme
library(dendextend)

# Première partie : Sparse K means sur données mixtes wine
## Chargement des données
data(wine)
## Run la fonction sparsewkm avec 4 clusters
res <- sparsewkm(X = wine, centers = 4, verbose=0)
## chemins de régularisation
p1 <- plot(res, what="weights.features", showlegend = FALSE) + geom_vline(xintercept=res$lambda[17], linetype="dashed")
## chemin de variance expliquée
p2 <- plot(res, what="expl.var") + geom_vline(xintercept=res$lambda[17], linetype="dashed")
grid.arrange(p1, p2, nrow = 1)
## quelles sont les variables sélectionnées (cad avec poids != 0)
varsel <- rownames(res$W)[which(res$W[,17]!=0)]
knitr::kable(matrix(varsel, nrow=2),
             caption="10 variables sélectionnées")

# Deuxième partie : Clustering de variables
## Découpage du jeu de données en deux groupes de variables: quanti et quali
X.quanti <- splitmix(wine)$X.quanti
X.quali <- splitmix(wine)$X.quali
## Clustering de variables avec la fonction hclustvar du package ClustOfVar
tree <- hclustvar(X.quanti, X.quali)
#plot(tree, main="Résultat du package ClustOfVar", cex.main=1)
#rect.hclust(tree, k=7)

### affichage du dendogramme du clustering de variables
dend <- as.dendrogram(tree)
indexcol <- rep(NA, length(varsel))
for (i in 1:length(varsel))
  indexcol[i] <- which(labels(dend) == varsel[i])
#labels(dend)[indexcol]
tocol <- rep(1,31)
tocol[indexcol] <- 2

par(mar = c(12,2,2,2))

dend %>% 
  set("labels_col", tocol) %>%  # change color 
  set("labels_cex", 1)   %>%  # change size
  plot(main="Résultat du package ClustOfVar", cex.main=1)
dend %>% rect.dendrogram(k=7, 
                         border = 8, lty = 5, lwd = 2) # nombre de clusters = 7

# Troisième partie : Clustering de groupes mixtes de variables
## découper l'arbre en 7 clusters
cl <- cutreevar(tree, k=7)$cluster
## Les groupes sont défini sur les variables: on affecte à chaque modalité le groupe à laquelle la variable d'où elle provient appartient
groupes <- c(cl[-c(30,31)],rep(cl[30],3), rep(cl[31],4))
## on récupère les données transformées: cad recodées et normalisées
X <- res$X.transformed
## Les noms des groupes sont affectés
names(groupes) <- colnames(X)

### Fonction group sparse K means avec les données recodées et les groupes donnés par le clustering de variable (et "étendus" aux modalités)
res2 <- groupsparsewkm(X, centers = 4, index = groupes, verbose = 0)
p1 <- plot(res2, what = "weights.features") + geom_vline(xintercept=res2$lambda[15], linetype="dashed")
p2 <- plot(res2, what="expl.var") + geom_vline(xintercept=res2$lambda[15], linetype="dashed")
grid.arrange(p1, p2, nrow = 1)
# rand(res$cluster[,17], res2$cluster[,15]) # même partition obtenue que précédemment

### mise en forme des résultats
varsel1 <- rownames(res$W)[which(groupes ==5)]
varsel2 <- rownames(res$W)[which(groupes ==4)]
varsel3 <- rownames(res$W)[which(groupes ==2)]
varsel <- matrix("", 9, 3)
varsel[1:7,3] <- varsel1
varsel[,2] <- varsel2
varsel[1:4,1] <- varsel3
colnames(varsel) <- c("Group2", "Group 4", "Group 5")
knitr::kable(varsel,
             caption="Groupes sélectionnées", format="latex")
