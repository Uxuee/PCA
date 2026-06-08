# Plot Gallery

These plots come from the frontal cortex PCA/covariate exploration example.

## Main PCA Figures

### PCA Colored by Original Region

![PCA colored by OriginalRegion](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_OriginalRegion.png)

Key point: original frontal subregions separate clearly, so `OriginalRegion` is a strong candidate covariate.

### PCA Colored by Diagnosis

![PCA colored by Diagnosis](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_Diagnosis.png)

Key point: CTRL and MDD are mixed. Diagnosis is still the target variable, but it is not the largest global source of variation.

### PCA Variance Explained

![PCA scree plot](../assets/frontal_cortex_pca/PCA_scree_plot_top5000_variable_genes.png)

Key point: PC1 and PC2 explain a large share of the main variation, but later PCs can still matter.

### Covariate Association Heatmap

![PC covariate R2 heatmap](../assets/frontal_cortex_pca/PC_covariate_R2_heatmap.png)

Key point: use this plot to identify which metadata variables are associated with each PC.

## Technical and Biological Covariates

### Age

![PCA colored by Age](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_Age.png)

### Sex

![PCA colored by Sex](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_Sex.png)

### RIN

![PCA colored by RIN](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_RIN.png)

### PMI

![PCA colored by PMI](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_PMI.png)

### pH

![PCA colored by pH](../assets/frontal_cortex_pca/PCA_PC1_PC2_by_pH.png)

## Covariate Balance Checks

### Diagnosis by Original Region

![Diagnosis by original region](../assets/frontal_cortex_pca/diagnosis_by_original_region.png)

### Boxplots by Diagnosis

![Age by diagnosis](../assets/frontal_cortex_pca/boxplot_Age_by_diagnosis.png)

![RIN by diagnosis](../assets/frontal_cortex_pca/boxplot_RIN_by_diagnosis.png)

![PMI by diagnosis](../assets/frontal_cortex_pca/boxplot_PMI_by_diagnosis.png)

![pH by diagnosis](../assets/frontal_cortex_pca/boxplot_pH_by_diagnosis.png)

