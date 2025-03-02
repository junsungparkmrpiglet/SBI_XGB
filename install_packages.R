# List of required packages
required_packages <- c("readxl", "xgboost", "dplyr", "caret", "ggplot2", "pROC", "rms", "tidyr", "pander", "openxlsx". "SHAPforxgboost", "caTools")

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, dependencies = TRUE)

# Load all packages
invisible(lapply(required_packages, library, character.only = TRUE))

print("All required packages are installed and loaded successfully.")
