# Load the model and internal validation

# Load the pre-trained model
model <- xgb.load("SBI_xgboost_model_train_test_split.model")

# Prepare data for cross-validation
train_control <- trainControl(method = "cv", number = 10, savePredictions = TRUE, classProbs = TRUE, summaryFunction = twoClassSummary)

# Reload the dataset for internal validation
train_data <- read_excel("C:/download/1. SBI_development.xlsx")
train_data <- na.omit(train_data)  # Remove rows with missing values
train_data$SBI <- as.factor(train_data$SBI)  # Ensure outcome variable is treated as factor
levels(train_data$SBI) <- c("No", "Yes")  # Assuming SBI is a binary outcome

# Fit model using 10-fold cross-validation
xgb_grid <- expand.grid(
  nrounds = c(100, 200, 300),
  max_depth = c(4, 6, 8),
  eta = c(0.01, 0.1, 0.3),
  gamma = c(0, 0.1, 1),
  colsample_bytree = c(0.7, 0.9, 1),
  min_child_weight = c(1, 3, 5),
  subsample = c(0.8, 1)
)

cv_model <- train(SBI ~ ., data = train_data,
                  method = "xgbTree",
                  trControl = train_control,
                  tuneGrid = xgb_grid,
                  metric = "ROC")

# Extract AUCs from cross-validation folds
fold_auc_values <- cv_model$resample$ROC
mean_auc <- mean(fold_auc_values)
std_error_auc <- sd(fold_auc_values) / sqrt(length(fold_auc_values))

# Calculate 95% confidence interval
z_score <- qnorm(0.975)
ci_lower <- mean_auc - z_score * std_error_auc
ci_upper <- mean_auc + z_score * std_error_auc

# Predict on training data to calculate AUC
train_preds <- predict(model, as.matrix(train_data[, -1]))
train_auc <- roc(as.numeric(train_data$SBI) - 1, train_preds)$auc

# Calculate optimism
optimism <- train_auc - mean_auc

# Print results
cat("10-Fold Cross-Validation AUC Mean: ", round(mean_auc, 3), "\n")
cat("95% Confidence Interval: (", round(ci_lower, 3), ",", round(ci_upper, 3), ")\n")
cat("Training AUC: ", round(train_auc, 3), "\n")
cat("Optimism: ", round(optimism, 3), "\n")
