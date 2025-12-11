# ==============================================================================
# CLUSTERING ANALYSIS - Heart Disease Dataset
# ==============================================================================
# This script performs clustering analysis on mixed-type data using:
# 1. Gower's distance for mixed data
# 2. Hierarchical clustering (single, complete, average linkage)
# 3. PAM (Partitioning Around Medoids)
# 4. K-Prototypes
# 5. Silhouette validation
# ==============================================================================

# ==============================================================================
# 1. DATA PREPARATION
# ==============================================================================
# Select variables for clustering (excluding target variables)
# We exclude 'num' and 'disease' as they are target/outcome variables
clustering_vars <- c(
    "age", "sex", "cp", "trestbps", "chol", "fbs",
    "restecg", "thalach", "exang", "oldpeak", "slope", "ca", "thal"
)
cluster_data <- heart_data_clean[, clustering_vars]

cat("\n")
cat("========================================\n")
cat("CLUSTERING ANALYSIS\n")
cat("========================================\n")
cat("Variables used:", length(clustering_vars), "\n")
cat("Observations:", nrow(cluster_data), "\n\n")

# ==============================================================================
# 2. GOWER'S DISTANCE
# ==============================================================================

cat("Computing Gower's distance matrix...\n")
gower_dist <- daisy(cluster_data, metric = "gower")
cat("Distance matrix computed successfully.\n\n")

# Visualize distance distribution
gower_mat <- as.matrix(gower_dist)
cat("Gower distance summary:\n")
cat("  Min:", round(min(gower_mat[gower_mat > 0]), 4), "\n")
cat("  Max:", round(max(gower_mat), 4), "\n")
cat("  Mean:", round(mean(gower_mat[gower_mat > 0]), 4), "\n\n")

# ==============================================================================
# 3. HIERARCHICAL CLUSTERING
# ==============================================================================

cat("----------------------------------------\n")
cat("HIERARCHICAL CLUSTERING\n")
cat("----------------------------------------\n\n")

# Apply hierarchical clustering with different linkage methods
linkage_methods <- c("single", "complete", "average")
hc_results <- list()

for (method in linkage_methods) {
    hc_results[[method]] <- hclust(gower_dist, method = method)
    cat("Computed hierarchical clustering with", method, "linkage\n")
}

# Plot dendrograms (without cluster rectangles - initial view)
png("visualizations/dendrograms.png", width = 1200, height = 400)
par(mfrow = c(1, 3))
for (method in linkage_methods) {
    plot(hc_results[[method]],
        main = paste("Dendrogram -", tools::toTitleCase(method), "Linkage"),
        xlab = "", sub = "", cex = 0.6,
        hang = -1
    )
}
dev.off()
cat("\nDendrograms saved to 'visualizations/dendrograms.png'\n")

# Plot dendrograms with cluster rectangles (after optimal k is determined)
plot_dendrograms_with_clusters <- function(k) {
    cluster_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33")
    png("visualizations/dendrograms_clusters.png", width = 1200, height = 500)
    par(mfrow = c(1, 3), mar = c(5, 4, 4, 2))
    for (method in linkage_methods) {
        plot(hc_results[[method]],
            main = paste("Dendrogram -", tools::toTitleCase(method), "Linkage"),
            xlab = "", sub = paste("k =", k), cex = 0.5,
            hang = -1
        )
        rect.hclust(hc_results[[method]], k = k, border = cluster_colors[1:k])
    }
    dev.off()
    cat("Dendrograms with cluster cuts saved to 'visualizations/dendrograms_clusters.png'\n\n")
}


# ==============================================================================
# 4. DETERMINE OPTIMAL NUMBER OF CLUSTERS (SILHOUETTE)
# ==============================================================================

cat("----------------------------------------\n")
cat("SILHOUETTE ANALYSIS FOR OPTIMAL K\n")
cat("----------------------------------------\n\n")

# Function to compute average silhouette width for different k values
compute_silhouette_avg <- function(dist_matrix, k_range = 2:6) {
    sil_widths <- sapply(k_range, function(k) {
        # Use PAM for cluster assignments
        pam_result <- pam(dist_matrix, k = k, diss = TRUE)
        sil <- silhouette(pam_result$clustering, dist_matrix)
        mean(sil[, "sil_width"])
    })
    names(sil_widths) <- k_range
    return(sil_widths)
}

# Compute silhouette for k = 2 to 6
k_range <- 2:6
sil_scores <- compute_silhouette_avg(gower_dist, k_range)

cat("Average Silhouette Width by k:\n")
for (k in k_range) {
    cat(sprintf("  k = %d: %.4f\n", k, sil_scores[as.character(k)]))
}

optimal_k <- as.integer(names(which.max(sil_scores)))
cat("\nOptimal number of clusters:", optimal_k, "\n")
cat("(Based on maximum average silhouette width)\n\n")

