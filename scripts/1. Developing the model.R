# developing the model
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
labels <- data_imputed$SBI
data_imputed$SBI <- NULL

# Split the data into training and testing sets (60% train, 40% test)
set.seed(2000)  # For reproducibility
train_index <- createDataPartition(labels, p = 0.6, list = FALSE)
train_data <- data_imputed[train_index, ]
train_labels <- labels[train_index]
test_data <- data_imputed[-train_index, ]
test_labels <- labels[-train_index]

# Prepare the training and testing sets for XGBoost
dtrain <- xgb.DMatrix(data = as.matrix(train_data), label = train_labels)
dtest <- xgb.DMatrix(data = as.matrix(test_data), label = test_labels)

# Set parameters for XGBoost
params <- list(
  objective = "binary:logistic",
  eval_metric = "auc",
  max_depth = 7,
  eta = 0.01,  # Lower learning rate
  gamma = 0,
  colsample_bytree = 0.9,
  min_child_weight = 3,  # Stricter split requirement
  subsample = 0.8  # Keep the same
)

# Train the XGBoost model with repeated training
nrounds <- sample(200:500, 1)  # Random value between 200 and 500
model <- xgb.train(
  nthread = 6,
  params = params,
  data = dtrain,
  nrounds = nrounds,
  watchlist = list(train = dtrain, test = dtest),
  early_stopping_rounds = 10,
  verbose = 1
)

# Save the model
xgb.save(model, "SBI_xgboost_model_train_test_split.model")
saveRDS(list(model = model, params = params), "SBI_xgb_model.rds")
