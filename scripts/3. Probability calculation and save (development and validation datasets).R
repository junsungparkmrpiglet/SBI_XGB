# probability calculation and save (development and validation datasets)

# Predict probabilities on the test set
test_preds <- predict(model, newdata = dtest)

# Save test predictions to CSV
test_results <- data.frame(ID = rownames(test_data), Predicted_Probability = test_preds, Observed = test_labels)
write.csv(test_results, "SBI_test_predictions.csv", row.names = FALSE)

# Load the validation dataset
validation_data <- read_excel("C:/download/1. SBI_validation.xlsx")

# Handle missing values in the validation dataset by imputing with median values
validation_imputed <- predict(preProcess_missingdata, newdata = validation_data)

# Prepare the validation set for XGBoost
validation_labels <- validation_imputed$SBI
validation_imputed$SBI <- NULL

# Convert validation data to DMatrix format
dvalidation <- xgb.DMatrix(data = as.matrix(validation_imputed), label = validation_labels)

# Predict probabilities on the validation set
validation_preds <- predict(model, newdata = dvalidation)

# Save validation predictions to CSV
validation_results <- data.frame(ID = rownames(validation_imputed), Predicted_Probability = validation_preds, Observed = validation_labels)
write.csv(validation_results, "SBI_validation_predictions.csv", row.names = FALSE)
