# Set theme for all plots
theme_set(theme_minimal())

cat("\n==============================================================================\n")
cat("DATA EXPLORATION\n")
cat("==============================================================================\n\n")

# Summary statistics
cat("SUMMARY STATISTICS\n")
cat("------------------\n")
summary(heart_data_clean[, c("age", "trestbps", "chol", "thalach", "oldpeak")])

cat("\nTARGET VARIABLE DISTRIBUTION\n")
cat("----------------------------\n")
table(heart_data_clean$disease)
cat("\nProportions:\n")
print(prop.table(table(heart_data_clean$disease)))

# Create visualizations directory if it doesn't exist
if (!dir.exists("visualizations")) {
    dir.create("visualizations")
}

# 1. Distribution of quantitative variables
cat("\nGenerating distribution plots for quantitative variables...\n")

p1 <- ggplot(heart_data_clean, aes(x = age)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "Age Distribution", x = "Age (years)", y = "Count")

p2 <- ggplot(heart_data_clean, aes(x = trestbps)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "Resting Blood Pressure", x = "BP (mm Hg)", y = "Count")

p3 <- ggplot(heart_data_clean, aes(x = chol)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "Cholesterol", x = "Cholesterol (mg/dl)", y = "Count")

p4 <- ggplot(heart_data_clean, aes(x = thalach)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "Max Heart Rate", x = "Heart Rate", y = "Count")

p5 <- ggplot(heart_data_clean, aes(x = oldpeak)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "ST Depression", x = "Oldpeak", y = "Count")

ggsave("visualizations/quantitative_distributions.png",
    arrangeGrob(p1, p2, p3, p4, p5, ncol = 2),
    width = 12, height = 10
)

# 2. Categorical variables by disease status
cat("Generating categorical variable plots...\n")

p6 <- ggplot(heart_data_clean, aes(x = sex, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Sex vs Disease", x = "Sex", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral"))

p7 <- ggplot(heart_data_clean, aes(x = cp, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Chest Pain Type vs Disease", x = "Chest Pain Type", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral")) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

p8 <- ggplot(heart_data_clean, aes(x = exang, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Exercise Induced Angina vs Disease", x = "Exercise Angina", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral"))

p9 <- ggplot(heart_data_clean, aes(x = ca, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Number of Major Vessels vs Disease", x = "Number of Vessels", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral"))

ggsave("visualizations/categorical_by_disease.png",
    arrangeGrob(p6, p7, p8, p9, ncol = 2),
    width = 12, height = 10
)

# 3. Quantitative variables by disease status
cat("Generating boxplots by disease status...\n")

p10 <- ggplot(heart_data_clean, aes(x = disease, y = age, fill = disease)) +
    geom_boxplot() +
    labs(title = "Age by Disease Status", x = "", y = "Age (years)") +
    scale_fill_manual(values = c("steelblue", "coral"))

p11 <- ggplot(heart_data_clean, aes(x = disease, y = trestbps, fill = disease)) +
    geom_boxplot() +
    labs(title = "Blood Pressure by Disease Status", x = "", y = "BP (mm Hg)") +
    scale_fill_manual(values = c("steelblue", "coral"))

p12 <- ggplot(heart_data_clean, aes(x = disease, y = chol, fill = disease)) +
    geom_boxplot() +
    labs(title = "Cholesterol by Disease Status", x = "", y = "Cholesterol (mg/dl)") +
    scale_fill_manual(values = c("steelblue", "coral"))

p13 <- ggplot(heart_data_clean, aes(x = disease, y = thalach, fill = disease)) +
    geom_boxplot() +
    labs(title = "Max Heart Rate by Disease Status", x = "", y = "Heart Rate") +
    scale_fill_manual(values = c("steelblue", "coral"))

ggsave("visualizations/quantitative_by_disease.png",
    arrangeGrob(p10, p11, p12, p13, ncol = 2),
    width = 12, height = 10
)

# 4. Correlation matrix
cat("Generating correlation matrix...\n")

# Create numeric version of dataset for correlation
numeric_data <- heart_data_clean %>%
    select(age, trestbps, chol, thalach, oldpeak) %>%
    as.matrix()

png("visualizations/correlation_matrix.png", width = 800, height = 800)
corrplot(cor(numeric_data),
    method = "color",
    type = "upper",
    addCoef.col = "black",
    tl.col = "black",
    tl.srt = 45,
    title = "Correlation Matrix - Quantitative Variables",
    mar = c(0, 0, 2, 0)
)
dev.off()

# 5. Age distribution by sex and disease
cat("Generating age distribution by sex and disease...\n")

p14 <- ggplot(heart_data_clean, aes(x = age, fill = disease)) +
    geom_density(alpha = 0.6) +
    facet_wrap(~sex) +
    labs(title = "Age Distribution by Sex and Disease Status", x = "Age (years)", y = "Density") +
    scale_fill_manual(values = c("steelblue", "coral"))

ggsave("visualizations/age_by_sex_disease.png", p14, width = 10, height = 6)

cat("\n==============================================================================\n")
cat("EXPLORATION COMPLETE\n")
cat("==============================================================================\n")
cat("\nVisualization files saved to 'visualizations/' directory:\n")
cat("  - quantitative_distributions.png\n")
cat("  - categorical_by_disease.png\n")
cat("  - quantitative_by_disease.png\n")
cat("  - correlation_matrix.png\n")
cat("  - age_by_sex_disease.png\n\n")
