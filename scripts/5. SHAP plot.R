# SHAP plot

library(SHAPforxgboost)

# SHAP
test_matrix <- as.matrix(test_set[, 2:30])
shap_values <- shap.values(xgb_model = model, X_train = test_matrix)
shap_summary <- shap.prep(shap_contrib = shap_values$shap_score, X_train = as.data.frame(test_matrix))
shap.plot.summary(shap_summary)

# SHAP save file
shap_df <- as.data.frame(shap_values$shap_score)  
colnames(shap_df) <- colnames(test_matrix) 
write.xlsx(shap_df, file = "C:/download/shap_values_test_set.xlsx", sheetName = "SHAP_Values")


library(caTools)
library(xgboost)
library(SHAPforxgboost)
library(reshape2)
library(viridis)

# Predict the outcome
dev_matrix <- as.matrix(dataset1[, 2:30])
dataset1$proability_dev <- predict(model, newdata = dev_matrix)

# Outcome formation
dataset1$Prediction <- ifelse(dataset1$proability_dev >= best_threshold_cost_based, 1, 0)
dataset1$Outcome <- ifelse(dataset1$SBI == 1 & dataset1$Prediction == 1, "true positive",
                           ifelse(dataset1$SBI == 1 & dataset1$Prediction == 0, "false negative",
                                  ifelse(dataset1$SBI == 0 & dataset1$Prediction == 1, "false positive", "true negative")))

# Outcome factor order FN, TP, FP, TN
desired_order <- c("false negative", "true positive", "false positive", "true negative")
dataset1$Outcome <- factor(dataset1$Outcome, levels = desired_order)

# calculate SHAP values
dev_shap_matrix <- dev_matrix  
shap_values <- shap.values(xgb_model = model, X_train = dev_shap_matrix)
shap_df <- as.data.frame(shap_values$shap_score)  

# Top 10 feature and rest_features
avg_abs_shap <- colMeans(abs(shap_df))
top10_features <- names(sort(avg_abs_shap, decreasing = TRUE))[1:10]
other_features <- setdiff(colnames(shap_df), top10_features)
rest_features_value <- rowSums(shap_df[, other_features])

shap_top10_df <- shap_df[, top10_features]
shap_top10_df$rest_features <- rest_features_value

# calculate net SHAP 
shap_top10_df$Case <- 1:nrow(shap_top10_df)
shap_top10_df$Outcome <- dataset1$Outcome
shap_top10_df$net_shap <- rowSums(shap_top10_df[, c(top10_features, "rest_features")])
shap_top10_df$TotalAbs <- rowSums(abs(shap_top10_df[, c(top10_features, "rest_features")]))

# Rearrangement according to class
ordered_df <- shap_top10_df %>%
  arrange(Outcome, net_shap) %>% 
  mutate(Case_order = factor(1:n(), levels = 1:n()))

# Prepare for zoom-in plot
zoom_df <- ordered_df %>% 
  filter(Outcome %in% c("false negative", "true positive", "false positive")) %>%
  mutate(Outcome = factor(Outcome, levels = c("false negative", "true positive", "false positive"))) %>%
  group_by(Outcome) %>%
  mutate(Case_order = factor(row_number(), levels = row_number())) %>%
  ungroup()

# long format data formation
all_long <- melt(ordered_df, 
                 id.vars = c("Case", "Outcome", "TotalAbs", "Case_order", "net_shap"),
                 variable.name = "Feature", value.name = "SHAP_Value")

zoom_long <- melt(zoom_df, 
                  id.vars = c("Case", "Outcome", "TotalAbs", "Case_order", "net_shap"),
                  variable.name = "Feature", value.name = "SHAP_Value")

# 8. net SHAP threshold
threshold_value <- as.numeric(quantile(ordered_df$net_shap, probs = 0.12, na.rm = TRUE))
print(paste("Calculated net SHAP threshold (8.8th percentile):", threshold_value))

# zoom out plot
p_all <- ggplot(all_long, aes(x = Case_order, y = SHAP_Value, fill = Feature)) +
  geom_bar(stat = "identity", position = "stack", width = 1) +
geom_point(data = ordered_df, aes(x = Case_order, y = net_shap),
             color = "red", size = 2, inherit.aes = FALSE) +
  # net SHAP threshold
  geom_hline(yintercept = threshold_value, color = "green", linetype = "solid") +
  scale_fill_viridis_d(option = "plasma") +
  scale_x_discrete(expand = c(0, 0)) +
  labs(x = "Case",
       y = "SHAP Value (Contribution to the Base Value)",
       title = "Force Plot for Development Dataset (Top 10 + Rest Features)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        panel.spacing = unit(0, "cm"),
        plot.margin = margin(0, 0, 0, 0))
p_all

# Zoom in plot
p_zoom <- ggplot(zoom_long, aes(x = Case_order, y = SHAP_Value, fill = Feature)) +
  geom_bar(stat = "identity", position = "stack", width = 1) +
  geom_point(data = zoom_df, aes(x = Case_order, y = net_shap),
             color = "red", size = 2, inherit.aes = FALSE) +
  geom_hline(yintercept = threshold_value, color = "green", linetype = "solid") +
  scale_fill_viridis_d(option = "plasma") +
  scale_x_discrete(expand = c(0, 0)) +
  labs(x = "Case",
       y = "SHAP Value (Contribution to the Base Value)",
       title = "Zoomed Force Plot for FN / TP / FP with Blank Gaps") +
  facet_grid(~ Outcome, scales = "free_x", space = "free_x") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
        panel.spacing = unit(1, "lines"),
        plot.margin = margin(0, 0, 0, 0))
p_zoom


