#transformations in R
apropos("AppliedPredictiveModeling")
RSiteSearch("AppliedPredictiveModeling", restrict = "packages")

install.packages("AppliedPredictiveModeling")
library(AppliedPredictiveModeling)
data(segmentationOriginal)
segData <- subset(segmentationOriginal, Case == "Train")
cellID <- segData$Cell 
class <- segData$Class 
case <- segData$Case 
# Now remove the columns 
segData <- segData[, -(1:3)]
#The original data contained several“status”columns which 
#were binary versions of the predictors. To remove these, 
#we ﬁnd the column names containing "Status" and remove them:
statusColNum <- grep("Status", names(segData))
statusColNum
segData <- segData[, -statusColNum]
head(segData)
?apply
# e1071 package calculates the sample skewness statistic 
#for each predictor:
install.packages("e1071")
library(e1071)
#for one predictor
skewness(segData$AngleCh1)
#all predictors are numeric, so we can apply skewness function
#across all columns
skewValues <- apply(segData, 2, skewness)
head(skewValues)
#Using these values as a guide, the variables 
#can be prioritized for visualizing the distribution
install.packages("caret")
library(caret)
summary(segData$AreaCh1)
CH1AreaTrans <- BoxCoxTrans(segData$AreaCh1)
CH1AreaTrans
hist(segData$AreaCh1)

#original data
head(segData$AreaCh1)
#after transformation
predict(CH1AreaTrans, head(segData$AreaCh1))
#i still dont understand why the predict function returns
#numeric vector of transformed values
#actually...model is the first argument, i kinda get it now

#actual math behind the hood for first obs transformation
#this is essentially the model 
(819^(-.9) - 1)/(-.9)

#whole dataset
transformation<-predict(CH1AreaTrans, segData$AreaCh1)
hist(transformation)
?predict

#PCA
pcaObject <- prcomp(segData, center = TRUE, scale. = TRUE)
# Calculate the cumulative percentage of variance which each 
#component > accounts for. 
percentVariance <- pcaObject$sd^2/sum(pcaObject$sd^2)*100  
percentVariance[1:3]
#The transformed values are stored in pcaObject as a sub-object called x:
head(pcaObject$x[, 1:5])
#The another sub-object called rotation stores the variable loadings, 
#where rows correspond to predictor variables and columns are 
#associated with the components:
head(pcaObject$rotation[, 1:3])

#another caret function preProcess applies this transformation to 
#a set of predictors

#To administer a series of transformations to multiple data sets, 
#the caret class preProcess has the ability to transform, center, scale, or impute values, 
#as well as apply the spatial sign transformation and feature extraction

trans <- preProcess(segData, method = c("BoxCox", "center", "scale", "pca"))
trans
#19 variables capture 95 % of variance across 119 variables

# Apply the transformations: 
transformed <- predict(trans, segData) 
# These values are different than the previous PCA components since  
# they were transformed prior to PCA 
head(transformed[, 1:5])
rm(simulations)
View(transformed)

#Filtering
nearZeroVar(segData)
# When predictors should be removed, a vector of integers is 
# returned that indicates which columns should be removed

#correlations between predictor variables, aka multicollinearity
correlations <- cor(segData)
dim(correlations)
correlations[1:4, 1:4]

#reveal clusters of highly correlated predictors
install.packages("corrplot")
library(corrplot)
corrplot(correlations, order = "hclust")

#filter based on correlations
highCorr<- findCorrelation(correlations, cutoff = 0.75)
length(highCorr)
head(highCorr)
#remove columns with high correlations
#recommeneded for deletion by findCorrelation
filteredSegData <- segData[, -highCorr]

#Creating Dummy Variables
library(caret)
head(cars)
head(carSubset)
#use dummyVars function

#excercise 
install.packages("mlbench")
library(mlbench)
data(Glass)
str(Glass)

#type is factor and non numeric
Glass_notype <- Glass[,1:9]
#explore predictors
skewValues_glass <- apply(Glass_notype, 2, skewness)
skewValues_glass
hist(Glass$K)
hist(Glass$Ca)
hist(Glass$Ba)
hist(Glass$RI)
hist(Glass$Na)
hist(Glass$Mg)
hist(Glass$Al)
hist(Glass$Si)
hist(Glass$Fe)
#K, Ca, Ba, Al, Fe, Mg are skewed

#explore correlation across predictors
correlations_glass <- cor(Glass_notype)
corrplot(correlations_glass, order = "hclust")

#there are outliers

#improvements
#filter based on correlation
highCorr_glass<- findCorrelation(correlations_glass, cutoff = 0.75)
length(highCorr_glass)
head(highCorr_glass)
#remove columns with high correlations
#recommeneded for deletion by findCorrelation
filteredSegData <- Glass_notype[, -highCorr_glass]

install.packages("mlbench")
library(mlbench)
data(Soybean)
str(Soybean)

install.packages("e1071")
library(e1071)
apply(Soybean, 2, skewness)
?skewness

install.packages("ggplot2")
library(ggplot2)

#histogram for factor varaib
barplot(table(Soybean$Class))
barplot(table(Soybean$seed))
barplot(table(Soybean$date))
barplot(table(Soybean$plant.stand))
barplot(table(Soybean$precip))

#histogram over all variables in dataset
install.packages("plyr")
install.packages("psych")
library(plyr)
library(psych)
multi.hist(mpg[,sapply(mpg, is.numeric)])
multi.hist(Soybean[,sapply(Soybean, is.numeric)])
head(mpg)
head(Soybean)

#missing data by variables
apply(is.na(Soybean), 2, sum)

#exploring missing data using mice package
install.packages("mice")
library(mice)
md.pattern(Soybean)
#visual representation
install.packages("VIM")
library(VIM)
aggr_plot <- aggr(Soybean, col = c('navyblue', 'red'),
                  numbers=TRUE, sortVars = TRUE, labels=names(Soybean),
                  cex.axis=.7, gap=3, ylab=c("Histogram of missing data", "Pattern"))
