# How PCA Is Made

PCA starts with a data table. The technical name is a matrix.

For gene expression, rows are often samples and columns are genes:

```text
sample_id    gene_1    gene_2    gene_3    ...
S1           8.2       3.1       0.5
S2           7.9       3.4       0.7
S3           2.1       9.8       4.5
```

For LLM embeddings, rows are texts and columns are embedding dimensions:

```text
text_id      dim_1     dim_2     dim_3     ...
T1           0.02      -0.14     0.31
T2           0.04      -0.11     0.29
T3          -0.48       0.55    -0.10
```

The PCA workflow is the same.

## The Short Version

PCA asks:

> Which directions through this high-dimensional cloud explain the most variation?

If you have 5,000 genes, each sample is a point in 5,000-dimensional space. PCA rotates that space and creates new axes:

- `PC1`: the direction where samples spread out the most
- `PC2`: the next biggest direction, independent of PC1
- `PC3`: the next biggest direction, independent of PC1 and PC2

The new axes are ordered from most variation to least variation.

## Step 1: Clean the Matrix

Before PCA, make sure the matrix is numeric and aligned with metadata.

For RNA-seq:

- remove genes with very low expression
- normalize counts
- often log-transform or variance-stabilize expression
- remove samples with missing or failed metadata

For embeddings:

- make sure every text has one vector
- avoid mixing embeddings from different models unless that is intentional
- optionally standardize dimensions if needed

## Step 2: Center the Features

PCA usually subtracts the mean of each column.

That means each gene or embedding dimension is recentered around zero.

This matters because PCA is looking for variation around the average profile.

Formula:

```text
centered_value = original_value - mean_of_that_feature
```

Example:

```text
gene_1 values:        8, 10, 12
mean of gene_1:       10
centered gene_1:     -2,  0,  2
```

## Step 3: Scale If Appropriate

Scaling divides each column by its standard deviation.

Use scaling when features have very different units or ranges.

For gene expression, scaling depends on the scientific question. If highly variable genes should dominate, scaling every gene equally may not be ideal. Many RNA-seq workflows instead choose the top variable genes after normalization.

For embeddings, dimensions are usually already in comparable units, but scaling can still be tested.

Formula:

```text
scaled_value = (original_value - feature_mean) / feature_standard_deviation
```

## Step 4: Find New Axes

PCA creates new axes called principal components:

- `PC1`: the direction explaining the most variation
- `PC2`: the next direction explaining the most remaining variation
- `PC3`: the next, and so on

Each PC is a weighted combination of the original variables.

There are two common ways software calculates these axes:

1. Covariance/eigen decomposition.
2. Singular value decomposition, often called SVD.

You usually do not need to calculate these by hand, but the idea is:

```text
centered_matrix -> find directions of maximum variance -> PC axes
```

In R, this is done with:

```r
pca <- prcomp(expression_matrix, center = TRUE, scale. = FALSE)
```

In Python, this is done with:

```python
pca = PCA(n_components=10)
scores = pca.fit_transform(matrix)
```

## What Scores and Loadings Mean

PCA produces two important tables.

### Scores

Scores tell you where each sample lands on each PC.

Example:

```text
sample_id    PC1      PC2
S1          -12.5      4.1
S2           -8.2      9.7
S3           31.0     -6.3
```

These are the coordinates used in a PCA scatter plot.

### Loadings

Loadings tell you how much each gene or feature contributes to each PC.

Example:

```text
gene_id    PC1_loading    PC2_loading
gene_A       0.18          -0.02
gene_B      -0.11           0.20
gene_C       0.03           0.15
```

Genes with large positive or negative loadings are major contributors to that PC.

## Step 5: Project Samples Onto the PCs

Every sample gets a coordinate on each PC.

A PCA scatter plot usually shows:

- x-axis: PC1 score
- y-axis: PC2 score
- point: one sample
- color: metadata variable, such as diagnosis, region, age, sex, RIN, PMI, or pH

## Step 6: Read Variance Explained

The variance explained tells you how much of the total variation each PC captures.

Example:

```text
PC1 = 34.4%
PC2 = 13.7%
```

This means PC1 and PC2 together capture 48.1% of the variation used in that PCA.

That is why PC1-PC2 plots are useful, but not complete. Later PCs can still contain important structure.

How it is calculated:

```text
variance_explained_for_PC1 = variance_of_PC1 / total_variance
```

In R:

```r
variance_explained <- pca$sdev^2 / sum(pca$sdev^2)
```

In Python:

```python
variance_explained = pca.explained_variance_ratio_
```

## Why Use the Top Variable Genes?

For RNA-seq PCA, it is common to use the top variable genes, such as the top 5,000 variable genes.

Why?

Genes that barely change across samples mostly add noise. Highly variable genes are more useful for seeing sample structure.

This does not mean the other genes are unimportant for differential expression. It only means the PCA map is clearer when it uses features that carry variation.

## Important PCA Outputs

### Scores

Scores are the sample coordinates on each PC. Use these to plot samples.

### Loadings

Loadings are the weights of genes or dimensions on each PC. Use these to understand which variables drive a PC.

### Scree Plot

A scree plot shows variance explained by each PC. It helps decide how many PCs are worth inspecting.

### Covariate Association Heatmap

A covariate heatmap asks whether metadata variables explain each PC. For example, it can show that `OriginalRegion` explains PC1 strongly.

## PCA Checklist

- Did I normalize the data first?
- Did I remove uninformative features?
- Are samples and metadata aligned?
- Did I inspect PC1 vs PC2 and later PCs?
- Did I color PCA by biological and technical covariates?
- Did I avoid treating PCA as a significance test?
