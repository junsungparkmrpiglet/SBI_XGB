# function test

# Read the Excel file
dataset1 <- read_excel("C:/download/1. SBI_development.xlsx")
model <- xgb.load("C:/download/SBI_xgboost_model_train_test_split.model")

#inputs
#split dataset
set.seed(2000)
split <- sample.split (dataset1$SBI, SplitRatio = 0.6)
train_set <- subset(dataset1, split == TRUE)
test_set <- subset(dataset1, split == FALSE)
test.y <- as.matrix(test_set[,1])
test.x <- as.matrix(test_set[,2:30])

#performance in training test_set
proability_test <- predict(model, newdata = test.x)
test_set$proability_test <- cbind(proability_test)
res = val.prob(test_set$proability_test, test_set$SBI, m=60, cex=.5)
val_m1 <- val.prob(test_set$proability_test, test_set$SBI,
                   pl = FALSE)
pander(val_m1)

#performance in external validation
dataset2 <- read_excel("C:/download/1. SBI_validation.xlsx")
test.X <- as.matrix(dataset2[,2:30])
probability_validation <- predict(model, newdata = test.X)
dataset2$probability_validation <- cbind(probability_validation)
res = val.prob(dataset2$probability_validation, dataset2$SBI, m=60, cex=.5)
val_m2 <- val.prob(dataset2$probability_validation, dataset2$SBI,
                   pl = FALSE)
pander(val_m2)


best_threshold_cost_based <- 0.088
best_threshold_youden <-0.335



#Calculating SE/SP by Youden index in test_set
predictions5 <- ifelse(test_set$proability_test >= best_threshold_youden, 1, 0)
TP5 <- sum(predictions5 == 1 & test_set$SBI == 1)
FN5 <- sum(predictions5 == 0 & test_set$SBI == 1)
TN5 <- sum(predictions5 == 0 & test_set$SBI == 0)
FP5 <- sum(predictions5 == 1 & test_set$SBI == 0)
sensitivity5 <- TP5 / (TP5 + FN5)
specificity5 <- TN5 / (TN5 + FP5)
PPV5 <- TP5 / (TP5 + FP5)
NPV5 <- TN5 / (FN5 + TN5)
PLR5 = sensitivity5 / (1 - specificity5)
NLR5 = (1 - sensitivity5) / specificity5
Accuracy5 <- (TP5 + TN5) / (TP5 + FN5 + TN5 + FP5)
results1 <- data.frame(
  Metric = c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Positive LR", "Negative LR", "Accuracy" ),
  Value = c(
    round(best_threshold_youden, 3), 
    round(sensitivity5, 3), 
    round(specificity5, 3), 
    round(PPV5, 3), 
    round(NPV5, 3),
    round(PLR5, 3),
    round(NLR5, 3),
    round(Accuracy5, 3))
)
print(results1)

#Calculating SE/SP by minimal cost in test_set
predictions2 <- ifelse(test_set$proability_test >= best_threshold_cost_based, 1, 0)
TP2 <- sum(predictions2 == 1 & test_set$SBI == 1)
FN2 <- sum(predictions2 == 0 & test_set$SBI == 1)
TN2 <- sum(predictions2 == 0 & test_set$SBI == 0)
FP2 <- sum(predictions2 == 1 & test_set$SBI == 0)
sensitivity2 <- TP2 / (TP2 + FN2)
specificity2 <- TN2 / (TN2 + FP2)
PPV2 <- TP2 / (TP2 + FP2)
NPV2 <- TN2 / (FN2 + TN2)
Accuracy2 <- (TP2 + TN2) /(TP2 + FN2 + TN2 + FP2)
results2 <- data.frame(
  Metric = c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Accuracy"),
  Value = c(
    round(best_threshold_cost_based, 3), 
    round(sensitivity2, 3), 
    round(specificity2, 3), 
    round(PPV2, 3), 
    round(NPV2, 3),
    round(Accuracy2, 3))
)
print(results2)

