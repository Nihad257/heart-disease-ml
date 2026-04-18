library(ggplot2)
library(caret)
library(rpart)
library(randomForest)
library(pROC)

getwd()

data <- read.csv("heart-disease-dataset.csv")
str(data)
data
summary(data)
head(data)

data$target <- as.factor(data$target)
data$sex <- as.factor(data$sex)
data$chest_pain_type <- as.factor(data$chest_pain_type)
data$fasting_blood_sugar <- as.factor(data$fasting_blood_sugar)
data$resting_ecg <- as.factor(data$resting_ecg)
data$exercise_angina <- as.factor(data$exercise_angina)
data$st_slope <- as.factor(data$st_slope)
str(data)

colSums(is.na(data))
data$risk_score <- data$resting_bp_s * data$cholesterol

library(caret)
set.seed(123)
train_index <- createDataPartition(data$target,p=0.8,list=FALSE)
trainData <- data[train_index,]
testData <- data[-train_index,]

model_log <- glm(target ~ .,data=trainData, family = "binomial")

library(rpart)
model_tree <- rpart(target ~ .,data=trainData, method = "class")


library(randomForest)
model_rf <- randomForest(target ~.,data=trainData)


prob_log <- predict(model_log, testData,type = "response")


prob_tree <- predict(model_tree, testData, type =  "prob")[,2]

prob_rf <- predict(model_rf, testData, type = "prob")[,2]

pred_log  <- ifelse(prob_log  > 0.5, 1, 0)
pred_tree <- ifelse(prob_tree > 0.5, 1, 0)
pred_rf   <- ifelse(prob_rf   > 0.5, 1, 0)

confusionMatrix(as.factor(pred_log),  testData$target)
confusionMatrix(as.factor(pred_tree), testData$target)
confusionMatrix(as.factor(pred_rf),   testData$target)

library(pROC)

roc_log  <- roc(testData$target, prob_log)
roc_tree <- roc(testData$target, prob_tree)
roc_rf   <- roc(testData$target, prob_rf)

plot(roc_log, col="blue")
plot(roc_tree, col="red", add=TRUE)
plot(roc_rf, col="green", add=TRUE)

auc(roc_log)
auc(roc_tree)
auc(roc_rf)

varImpPlot(model_rf)

install.packages("rpart.plot")
library(rpart.plot)
rpart.plot(model_tree)


summary(model_log)

importance_rf <- importance(model_rf)
write.csv(importance_rf, "rf_feature_importance.csv")

