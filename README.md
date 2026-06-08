# PCA and LLM Guide

This repository explains how to make, read, and responsibly use Principal Component Analysis (PCA), using real gene-expression PCA plots and a short connection to large language models (LLMs).

The main idea:

> PCA finds the biggest directions of variation in a large table. In gene expression, that helps you see sample structure before modeling. In LLMs, similar ideas help inspect high-dimensional text embeddings.

## What PCA Is For

Use PCA before final modeling to ask:

1. Are samples clustering by brain region, diagnosis, sex, batch, or another variable?
2. Are technical variables such as RIN, PMI, or pH driving the main structure?
3. Are there outlier samples?
4. Which covariates should be included in the downstream model?

PCA is not usually the final result. It is a map of the data before modeling.

## What PCA Starts With

PCA starts with a numeric matrix.

For gene expression, rows are samples and columns are genes:

```text
sample_id    gene_1    gene_2    gene_3    ...
S1           8.2       3.1       0.5
S2           7.9       3.4       0.7
S3           2.1       9.8       4.5
```

For LLM embeddings, rows are texts and columns are embedding dimensions:

```text
text_id      dim_1     dim_2     dim_3    ...
T1           0.02      -0.14     0.31
T2           0.04      -0.11     0.29
T3          -0.48       0.55    -0.10
```

In both cases, PCA asks:

> Which directions through this high-dimensional cloud explain the most variation?

If you have 5,000 genes, each sample is a point in 5,000-dimensional space. PCA rotates that space and creates new axes:

- `PC1`: the direction where samples spread out the most
- `PC2`: the next biggest direction, independent of PC1
- `PC3`: the next biggest direction, independent of PC1 and PC2

The PCs are ordered from most variation to least variation.

## How PCA Is Calculated

### Step 1: Clean and Normalize the Matrix

Before PCA, make sure the matrix is numeric and aligned with metadata.

For RNA-seq or gene expression:

- remove genes with very low expression
- normalize counts
- often log-transform or variance-stabilize expression
- remove samples with missing or failed metadata
- keep sample IDs aligned between expression data and metadata

For embeddings:

- make sure every text has one vector
- avoid mixing embeddings from different models unless intentional
- optionally standardize dimensions

### Step 2: Center Each Feature

PCA usually subtracts the mean of each column.

```text
centered_value = original_value - mean_of_that_feature
```

Example:

```text
gene_1 values:        8, 10, 12
mean of gene_1:       10
centered gene_1:     -2,  0,  2
```

This matters because PCA looks for variation around the average profile.

### Step 3: Scale If Needed

Scaling divides each feature by its standard deviation:

```text
scaled_value = (original_value - feature_mean) / feature_standard_deviation
```

Use scaling when features have very different units or ranges.

For gene expression, scaling depends on the question. Many RNA-seq workflows use normalized expression and then select the top variable genes instead of scaling every gene equally.

### Step 4: Find the Principal Components

PCA creates new axes called principal components. Each PC is a weighted combination of the original variables.

Software usually calculates PCA using either:

1. covariance/eigen decomposition
2. singular value decomposition, usually called SVD

The idea is:

```text
centered_matrix -> find directions of maximum variance -> PC axes
```

In R:

```r
pca <- prcomp(expression_matrix, center = TRUE, scale. = FALSE)
```

In Python:

```python
pca = PCA(n_components=10)
scores = pca.fit_transform(matrix)
```

### Step 5: Calculate Scores

Scores tell you where each sample lands on each PC.

```text
sample_id    PC1      PC2
S1          -12.5      4.1
S2           -8.2      9.7
S3           31.0     -6.3
```

These are the coordinates used in a PCA scatter plot.

### Step 6: Calculate Loadings

Loadings tell you how much each gene or feature contributes to each PC.

```text
gene_id    PC1_loading    PC2_loading
gene_A       0.18          -0.02
gene_B      -0.11           0.20
gene_C       0.03           0.15
```

Genes with large positive or negative loadings are major contributors to that PC.

### Step 7: Calculate Variance Explained

Variance explained tells you how much of the total variation each PC captures.

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

In this example:

```text
PC1 = 34.4%
PC2 = 13.7%
PC1 + PC2 = 48.1%
```

So the first two PCs show almost half of the main variation in the top variable genes used for PCA.

## Why Use Top Variable Genes?

For RNA-seq PCA, it is common to use the top variable genes, such as the top 5,000 variable genes.

Genes that barely change across samples mostly add noise to the PCA map. Highly variable genes make the sample structure easier to see.

