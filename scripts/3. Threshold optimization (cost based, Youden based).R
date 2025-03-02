# Threshold optimization (cost based, Youden based)

thresholds <- seq(0, 1, by = 0.001)
costs <- sapply(thresholds, function(th) {
  predicted <- ifelse(test_set$proability_test >= th, 1, 0)
  FN <- sum((predicted == 0) & (test_set$SBI == 1))
  FP <- sum((predicted == 1) & (test_set$SBI == 0))
  cost <- 50 * FN + FP
  return(cost)
})
best_threshold_cost_based <- thresholds[which.min(costs)]

# Youden index threshold
roc_obj <- roc(test_set$SBI, test_set$proability_test)
best_threshold_youden <- coords(roc_obj, "best", ret = "threshold", best.method = "youden")

# print threshold
print(paste("Best Threshold (Cost-based):", best_threshold_cost_based))
print(paste("Best Threshold (Youden Index):", best_threshold_youden))