# Plot silhouette scores
png("visualizations/silhouette_optimal_k.png", width = 600, height = 400)
plot(k_range, sil_scores,
    type = "b", pch = 19, col = "steelblue",
    xlab = "Number of Clusters (k)",
    ylab = "Average Silhouette Width",
    main = "Silhouette Analysis for Optimal k"
)
points(optimal_k, sil_scores[as.character(optimal_k)],
    col = "red", pch = 19, cex = 2
)
abline(v = optimal_k, col = "red", lty = 2)
dev.off()
cat("Silhouette plot saved to 'visualizations/silhouette_optimal_k.png'\n\n")

# Generate dendrograms with cluster rectangles
plot_dendrograms_with_clusters(optimal_k)

# ==============================================================================
# 5. HIERARCHICAL CLUSTERING - CUT AT OPTIMAL K
# ==============================================================================

cat("----------------------------------------\n")
cat("HIERARCHICAL CLUSTERING RESULTS (k =", optimal_k, ")\n")
cat("----------------------------------------\n\n")

# Cut dendrograms at optimal k
hc_clusters <- list()
for (method in linkage_methods) {
    hc_clusters[[method]] <- cutree(hc_results[[method]], k = optimal_k)
    cat(method, "linkage cluster sizes:\n")
    print(table(hc_clusters[[method]]))
    cat("\n")
}

# Compute silhouette for each linkage method
cat("Silhouette comparison across linkage methods:\n")
hc_silhouettes <- list()
for (method in linkage_methods) {
    sil <- silhouette(hc_clusters[[method]], gower_dist)
    hc_silhouettes[[method]] <- sil
    cat(sprintf("  %s: %.4f\n", method, mean(sil[, "sil_width"])))
}

# Find best linkage method
best_linkage <- names(which.max(sapply(hc_silhouettes, function(s) mean(s[, "sil_width"]))))
cat("\nBest linkage method:", best_linkage, "\n\n")

# ==============================================================================
# 6. PAM CLUSTERING
# ==============================================================================

cat("----------------------------------------\n")
cat("PAM CLUSTERING (k =", optimal_k, ")\n")
cat("----------------------------------------\n\n")

pam_result <- pam(gower_dist, k = optimal_k, diss = TRUE)

cat("PAM cluster sizes:\n")
print(table(pam_result$clustering))
cat("\n")

# Silhouette for PAM
pam_sil <- silhouette(pam_result$clustering, gower_dist)
cat("PAM average silhouette width:", round(mean(pam_sil[, "sil_width"]), 4), "\n\n")

# Display medoids
cat("Medoid observations (cluster representatives):\n")
print(cluster_data[pam_result$medoids, ])
cat("\n")

# ==============================================================================
# 7. K-PROTOTYPES CLUSTERING
# ==============================================================================

cat("----------------------------------------\n")
cat("K-PROTOTYPES CLUSTERING (k =", optimal_k, ")\n")
cat("----------------------------------------\n\n")

# K-prototypes works directly with the data (not distance matrix)
set.seed(42) # For reproducibility
kproto_result <- kproto(cluster_data, k = optimal_k, verbose = FALSE)

cat("K-Prototypes cluster sizes:\n")
print(table(kproto_result$cluster))
cat("\n")

# Silhouette for K-prototypes (using Gower distance)
kproto_sil <- silhouette(kproto_result$cluster, gower_dist)
cat("K-Prototypes average silhouette width:", round(mean(kproto_sil[, "sil_width"]), 4), "\n\n")

# Display prototypes
cat("Cluster prototypes:\n")
print(kproto_result$centers)
cat("\n")

# ==============================================================================
# 8. COMPARISON OF CLUSTERING METHODS
# ==============================================================================

cat("========================================\n")
cat("CLUSTERING METHODS COMPARISON\n")
cat("========================================\n\n")

# Collect all silhouette scores
all_sil_scores <- c(
    sapply(hc_silhouettes, function(s) mean(s[, "sil_width"])),
    "PAM" = mean(pam_sil[, "sil_width"]),
    "K-Prototypes" = mean(kproto_sil[, "sil_width"])
)

# Create comparison data frame
comparison_df <- data.frame(
    Method = names(all_sil_scores),
    Avg_Silhouette = round(all_sil_scores, 4)
)
comparison_df <- comparison_df[order(-comparison_df$Avg_Silhouette), ]
rownames(comparison_df) <- NULL

cat("Method Comparison (sorted by silhouette):\n")
print(comparison_df)
cat("\n")

best_method <- comparison_df$Method[1]
cat("Best performing method:", best_method, "\n")
cat("Average silhouette width:", comparison_df$Avg_Silhouette[1], "\n\n")

# ==============================================================================
# 9. VISUALIZATION
# ==============================================================================

cat("----------------------------------------\n")
cat("GENERATING VISUALIZATIONS\n")
cat("----------------------------------------\n\n")

# Silhouette plots for best methods
png("visualizations/silhouette_plots.png", width = 1200, height = 400)
par(mfrow = c(1, 3))