This does not mean low-variation genes are useless for differential expression. It only means PCA is clearer when it uses features that carry variation.

## Interpreting the Frontal Cortex PCA Example

The example PCA was run inside a grouped frontal cortex dataset. The main question is:

> What is the biggest structure in the data before fitting differential-expression models?

### PCA Variance Explained

![PCA variance explained](assets/frontal_cortex_pca/PCA_scree_plot_top5000_variable_genes.png)

How to read this plot:

- the x-axis lists PCs
- the y-axis shows how much variation each PC explains
- PC1 is the tallest bar, so it is the biggest source of variation
- PC2 is smaller but still important
- later PCs explain less variation one by one

This tells us that PC1 is a dominant source of variation. PC1 and PC2 together explain about 48.1% of the variation.

## First Rule: PCA Is Exploratory

PCA does not prove that a variable is statistically significant. It shows visible structure.

Good PCA language:

> Samples appear to separate by original region.

Too strong:

> PCA proves original region causes the difference.

PCA helps decide what to check and what to include in the downstream model.

## PCA Colored by BrainArea

![PCA colored by BrainArea](assets/frontal_cortex_pca/PCA_PC1_PC2_by_BrainArea.png)

This plot is not very informative because all samples are labeled `Frontal_Cortex`.

That means the PCA is already inside one broad brain-area subset. Since there is only one broad `BrainArea`, it cannot explain differences among points.

## PCA Colored by OriginalRegion

![PCA colored by OriginalRegion](assets/frontal_cortex_pca/PCA_PC1_PC2_by_OriginalRegion.png)

This is the most important plot.

The grouped frontal cortex data still contains multiple original regions:

- Cg25
- dlPFC
- OFC

These regions separate clearly in PCA space.

Interpretation:

> The exact original frontal region is a major source of expression variation.

Modeling consequence:

> Include `OriginalRegion` as a covariate when analyzing grouped frontal cortex samples.

Plain-language example:

> If a gene is naturally higher in OFC than dlPFC, and MDD samples are not perfectly balanced across those regions, the model might accidentally call a region effect a diagnosis effect.

## PCA Colored by Diagnosis

![PCA colored by Diagnosis](assets/frontal_cortex_pca/PCA_PC1_PC2_by_Diagnosis.png)

CTRL and MDD are mixed across the PCA plot.

Interpretation:

> Diagnosis is not the largest global source of variation.

This does not mean diagnosis has no effect. In transcriptomics, disease effects can be gene-specific and subtle. PCA only shows the largest global patterns.

Modeling consequence:

> Keep `Diagnosis` in the model because it is the target variable, but do not expect PCA alone to identify depression genes.

## PCA Colored by Age

![PCA colored by Age](assets/frontal_cortex_pca/PCA_PC1_PC2_by_Age.png)

Age does not appear to define the main clusters in PC1-PC2.

Interpretation:

> Age may matter biologically, but it is not visually dominating the first two PCs.

Modeling consequence:

> Age is still reasonable to include as a covariate.

## PCA Colored by Sex

![PCA colored by Sex](assets/frontal_cortex_pca/PCA_PC1_PC2_by_Sex.png)

Male and female samples appear mixed.

Interpretation:

> Sex does not appear to dominate PC1-PC2.

Modeling consequence:

> Sex can remain a covariate because expression often differs by sex, even when the PCA signal is not dramatic.

## PCA Colored by RIN

![PCA colored by RIN](assets/frontal_cortex_pca/PCA_PC1_PC2_by_RIN.png)

RIN shows no obvious giant separation in PC1-PC2.

Interpretation:

> RNA quality may influence expression, but it is not the strongest visible driver in the first two PCs.

Modeling consequence:

> RIN is still a sensible technical covariate.

## PCA Colored by PMI

![PCA colored by PMI](assets/frontal_cortex_pca/PCA_PC1_PC2_by_PMI.png)

PMI does not visibly define the main PCA clusters.

Interpretation:

> PMI is not the dominant visible source of PC1-PC2 variation.

Modeling consequence:

> Consider PMI if metadata quality is good and missingness is acceptable.

## PCA Colored by pH

![PCA colored by pH](assets/frontal_cortex_pca/PCA_PC1_PC2_by_pH.png)

pH does not show a strong global gradient in PC1-PC2.

Interpretation:

> pH may matter, but it is not visually dominating the first two PCs.

Modeling consequence:

> Consider pH as a covariate if it is reliable and does not destabilize the model.

## Covariate Association Heatmap

![PC covariate R2 heatmap](assets/frontal_cortex_pca/PC_covariate_R2_heatmap.png)

