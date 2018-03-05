# Applied-Predictive-Modeling
#Chp 4 Over fitting & Model tuning

library(AppliedPredictiveModeling)
library(caret)
data(twoClassData)

str(predictors)
str(classes)
head(classes)
head(predictors)

set.seed(1)
?createDataPartition
trainingRows <- createDataPartition(classes, 
                                    p = 0.80,
                                    list = FALSE)
head(trainingRows)

trainPredictors <- predictors[trainingRows,]
head(trainPredictors)
TrainClasses <- classes[trainingRows]
TrainClasses

#now test
testPredictors <- predictors[-trainingRows,]
testClasses <- classes[-trainingRows]

#adding 'times' for multiple splits

set.seed(1)
repeatedSplits <- createDataPartition(TrainClasses, p =0.8,
                                       times= 3)
#kfold splits
set.seed(1)
?createFolds
cvSplits <- createFolds(TrainClasses, k = 10,
                        returnTrain = TRUE)
#return train specifies with replacement 
#or without, returnTrain = TRUE is with replacement
cvSplits

#referencing a list of list
fold1 <- cvSplits[[1]]
fold1

#to get the first 90% of the data (first fold)
cvPredictors1 <- trainPredictors[fold1,]
cvPredictors1
cvClasses1 <- TrainClasses[fold1]
nrow(trainPredictors)
nrow(cvPredictors1)

#knn3 function in caret for k nearest neihbor 
#running model as matrix instead of formulate interface
#for greater computational effeciency
trainPredictors<- as.matrix(trainPredictors)
knnFit <- knn3(x= trainPredictors, y = TrainClasses, k=5)
knnFit
#predicting new samples
testPredictions <- predict(knnFit, newdata = testPredictors, 
                           type = "class")
testPredictions
str(testPredictions)

#determination of tuning parameters

#train function in caret is bad ass
#has built in modules for 144 models, algos for choosing best
#an parallel processing capabilities

#tuning cost parameter
data(GermanCredit)
set.seed(1056)
data(GermanCreditTrain)
svm <- train(Class ~.,
             data = GermanCreditTrain,
             method = "svmRadial")

#excercises 

