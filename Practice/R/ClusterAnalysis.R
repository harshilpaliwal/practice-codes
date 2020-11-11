library(alr4)
attributes(BigMac2003)
region=as.factor(c("EU","EU","AUNZ","AS","EU","EU","EU","SA","EU","EU","EU","EU","SA","SA","NA",
                   "EU","AF","EU","EU","EU","EU","AS","AF","AS","AF","AS","EU","AS","AF","SA","EU","EU","EU","NA",
                   "EU","EU","EU","AF","AS","NA","NA","EU","NA","EU","AS","AF","NA","EU","EU","EU","EU","SA","EU",
                   "SA","SA","AS","AS","AS","EU","EU","AUNZ","AS","EU","AF","AS","NA","EU","EU","EU"))
region4 = region;
levels(region4) = c("AF","AS","N","N","N","SA")

#1
bm <- data.frame(FoodIndex=scale(BigMac2003$FoodIndex), Bus=scale(BigMac2003$Bus), Apt=scale(BigMac2003$Apt), 
                 TeachNI=scale(BigMac2003$TeachNI), TeachHours=scale(BigMac2003$TeachHours), row.names=row.names(BigMac2003))
#2
distance_cor <- as.dist((1-abs(cor(t(bm[,]), method = "pearson"))))
distance_manhattan <- dist(bm, method = "minkowski", diag = FALSE, p = 1) #also d2 <- dist(bm, method = "manhattan")
distance_euclidean <- d2 <- dist(bm, method = "minkowski", diag = FALSE, p = 2) #also d2 <- dist(bm, method = "euclidean")

#dim() -> retrieve or set the dimension of an object dim(as.matrix(d1))

#3
library(cluster)
dg_cor <- diana(x=distance_cor, diss=TRUE)
plot(dg_cor)

#4
ag_single <- agnes(x=distance_euclidean, diss = TRUE, method = "single")
#alt, method param, values: "single", "complete", "weighted", "ward"
plot(ag_single)

#5
library(ggplot2)
library(clusterCrit)

km <- kmeans(bm[,c("FoodIndex", "Apt")], centers = 5) #try 3, 4, 5
bm_c <- data.frame(bm, cluster=factor(km$cluster))
ggplot(bm_c, aes(x=bm$FoodIndex, y=bm$Apt, color=cluster)) + geom_point() 

km_int <- intCriteria(traj=as.matrix(bm[,c("FoodIndex", "Apt")]), km$cluster, "silhouette")
km_int

if(nclusters==4){
  km_ext <- extCriteria(km$cluster, as.integer(region4), "Rand")
  print(km_ext)
}


#6
library("EMCluster")

nclusters = 4 #try 3, 4, 5
em = init.EM(x=bm[,c("FoodIndex", "Apt")], nclass=nclusters, method = "em.EM")
em_c = emcluster(x=bm[,c("FoodIndex", "Apt")], em, assign.class = TRUE)

em_df <- data.frame(em_c, cluster=factor(em$nclass))
ggplot(em, aes(x=bm$FoodIndex, y=bm$Apt, color=cluster)) + geom_point()

em_int <- intCriteria(traj=as.matrix(bm[,c("FoodIndex", "Apt")]), as.integer(em$class), "silhouette")
if (nclusters == 4) {em_ext <- extCriteria(as.integer(em$class), as.integer(region4), "Rand") }

#22
library(e1071)

golf_train<-data.frame(
  temp=c("hot","hot","hot","mild","cool","cool","cool","mild","cool","mild","mild","mild","hot","mild"),
  hum=c("h","h","h","h","n","n","n","h","n","n","n","h","n","h"),
  windy=c("f","t","f","f","f","t","t","f","f","f","t","t","f","t"),
  play=c("n","n","y","y","y","n","y","n","y","y","y","y","y","n"))
golf_test<-data.frame(temp=c("cool","cool","hot"),hum=c("n","n","h"),
                      windy=c("t","f","t"),play=c("n","y","n"))
#a)
library(e1071)
nb <- naiveBayes(play~temp+hum, data = golf_train)
predict(nb, golf_test)

#b)
library(rpart)
library(MASS)
library(hmeasure)
dectree_control = rpart.control(minsplit = 2, minbucket = 1, xval = 3)
dectree <- rpart(play~temp+hum, data = golf_train, control = dectree_control)
dectree_pred <- data.frame(class = predict(dectree, golf_test, type = "class"),
                           prob = predict(dectree, golf_test, type = "prob"))
dectree_hm <- HMeasure(golf_test$play, dectree_pred$prob.y)
print(paste("Error rate: ", dectree_hm$metrics$ER))
print(paste("AUC :", dectree_hm$metrics$AUC))

#c)
summary(iris)
linrm <- lm(data = iris, formula = Sepal.Length~Petal.Length+Petal.Width)
summary(linrm)
hist(residuals(linrm))
iris_test <- data.frame(Petal.Length = c(4, 3), Petal.Width = c(1, 3))
predict(linrm, newdata = iris_test)





dtrain<-data.frame(X=c("a","a","a","a","a","a","b","b","b","b"),Y=c("+","+","+","+","-","-","+","-","-","-"))
dtest<-data.frame(X=c("a","a","b","b"),Y=c("+","-","+","-"))
nb <- naiveBayes(Y~X, data = dtrain)
predict(nb, golf_test)