The PCA scatter plots show patterns visually. The heatmap makes the same idea more systematic.

Each cell asks:

> How much of this PC is associated with this covariate?

Bright cells mean stronger association. Dark cells mean weaker association.

In this example, `OriginalRegion` has a strong relationship with the early PCs, especially PC1 and PC2. That supports the visual interpretation from the original-region PCA plot.

## Covariate Balance Checks

Before fitting a model, also check whether diagnosis groups are balanced across regions and technical variables.

### Diagnosis Balance by Original Region

![Diagnosis balance by original region](assets/frontal_cortex_pca/diagnosis_by_original_region.png)

This plot checks whether CTRL and MDD samples are distributed similarly across Cg25, dlPFC, and OFC.

### Age by Diagnosis

![Age by diagnosis](assets/frontal_cortex_pca/boxplot_Age_by_diagnosis.png)

The age distributions are not identical, so age is worth keeping as a biological covariate.

### RIN by Diagnosis

![RIN by diagnosis](assets/frontal_cortex_pca/boxplot_RIN_by_diagnosis.png)

RIN reflects RNA quality. Even without a dramatic PCA effect, it is usually a sensible technical covariate.

### PMI by Diagnosis

![PMI by diagnosis](assets/frontal_cortex_pca/boxplot_PMI_by_diagnosis.png)

PMI is postmortem interval. If PMI differs between groups or has missingness, it needs careful handling.

### pH by Diagnosis

![pH by diagnosis](assets/frontal_cortex_pca/boxplot_pH_by_diagnosis.png)

pH can reflect tissue quality and postmortem effects. Include it if metadata quality is good and the model remains stable.

## Recommended Starting Model

For grouped frontal cortex, a reasonable first mixed model is:

```text
expression_gene ~ Diagnosis + Age + Sex + RIN + OriginalRegion + (1 | BrainID)
```

Possible additions:

```text
expression_gene ~ Diagnosis + Age + Sex + RIN + PMI + pH + OriginalRegion + (1 | BrainID)
```

Choose the final formula after checking:

- missingness
- collinearity
- sample size
- repeated donors or paired samples
- model stability
- biological plausibility

## Main Biological Takeaway

The PCA is mainly saying:

> Grouped frontal cortex samples are still strongly structured by original region. Region should be accounted for before interpreting diagnosis effects.

Diagnosis remains the target variable, but it is not the biggest global pattern in the PCA.

## How PCA Relates to LLMs

LLMs often represent text as high-dimensional vectors called embeddings.

Example:

```text
"major depression in frontal cortex" -> [0.02, -0.14, 0.31, ...]
```

Those vectors may have hundreds or thousands of dimensions. PCA can reduce them to two or three dimensions for inspection.

The analogy:

| Gene expression PCA | LLM embedding PCA |
| --- | --- |
| sample | document or text chunk |
| gene | embedding dimension |
| diagnosis, region, RIN | label, source, author, timestamp |
| batch effect | collection/source effect |
| outlier sample | outlier text |

PCA on embeddings can help you see:

- whether similar documents cluster together
- whether labels or topics separate
- whether one source dominates the embedding space
- whether there are outlier documents
- whether a classifier might learn source effects instead of the desired label

The same warning applies:

> PCA can suggest structure, but it does not prove causality or significance.

## Good PCA Interpretation Rule

When reading a PCA plot, ask:

> Does this variable visibly structure the samples?

If yes, it is a strong candidate covariate. If no, it may still matter biologically, but PCA is not showing it as one of the dominant sources of variation.

In this example:

- `OriginalRegion`: yes, clearly structures the samples
- `Diagnosis`: mixed, but still the target variable
- `Age`, `Sex`, `RIN`, `PMI`, `pH`: weaker visual effects, but still possible covariates

## How to Run the Examples

The scripts are templates. They are meant to be adapted to your actual expression matrix and metadata.

For R:

```powershell
Rscript scripts/run_pca_template.R
```

For Python:

```powershell
python scripts/pca_embeddings_example.py
```

The Python file uses synthetic data so it can run without private datasets.

## Repository Files

- `README.md`: main tutorial and interpretation
- `assets/frontal_cortex_pca/`: PCA and covariate plots
- `scripts/run_pca_template.R`: R template for gene-expression PCA
- `scripts/pca_embeddings_example.py`: Python PCA example for embeddings
- `prompts/pca_interpretation_prompt.md`: reusable prompt for LLM-assisted PCA interpretation
- `docs/`: backup/deeper notes with the same concepts split into smaller files

