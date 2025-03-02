# Load necessary libraries
library(readxl)
library(xgboost)
library(dplyr)
library(caret)
library(ggplot2)
library(pROC)
library(rms)

# Load the dataset
data <- read_excel("C:/download/1. SBI_development.xlsx")

# Handle missing values by imputing with median values
preProcess_missingdata <- preProcess(data, method = 'medianImpute')
data_imputed <- predict(preProcess_missingdata, newdata = data)

# Prepare the data for XGBoost
# Assume the target variable is named 'SBI' and is binary (0 or 1)
labels <- as.factor(ifelse(data_imputed$SBI == 1, "yes", "no"))  
data_imputed$SBI <- NULL

# Split the data into training and testing sets (60% train, 40% test)
set.seed(2000)
train_index <- createDataPartition(labels, p = 0.6, list = FALSE)
train_data <- data_imputed[train_index, ]
train_labels <- labels[train_index]
test_data <- data_imputed[-train_index, ]
test_labels <- labels[-train_index]

# Prepare the training and testing sets for XGBoost
dtrain <- xgb.DMatrix(data = as.matrix(train_data), label = as.numeric(train_labels == "yes"))
dtest <- xgb.DMatrix(data = as.matrix(test_data), label = as.numeric(test_labels == "yes"))

# Define grid search parameters
grid <- expand.grid(
  nrounds = c(200, 300, 400, 500),
  max_depth = c(5, 7, 9),
  eta = c(0.001, 0.01, 0.1),
  colsample_bytree = c(0.8, 0.9, 1.0),
  min_child_weight = c(1, 3, 5),
  subsample = c(0.7, 0.8, 0.9),
  gamma = c(0, 0.1, 0.5)
)

# Set up cross-validation
train_control <- trainControl(
  method = "cv",
  number = 5,
  verboseIter = TRUE,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final"
)

# Train using caret grid search
set.seed(2000)
xgb_grid_model <- train(
  x = as.matrix(train_data),
  y = train_labels,
  method = "xgbTree",
  trControl = train_control,
  tuneGrid = grid,
  metric = "ROC"
)

# Extract best hyperparameters
best_params <- xgb_grid_model$bestTune
print(best_params)

# Cross-validation AUCs 저장
cv_auc_values <- xgb_grid_model$resample$ROC
mean_cv_auc <- mean(cv_auc_values)  # Mean Cross-validated AUC
print(paste("Mean Cross-validated AUC:", mean_cv_auc))

# Train the final model with best parameters
params <- list(
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = best_params$max_depth,
  eta = best_params$eta,
  gamma = best_params$gamma,
  colsample_bytree = best_params$colsample_bytree,
  min_child_weight = best_params$min_child_weight,
  subsample = best_params$subsample
)

# Train the XGBoost model with best parameters
model <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = best_params$nrounds,
  watchlist = list(train = dtrain, test = dtest),
  early_stopping_rounds = 10,
  verbose = 1
)

# Evaluate the model on the training data
train_predictions <- predict(model, dtrain)
train_auc <- roc(as.numeric(train_labels == "yes"), train_predictions)$auc
print(paste("Apparent AUC:", train_auc))

# Optimism Calculation
optimism <- train_auc - mean_cv_auc
print(paste("Optimism:", optimism))

# Save the model
xgb.save(model, " SBI_xgboost_model_train_test_split.model ")
saveRDS(list(model = model, params = best_params, mean_cv_auc = mean_cv_auc, train_auc = train_auc, optimism = optimism), 
        " SBI_xgboost_model_train_test_split.rds")
