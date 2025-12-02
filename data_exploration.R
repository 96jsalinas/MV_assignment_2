# Set theme for all plots
theme_set(theme_minimal())

cat("\n==============================================================================\n")
cat("DATA EXPLORATION\n")
cat("==============================================================================\n\n")

# Summary statistics
cat("SUMMARY STATISTICS\n")
cat("------------------\n")
summary(heart_data_clean[, c("age", "trestbps", "chol", "ca", "thalach", "oldpeak")])

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

p4 <- ggplot(heart_data_clean, aes(x = ca)) +
    geom_histogram(bins = 4, fill = "steelblue", color = "white") +
    labs(title = "Number of Major Vessels", x = "Vessels (0-3)", y = "Count")

p5 <- ggplot(heart_data_clean, aes(x = thalach)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "Max Heart Rate", x = "Heart Rate", y = "Count")

p6 <- ggplot(heart_data_clean, aes(x = oldpeak)) +
    geom_histogram(bins = 20, fill = "steelblue", color = "white") +
    labs(title = "ST Depression", x = "Oldpeak", y = "Count")

ggsave("visualizations/quantitative_distributions.png",
    arrangeGrob(p1, p2, p3, p4, p5, p6, ncol = 2),
    width = 12, height = 12
)

# 2. Categorical variables by disease status
cat("Generating categorical variable plots...\n")

p7 <- ggplot(heart_data_clean, aes(x = sex, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Sex vs Disease", x = "Sex", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral"))

p8 <- ggplot(heart_data_clean, aes(x = cp, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Chest Pain Type vs Disease", x = "Chest Pain Type", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral")) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

p9 <- ggplot(heart_data_clean, aes(x = exang, fill = disease)) +
    geom_bar(position = "dodge") +
    labs(title = "Exercise Induced Angina vs Disease", x = "Exercise Angina", y = "Count") +
    scale_fill_manual(values = c("steelblue", "coral"))

ggsave("visualizations/categorical_by_disease.png",
    arrangeGrob(p7, p8, p9, ncol = 2),
    width = 12, height = 8
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

p13 <- ggplot(heart_data_clean, aes(x = disease, y = ca, fill = disease)) +
    geom_boxplot() +
    labs(title = "Number of Vessels by Disease Status", x = "", y = "Vessels (0-3)") +
    scale_fill_manual(values = c("steelblue", "coral"))

p14 <- ggplot(heart_data_clean, aes(x = disease, y = thalach, fill = disease)) +
    geom_boxplot() +
    labs(title = "Max Heart Rate by Disease Status", x = "", y = "Heart Rate") +
    scale_fill_manual(values = c("steelblue", "coral"))

p15 <- ggplot(heart_data_clean, aes(x = disease, y = oldpeak, fill = disease)) +
    geom_boxplot() +
    labs(title = "ST Depression by Disease Status", x = "", y = "Oldpeak") +
    scale_fill_manual(values = c("steelblue", "coral"))

ggsave("visualizations/quantitative_by_disease.png",
    arrangeGrob(p10, p11, p12, p13, p14, p15, ncol = 2),
    width = 12, height = 14
)

# 4. Pairs plot with correlations
cat("Generating pairs plot with correlations...\n")

# Custom correlation function with larger text and color coding
# Uses GGally internal functions: eval_data_col, ggally_text
cor_func <- function(data, mapping, method = "pearson", use = "complete.obs", ...) {
    x <- eval_data_col(data, mapping$x)
    y <- eval_data_col(data, mapping$y)

    corr <- cor(x, y, method = method, use = use)
    corr_text <- formatC(corr, format = "f", digits = 2)

    # Color based on correlation strength
    corr_abs <- abs(corr)
    color <- if (corr_abs > 0.5) {
        "firebrick"
    } else if (corr_abs > 0.3) {
        "darkorange"
    } else {
        "steelblue"
    }

    ggally_text(
        label = corr_text,
        mapping = aes(),
        color = color,
        size = 6,
        ...
    ) +
        theme_void()
}

# Create pairs plot for quantitative variables
p_pairs <- heart_data_clean %>%
    select(age, trestbps, chol, ca, thalach, oldpeak) %>%
    ggpairs(
        title = "Pairs Plot - Quantitative Variables (n=6)",
        lower = list(continuous = wrap("points", alpha = 0.3, size = 0.5)),
        upper = list(continuous = cor_func),
        diag = list(continuous = wrap("densityDiag", alpha = 0.5))
    ) +
    theme_minimal()

ggsave("visualizations/correlation_pairs.png", p_pairs, width = 14, height = 14)

# 5. Age distribution by sex and disease
cat("Generating age distribution by sex and disease...\n")

p16 <- ggplot(heart_data_clean, aes(x = age, fill = disease)) +
    geom_density(alpha = 0.6) +
    facet_wrap(~sex) +
    labs(title = "Age Distribution by Sex and Disease Status", x = "Age (years)", y = "Density") +
    scale_fill_manual(values = c("steelblue", "coral"))

ggsave("visualizations/age_by_sex_disease.png", p16, width = 10, height = 6)

cat("\n==============================================================================\n")
cat("EXPLORATION COMPLETE\n")
cat("==============================================================================\n")
cat("\nVisualization files saved to 'visualizations/' directory:\n")
cat("  - quantitative_distributions.png\n")
cat("  - categorical_by_disease.png\n")
cat("  - quantitative_by_disease.png\n")
cat("  - correlation_pairs.png\n")
cat("  - age_by_sex_disease.png\n\n")
