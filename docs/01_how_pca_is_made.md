# How PCA Is Made

PCA starts with a data table.

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

## Step 3: Scale If Appropriate

Scaling divides each column by its standard deviation.

Use scaling when features have very different units or ranges.

For gene expression, scaling depends on the scientific question. If highly variable genes should dominate, scaling every gene equally may not be ideal. Many RNA-seq workflows instead choose the top variable genes after normalization.

For embeddings, dimensions are usually already in comparable units, but scaling can still be tested.

## Step 4: Find New Axes

PCA creates new axes called principal components:

- `PC1`: the direction explaining the most variation
- `PC2`: the next direction explaining the most remaining variation
- `PC3`: the next, and so on

Each PC is a weighted combination of the original variables.

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