# Best hierarchical
plot(hc_silhouettes[[best_linkage]],
    main = paste("Hierarchical (", best_linkage, ")", sep = ""),
    col = 1:optimal_k, border = NA
)

# PAM
plot(pam_sil,
    main = "PAM",
    col = 1:optimal_k, border = NA
)

# K-Prototypes
plot(kproto_sil,
    main = "K-Prototypes",
    col = 1:optimal_k, border = NA
)

dev.off()
cat("Silhouette plots saved to 'visualizations/silhouette_plots.png'\n")

# Cluster comparison barplot
png("visualizations/method_comparison.png", width = 600, height = 400)
barplot(comparison_df$Avg_Silhouette,
    names.arg = comparison_df$Method,
    col = ifelse(comparison_df$Method == best_method, "steelblue", "lightgray"),
    main = "Clustering Methods Comparison",
    ylab = "Average Silhouette Width",
    las = 2, cex.names = 0.8
)
abline(h = 0.25, col = "red", lty = 2)
legend("topright", legend = "0.25 threshold", col = "red", lty = 2, bty = "n")
dev.off()
cat("Method comparison plot saved to 'visualizations/method_comparison.png'\n\n")

# ==============================================================================
# 10. EXTERNAL VALIDATION (COMPARISON WITH DISEASE)
# ==============================================================================

cat("----------------------------------------\n")
cat("EXTERNAL VALIDATION (vs Disease Status)\n")
cat("----------------------------------------\n\n")

# Get best clustering result
if (best_method %in% linkage_methods) {
    best_clusters <- hc_clusters[[best_method]]
} else if (best_method == "PAM") {
    best_clusters <- pam_result$clustering
} else {
    best_clusters <- kproto_result$cluster
}

# Cross-tabulation with disease
cat("Cross-tabulation: Best Clustering vs Disease Status\n")
cross_tab <- table(Cluster = best_clusters, Disease = heart_data_clean$disease)
print(cross_tab)
cat("\n")

# Proportions
cat("Proportions within each cluster:\n")
print(round(prop.table(cross_tab, margin = 1), 3))
cat("\n")

# Visualize cross-tabulation
# Create data frame for ggplot
cross_tab_df <- as.data.frame(cross_tab)
names(cross_tab_df) <- c("Cluster", "Disease", "Count")

# Calculate proportions for labels
cross_tab_df <- cross_tab_df %>%
    group_by(Cluster) %>%
    mutate(
        Total = sum(Count),
        Proportion = Count / Total,
        Label = paste0(Count, "\n(", round(Proportion * 100, 1), "%)")
    )

# Stacked bar chart
p1 <- ggplot(cross_tab_df, aes(x = factor(Cluster), y = Count, fill = Disease)) +
    geom_bar(stat = "identity", position = "stack", width = 0.7) +
    geom_text(aes(label = Label),
        position = position_stack(vjust = 0.5),
        size = 4, color = "white", fontface = "bold"
    ) +
    scale_fill_manual(values = c("No Disease" = "#4DAF4A", "Disease" = "#E41A1C")) +
    labs(
        title = "Cluster Composition by Disease Status",
        subtitle = paste("Best method:", best_method, "| k =", optimal_k),
        x = "Cluster",
        y = "Number of Patients",
        fill = "Disease Status"
    ) +
    theme_minimal(base_size = 14) +
    theme(
        plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5),
        legend.position = "bottom"
    )

# Proportional stacked bar chart (100% stacked)
p2 <- ggplot(cross_tab_df, aes(x = factor(Cluster), y = Proportion, fill = Disease)) +
    geom_bar(stat = "identity", position = "stack", width = 0.7) +
    geom_text(aes(label = paste0(round(Proportion * 100, 1), "%")),
        position = position_stack(vjust = 0.5),
        size = 5, color = "white", fontface = "bold"
    ) +
    scale_fill_manual(values = c("No Disease" = "#4DAF4A", "Disease" = "#E41A1C")) +
    scale_y_continuous(labels = scales::percent) +
    labs(
        title = "Disease Proportion by Cluster",
        x = "Cluster",
        y = "Proportion",
        fill = "Disease Status"
    ) +
    theme_minimal(base_size = 14) +
    theme(
        plot.title = element_text(hjust = 0.5, face = "bold"),
        legend.position = "bottom"
    )

# Save combined plot
png("visualizations/cluster_disease_comparison.png", width = 1000, height = 500)
grid.arrange(p1, p2, ncol = 2)
dev.off()
cat("Cluster-disease comparison saved to 'visualizations/cluster_disease_comparison.png'\n\n")


# ==============================================================================
# SUMMARY
# ==============================================================================

cat("========================================\n")
cat("ANALYSIS COMPLETE\n")
cat("========================================\n")
cat("Optimal k:", optimal_k, "\n")
cat("Best method:", best_method, "\n")
cat("Silhouette:", comparison_df$Avg_Silhouette[1], "\n")
cat("\nVisualizations saved to 'visualizations/' directory\n")
