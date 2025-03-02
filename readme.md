# SBI_XGB

Machine Learning-Based Prediction Model for Serious Bacterial Infections in Febrile Young Infants

----------------------

**📌 Overview**


This repository contains code and resources for developing and validating machine learning (ML)-based prediction models for serious bacterial infections (SBIs) in febrile young infants (≤90 days old). 
-----------------------

The study compares eXtreme Gradient Boosting (XGB) and Logistic Regression (LR) models with traditional rule-based models to improve diagnostic accuracy.
This research is based on data collected from febrile infants at Asan Medical Center, Republic of Korea. The models aim to enhance specificity and positive predictive value (PPV) while maintaining high sensitivity.

-----------------------


**🏥 Study Objective**


The goal of this study is to develop an ML-based prediction model for SBI risk assessment in febrile infants aged ≤90 days and validate its performance against traditional clinical guidelines, including:

PECARN Rule

American Academy of Pediatrics Clinical Practice Guideline (AAP CPG)

Step-by-step approach

Rochester, Boston, and Philadelphia criteria

The models are designed to provide individualized risk probabilities for SBI and allow dynamic threshold adjustments to balance sensitivity and specificity.

----------------------


**📂 Repository Structure**

📦 BSI_Prediction_EMR/

 ┣ 📂 data/               # Example dataset
 
 ┣ 📂 scripts/            # R scripts for model training, validation, and evaluation
 
 ┣ 📂 figures/            # ROC curves, calibration plots, SHAP values
 
 ┣ 📂 model/              # XGB model
 
 ┣ 📄 README.md           # Overview and instructions
 
 ┣ 📄 requirements.txt    # Required R packages


----------------------


📊 Dataset


📌 Data Description

The study includes 2,860 febrile infants who visited the emergency department:

Development dataset: 2,288 infants (2015–2021)

Validation dataset: 572 infants (2022–2023)

Feature	Description

Patient_ID	Unique identifier

Age	Infant’s age (days)
Sex	Male/Female
Temperature	Maximum recorded fever (°C)
CRP	C-reactive protein level (mg/L)
Procalcitonin	Procalcitonin level (ng/mL)
WBC	White blood cell count (×10⁹/L)
ANC	Absolute neutrophil count (cells/µL)
Urine_Nitrite	Urine test result (Positive/Negative)
Urine_WBC	White blood cells in urine
SBI	Serious bacterial infection (1 = Yes, 0 = No)
⚠️ Note: The original dataset contains protected health information (PHI) and cannot be shared. A synthetic example dataset (data/example_SBI_data.csv) is provided for demonstration.

----------------------

📈 Model Performance

## Development Dataset

| Model                | AUC   | Sensitivity | Specificity | PPV   | NPV   |
|----------------------|------|------------|------------|-------|-------|
| **XGBoost**         | 0.986 | 98.3%      | 84.4%      | 68.5% | 99.5% |
| **Logistic Regression** | 0.975 | 98.1%  | 80.2%      | 61.5% | 99.5% |
| **PECARN Rule**      | 0.87  | 98.4%      | 46.4%      | 35.0% | 99.5% |

---

## Validation Dataset

| Model                | AUC   | Sensitivity | Specificity | PPV   | NPV   |
|----------------------|------|------------|------------|-------|-------|
| **XGBoost**         | 0.984 | 98.4%      | 86.9%      | 68.5% | 99.5% |
| **Logistic Regression** | 0.978 | 98.4%  | 82.2%      | 61.5% | 99.5% |
| **PECARN Rule**      | 0.88  | 98.4%      | 46.4%      | 35.0% | 99.5% |




