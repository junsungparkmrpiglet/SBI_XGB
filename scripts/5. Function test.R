# Load libraries
library(readxl)
library(xgboost)
library(dplyr)
library(tidyr)
library(pander)
library(openxlsx)

# Read the development dataset
dataset1 <- read_excel("C:/download/1. SBI_development.xlsx")
model <- xgb.load("C:/download/SBI_xgboost_model_train_test_split.model")

# Development dataset
dataset1_x <- as.matrix(dataset1[, 2:30])  # Feature columns
dataset1$probability_dev <- predict(model, newdata = dataset1_x)

# Performance evaluation for development dataset
res_dev = val.prob(dataset1$probability_dev, dataset1$SBI, m=60, cex=.5)
val_dev <- val.prob(dataset1$probability_dev, dataset1$SBI, pl = FALSE)
pander(val_dev)

# Load external validation dataset
dataset2 <- read_excel("C:/download/1. SBI_validation.xlsx")
dataset2_x <- as.matrix(dataset2[, 2:30])  # Feature columns
dataset2$probability_validation <- predict(model, newdata = dataset2_x)

# Performance evaluation for validation dataset
res_val = val.prob(dataset2$probability_validation, dataset2$SBI, m=60, cex=.5)
val_m2 <- val.prob(dataset2$probability_validation, dataset2$SBI, pl = FALSE)
pander(val_m2)

# Define best thresholds
best_threshold_cost_based <- 0.088
best_threshold_youden <- 0.335

# Function to calculate performance metrics
calculate_metrics <- function(probabilities, true_labels, threshold, dataset_name) {
  predictions <- ifelse(probabilities >= threshold, 1, 0)
  
  TP <- sum(predictions == 1 & true_labels == 1)
  FN <- sum(predictions == 0 & true_labels == 1)
  TN <- sum(predictions == 0 & true_labels == 0)
  FP <- sum(predictions == 1 & true_labels == 0)
  
  sensitivity <- TP / (TP + FN)
  specificity <- TN / (TN + FP)
  PPV <- TP / (TP + FP)
  NPV <- TN / (FN + TN)
  PLR <- sensitivity / (1 - specificity)
  NLR <- (1 - sensitivity) / specificity
  Accuracy <- (TP + TN) / (TP + FN + TN + FP)
  
  results <- data.frame(
    Metric = c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Positive LR", "Negative LR", "Accuracy"),
    Value = c(
      round(threshold, 3),
      round(sensitivity, 3),
      round(specificity, 3),
      round(PPV, 3),
      round(NPV, 3),
      round(PLR, 3),
      round(NLR, 3),
      round(Accuracy, 3)
    ),
    Set = dataset_name
  )
  
  return(results)
}

# Calculate performance for development dataset
results_dev_youden <- calculate_metrics(dataset1$probability_dev, dataset1$SBI, best_threshold_youden, "<Development dataset by Youden>")
results_dev_cost <- calculate_metrics(dataset1$probability_dev, dataset1$SBI, best_threshold_cost_based, "<Development dataset by Cost>")

# Calculate performance for validation dataset
results_val_youden <- calculate_metrics(dataset2$probability_validation, dataset2$SBI, best_threshold_youden, "<Validation dataset by Youden>")
results_val_cost <- calculate_metrics(dataset2$probability_validation, dataset2$SBI, best_threshold_cost_based, "<Validation dataset by Cost>")

# Combine all results
all_results <- rbind(results_dev_youden, results_dev_cost, results_val_youden, results_val_cost)

# Convert results to wide format using `pivot_wider()` (instead of deprecated `spread()`)
wide_results <- all_results %>%
  pivot_wider(names_from = Set, values_from = Value)

# Order rows based on metrics
desired_order <- c("Best Threshold", "Sensitivity", "Specificity", "PPV", "NPV", "Positive LR", "Negative LR", "Accuracy")
wide_results <- wide_results %>%
  filter(Metric %in% desired_order) %>%
  arrange(match(Metric, desired_order))

print(wide_results)

# Save results and predictions
write.xlsx(dataset1, file = "C:/download/dataset1_predictions.xlsx", sheetName = "Development Predictions")
write.xlsx(dataset2, file = "C:/download/dataset2_predictions.xlsx", sheetName = "Validation Predictions")
write.xlsx(wide_results, file = "C:/download/Performance_Results.xlsx", sheetName = "Performance")
