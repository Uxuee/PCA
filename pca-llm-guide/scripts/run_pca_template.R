# PCA template for gene-expression style data.
#
# Expected inputs:
# - data/expression_matrix.csv: rows are samples, columns are genes/features
# - data/metadata.csv: one row per sample, includes sample_id and covariates

suppressPackageStartupMessages({
  library(ggplot2)
})

dir.create("outputs", showWarnings = FALSE)

expression_path <- "data/expression_matrix.csv"
metadata_path <- "data/metadata.csv"

if (!file.exists(expression_path) || !file.exists(metadata_path)) {
  message("Input files not found. Add data/expression_matrix.csv and data/metadata.csv to run this template.")
  quit(save = "no", status = 0)
}

expr <- read.csv(expression_path, row.names = 1, check.names = FALSE)
metadata <- read.csv(metadata_path, stringsAsFactors = FALSE)

if (!"sample_id" %in% names(metadata)) {
  stop("metadata.csv must contain a sample_id column.")
}

common_samples <- intersect(rownames(expr), metadata$sample_id)
expr <- expr[common_samples, , drop = FALSE]
metadata <- metadata[match(common_samples, metadata$sample_id), , drop = FALSE]

# Keep genes/features with non-zero variance. PCA cannot use constant columns.
feature_sd <- apply(expr, 2, sd, na.rm = TRUE)
expr <- expr[, is.finite(feature_sd) & feature_sd > 0, drop = FALSE]

# Optional: keep the most variable features, useful for RNA-seq PCA.
top_n <- min(5000, ncol(expr))
feature_var <- apply(expr, 2, var, na.rm = TRUE)
expr_top <- expr[, order(feature_var, decreasing = TRUE)[seq_len(top_n)], drop = FALSE]

# If your input is raw counts, normalize/log-transform before this point.
pca <- prcomp(expr_top, center = TRUE, scale. = FALSE)

variance_explained <- (pca$sdev^2) / sum(pca$sdev^2)

scores <- data.frame(
  sample_id = rownames(pca$x),
  PC1 = pca$x[, 1],
  PC2 = pca$x[, 2],
  metadata,
  check.names = FALSE
)

write.csv(scores, "outputs/pca_scores.csv", row.names = FALSE)
write.csv(
  data.frame(
    PC = paste0("PC", seq_along(variance_explained)),
    variance_explained = variance_explained
  ),
  "outputs/pca_variance_explained.csv",
  row.names = FALSE
)

plot_pca <- function(color_column) {
  if (!color_column %in% names(scores)) {
    message("Skipping missing column: ", color_column)
    return(invisible(NULL))
  }

  ggplot(scores, aes(x = PC1, y = PC2, color = .data[[color_column]])) +
    geom_point(size = 2.6, alpha = 0.85) +
    theme_minimal(base_size = 14) +
    labs(
      title = paste("PCA colored by", color_column),
      x = sprintf("PC1 (%.1f%%)", 100 * variance_explained[1]),
      y = sprintf("PC2 (%.1f%%)", 100 * variance_explained[2]),
      color = color_column
    )

  ggsave(
    filename = file.path("outputs", paste0("PCA_PC1_PC2_by_", color_column, ".png")),
    width = 8,
    height = 6,
    dpi = 180
  )
}

for (column in c("Diagnosis", "OriginalRegion", "Age", "Sex", "RIN", "PMI", "pH", "Batch")) {
  plot_pca(column)
}

scree_df <- data.frame(
  PC = factor(paste0("PC", seq_along(variance_explained)), levels = paste0("PC", seq_along(variance_explained))),
  variance_explained = variance_explained
)

ggplot(head(scree_df, 20), aes(x = PC, y = variance_explained)) +
  geom_col(fill = "gray35") +
  theme_minimal(base_size = 14) +
  labs(
    title = "PCA variance explained",
    x = "Principal component",
    y = "Variance explained"
  )

ggsave("outputs/PCA_scree_plot.png", width = 9, height = 5, dpi = 180)

message("PCA complete. Results written to outputs/.")

