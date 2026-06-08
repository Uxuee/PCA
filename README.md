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

## Quick Interpretation of the Example

In the frontal cortex example, PC1 explains about 34.4% of the variation and PC2 explains about 13.7%. Together they show a large part of the main structure.

The strongest visible pattern is not diagnosis. It is `OriginalRegion`: Cg25, dlPFC, and OFC separate clearly. That means region should probably be included as a covariate when analyzing grouped frontal cortex samples.

Diagnosis remains the biological question of interest, but it is mixed across the PCA plot. That suggests depression-related expression differences may be subtler and should be tested gene by gene using a model such as:

```text
expression_gene ~ Diagnosis + Age + Sex + RIN + OriginalRegion + (1 | BrainID)
```

PMI and pH may also be considered depending on missingness, collinearity, and model stability.

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
