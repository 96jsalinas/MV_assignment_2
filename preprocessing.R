# Define column names based on documentation
column_names <- c(
    "age", "sex", "cp", "trestbps", "chol", "fbs", "restecg",
    "thalach", "exang", "oldpeak", "slope", "ca", "thal", "num"
)

# Load data
data_path <- file.path("data", "processed.cleveland.data")
heart_data <- read.csv(data_path,
    header = FALSE, col.names = column_names,
    na.strings = "?"
)
cat("Data loaded successfully (", nrow(heart_data), "rows )\n", sep = "")


# Remove rows with missing 'ca' or 'thal' values
heart_data_clean <- heart_data %>%
    filter(!is.na(ca) & !is.na(thal))
cat("Removed rows with missing 'ca' or 'thal' values (",
    nrow(heart_data) - nrow(heart_data_clean), " rows removed)\n",
    sep = ""
)

# Convert categorical variables to factors with labels
heart_data_clean$sex <- factor(heart_data_clean$sex,
    levels = c(0, 1),
    labels = c("Female", "Male")
)
heart_data_clean$cp <- factor(heart_data_clean$cp,
    levels = c(1, 2, 3, 4),
    labels = c(
        "Typical Angina", "Atypical Angina",
        "Non-Anginal Pain", "Asymptomatic"
    )
)
heart_data_clean$fbs <- factor(heart_data_clean$fbs,
    levels = c(0, 1),
    labels = c("<=120", ">120")
)
heart_data_clean$restecg <- factor(heart_data_clean$restecg,
    levels = c(0, 1, 2),
    labels = c(
        "Normal", "ST-T Abnormality",
        "LV Hypertrophy"
    )
)
heart_data_clean$exang <- factor(heart_data_clean$exang,
    levels = c(0, 1),
    labels = c("No", "Yes")
)
heart_data_clean$slope <- factor(heart_data_clean$slope,
    levels = c(1, 2, 3),
    labels = c("Upsloping", "Flat", "Downsloping")
)
heart_data_clean$thal <- factor(heart_data_clean$thal,
    levels = c(3, 6, 7),
    labels = c(
        "Normal", "Fixed Defect",
        "Reversible Defect"
    )
)
heart_data_clean$num <- as.factor(heart_data_clean$num)

# Create binary target variable
heart_data_clean$disease <- factor(ifelse(heart_data_clean$num == "0", 0, 1),
    levels = c(0, 1),
    labels = c("No Disease", "Disease")
)

# ==============================================================================
# FINAL SUMMARY
# ==============================================================================

cat("\n")
cat("========================================\n")
cat("CLEANED DATASET SUMMARY\n")
cat("========================================\n")
cat("Dimensions:", nrow(heart_data_clean), "rows ×", ncol(heart_data_clean), "columns\n\n")

cat("COLUMN DATA TYPES:\n")
cat("------------------\n")

# Categorize variables
binary_vars <- c("sex", "fbs", "exang", "disease")
categorical_vars <- c("cp", "restecg", "slope", "thal", "num")
quantitative_vars <- c("age", "trestbps", "chol", "ca", "thalach", "oldpeak")

cat("\nBinary (2 levels):\n")
for (var in binary_vars) {
    cat(sprintf("  - %s\n", var))
}

cat("\nCategorical (>2 levels):\n")
for (var in categorical_vars) {
    n_levels <- length(levels(heart_data_clean[[var]]))
    cat(sprintf("  - %s (%d levels)\n", var, n_levels))
}

cat("\nQuantitative:\n")
for (var in quantitative_vars) {
    cat(sprintf("  - %s\n", var))
}
