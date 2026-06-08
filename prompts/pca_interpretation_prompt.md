# PCA Interpretation Prompt

Use this prompt when asking an LLM to help interpret PCA plots.

```text
I am analyzing a high-dimensional dataset with PCA.

Rows are:
[describe samples/documents]

Columns are:
[describe genes/features/embedding dimensions]

PCA preprocessing:
[normalization, filtering, scaling, top variable features, missing data handling]

PC variance explained:
[PC1 %, PC2 %, PC3 %, etc.]

Metadata variables shown:
[diagnosis, region, age, sex, RIN, PMI, pH, batch, source, labels]

Please interpret the PCA carefully.

For each plot:
1. Describe visible structure.
2. Say which metadata variable appears to explain the structure.
3. Say what this suggests for downstream modeling.
4. Say what cannot be concluded from PCA alone.
5. Avoid claiming statistical significance unless a formal test is provided.

My downstream goal is:
[differential expression, clustering documents, checking confounders, building a classifier]
```

## Short Version

```text
Interpret this PCA as exploratory QC. Tell me what appears to structure the samples, which covariates I should consider, and what PCA cannot prove.
```

