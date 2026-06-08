# PCA and LLM Guide

This repository explains how to make, read, and responsibly use Principal Component Analysis (PCA), with examples from gene-expression data and a short bridge to large language models (LLMs).

The main idea:

> PCA finds the biggest directions of variation in a large table. In gene expression, that helps you see sample structure before modeling. In LLMs, similar dimensionality-reduction ideas help you inspect high-dimensional embeddings.

## Repository Map

- `docs/01_how_pca_is_made.md` explains PCA step by step.
- `docs/02_interpreting_gene_expression_pca.md` explains your frontal cortex PCA plots.
- `docs/03_pca_and_llms.md` connects PCA to embeddings and LLM workflows.
- `docs/04_plot_gallery.md` displays the example figures.
- `docs/05_pca_interpretation_checklist.md` gives a reusable PCA checklist.
- `scripts/run_pca_template.R` is an R template for RNA-seq style PCA.
- `scripts/pca_embeddings_example.py` is a Python example for PCA on text embeddings or numeric vectors.
- `prompts/pca_interpretation_prompt.md` is a reusable LLM prompt for interpreting PCA plots.
- `assets/frontal_cortex_pca/` contains example PCA/QC plots.

## What PCA Is For

Use PCA before final modeling to ask:

1. Are samples clustering by batch, brain region, diagnosis, sex, or another variable?
2. Are technical variables such as RIN, PMI, or pH driving the main structure?
3. Are there outlier samples?
4. Which covariates should be included in the downstream model?

PCA is not usually the final answer. It is a map of the data.

## How PCA Is Calculated

PCA starts from a numeric matrix:

```text
rows    = samples, documents, or observations
columns = genes, features, or embedding dimensions
```

Then it:

1. Cleans and normalizes the matrix.
2. Centers each feature by subtracting its mean.
3. Optionally scales features to similar ranges.
4. Finds new axes that capture the largest variation.
5. Projects every sample onto those axes.

The first new axis is `PC1`, the biggest direction of variation. `PC2` is the next biggest independent direction. In your example, `PC1 = 34.4%` and `PC2 = 13.7%`, so the first two PCs explain about `48.1%` of the main variation.

For a deeper step-by-step explanation, see [docs/01_how_pca_is_made.md](docs/01_how_pca_is_made.md).

## Quick Interpretation of the Example

In the frontal cortex example, PC1 explains about 34.4% of the variation and PC2 explains about 13.7%. Together they show a large part of the main structure.

### Scree Plot: How Much Each PC Explains

![PCA variance explained](assets/frontal_cortex_pca/PCA_scree_plot_top5000_variable_genes.png)

This plot tells you that PC1 is much larger than the later PCs. That means one dominant source of variation exists in the expression data.

### PCA Colored by Original Region

![PCA colored by OriginalRegion](assets/frontal_cortex_pca/PCA_PC1_PC2_by_OriginalRegion.png)

The strongest visible pattern is not diagnosis. It is `OriginalRegion`: Cg25, dlPFC, and OFC separate clearly. That means region should probably be included as a covariate when analyzing grouped frontal cortex samples.

### PCA Colored by Diagnosis

![PCA colored by Diagnosis](assets/frontal_cortex_pca/PCA_PC1_PC2_by_Diagnosis.png)

Diagnosis remains the biological question of interest, but it is mixed across the PCA plot. That suggests depression-related expression differences may be subtler and should be tested gene by gene using a model such as:

```text
expression_gene ~ Diagnosis + Age + Sex + RIN + OriginalRegion + (1 | BrainID)
```

PMI and pH may also be considered depending on missingness, collinearity, and model stability.

### Covariate Association Heatmap

![Covariate association heatmap](assets/frontal_cortex_pca/PC_covariate_R2_heatmap.png)

This heatmap summarizes which covariates explain each PC. A bright cell means that covariate is strongly associated with that PC. In your data, region-related structure is the clearest signal.

## How to Run the Examples

The scripts are templates. They are meant to be copied and adapted to your actual expression matrix and metadata.

For R:

```powershell
Rscript scripts/run_pca_template.R
```

For Python:

```powershell
python scripts/pca_embeddings_example.py
```

The Python file uses synthetic data so it can run without private datasets.

## Good Rule

When reading a PCA plot, ask:

> Does this variable visibly structure the samples?

If yes, it is a strong candidate covariate. If no, it may still matter biologically, but PCA is not showing it as one of the dominant sources of variation.
