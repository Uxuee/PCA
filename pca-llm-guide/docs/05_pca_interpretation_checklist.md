# PCA Interpretation Checklist

Use this checklist whenever you make a PCA plot.

## Before PCA

- Confirm samples and metadata are aligned.
- Remove failed samples and unusable metadata.
- Normalize the feature matrix.
- Remove features with zero or near-zero variance.
- Decide whether to use all features or the top variable features.

## During PCA

- Record the preprocessing choices.
- Save PC scores for each sample.
- Save variance explained for each PC.
- Plot PC1-PC2 and inspect later PCs if needed.

## After PCA

For every metadata variable, ask:

- Do colors form clear clusters?
- Is there a smooth gradient?
- Are outliers concentrated in one group?
- Does a technical variable explain more structure than the biological variable of interest?
- Does the pattern suggest a covariate for the downstream model?

## Interpretation Language

Use careful wording:

- "Samples appear to separate by original region."
- "Diagnosis does not appear to dominate PC1-PC2."
- "RIN may contribute to variation, but it is not the strongest visible driver."
- "This suggests a covariate to consider."

Avoid overclaiming:

- "PCA proves diagnosis has no effect."
- "This PCA identifies the disease genes."
- "This cluster is statistically significant."
- "This variable causes the separation."

## Downstream Model Decision

PCA can suggest covariates, but the final model should also consider:

- study design
- missingness
- collinearity
- sample size
- repeated donors or paired samples
- biological plausibility
- model diagnostics