#Validation dataset
#Calculating SE/SP by maximal Youden index from dataset2
predictions3 <- ifelse(dataset2$probability_validation >= best_threshold_youden, 1, 0)
TP3 <- sum(predictions3 == 1 & dataset2$SBI == 1)
FN3 <- sum(predictions3 == 0 & dataset2$SBI == 1)
TN3 <- sum(predictions3 == 0 & dataset2$SBI == 0)
FP3 <- sum(predictions3 == 1 & dataset2$SBI == 0)
sensitivity3 <- TP3 / (TP3 + FN3)
specificity3 <- TN3 / (TN3 + FP3)
PPV3 <- TP3 / (TP3 + FP3)
NPV3 <- TN3 / (FN3 + TN3)
PLR3 = sensitivity3 / (1 - specificity3)
NLR3 = (1 - sensitivity3) / specificity3
Accuracy3 <- (TP3 + TN3) / (TP3 + FN3 + TN3 + FP3)
results3 <- data.frame(
  Metric = c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Positive LR", "Negative LR", "Accuracy" ),
  Value = c(
    round(best_threshold_youden, 3), 
    round(sensitivity3, 3), 
    round(specificity3, 3), 
    round(PPV3, 3), 
    round(NPV3, 3),
    round(PLR3, 3),
    round(NLR3, 3),
    round(Accuracy3, 3))
)
print(results3)

#Calculating SE/SP by minimal cost (validation set)
predictions4 <- ifelse(dataset2$probability_validation >= best_threshold_cost_based, 1, 0)
TP4 <- sum(predictions4 == 1 & dataset2$SBI == 1)
FN4 <- sum(predictions4 == 0 & dataset2$SBI == 1)
TN4 <- sum(predictions4 == 0 & dataset2$SBI == 0)
FP4 <- sum(predictions4 == 1 & dataset2$SBI == 0)
sensitivity4 <- TP4 / (TP4 + FN4)
specificity4 <- TN4 / (TN4 + FP4)
PPV4 <- TP4 / (TP4 + FP4)
NPV4 <- TN4 / (FN4 + TN4)
PPV4 <- TP4 / (TP4 + FP4)
NPV4 <- TN4 / (FN4 + TN4)
PLR4 = sensitivity4 / (1 - specificity4)
NLR4 = (1 - sensitivity4) / specificity4
Accuracy4 <- (TP4 + TN4) / (TP4 + FN4 + TN4 + FP4)
results4 <- data.frame(
  Metric = c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Positive LR", "Negative LR", "Accuracy" ),
  Value = c(
    round(best_threshold_cost_based, 3), 
    round(sensitivity4, 3), 
    round(specificity4, 3), 
    round(PPV4, 3), 
    round(NPV4, 3),
    round(PLR4, 3),
    round(NLR4, 3),
    round(Accuracy4, 3))
)
print(results4)

results1$Set <- "<Test dataset by youden>"
results2$Set <- "<Test dataset by cost>"
results3$Set <- "<Validation dataset by youden>"
results4$Set <- "<Validation dataset  by cost>"
all_results <- rbind(results1, results2, results3, results4)
wide_results <- spread(all_results, Set, Value)
desired_order <- c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Positive LR", "Negative LR", "Accuracy")
wide_results <- wide_results[match(desired_order, wide_results$Metric),]
print(wide_results)

# probability save
library(openxlsx)

write.xlsx(test_set, file = "C:/download/dataset1_predictions.xlsx", sheetName = "Dataset1_Predictions")
write.xlsx(dataset2, file = "C:/download/dataset2_predictions.xlsx", sheetName = "Dataset2_Predictions")
train_set$probability_train <- predict(model, newdata = as.matrix(train_set[,2:30]))
write.xlsx(train_set, file = "C:/download/train_set_predictions.xlsx", sheetName = "Train_Set_Predictions")
 
