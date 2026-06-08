# PCA and LLMs

PCA is useful for LLM work because LLMs often represent text as high-dimensional vectors.

These vectors are called embeddings.

## What Is an Embedding?

An embedding is a numeric representation of text.

Example:

```text
"major depression in frontal cortex" -> [0.02, -0.14, 0.31, ...]
```

The vector may have hundreds or thousands of dimensions. Humans cannot inspect that directly, so dimensionality reduction methods such as PCA help make maps.

## PCA on Embeddings

If each row is a document and each column is an embedding dimension, PCA can show:

- whether similar texts cluster together
- whether labels or categories separate
- whether one source, batch, or writing style dominates the embedding space
- whether there are outlier documents

This is similar to gene-expression PCA:

| Gene expression PCA | LLM embedding PCA |
| --- | --- |
| sample | document or chunk |
| gene | embedding dimension |
| diagnosis, region, RIN | label, source, author, timestamp |
| batch effect | collection/source effect |
| outlier sample | outlier text |

## Example Uses

### 1. Inspect a Document Dataset

Suppose you embed abstracts about neuroscience, oncology, and cardiology. PCA may show three clusters. That means the embedding model places these topics in different regions of vector space.

### 2. Check for Confounding

Suppose documents from hospital A and hospital B separate more strongly than disease labels.

That tells you:

> The model may learn hospital/source differences instead of disease differences.

This is the same logic as original brain region structuring a gene-expression PCA.

### 3. Find Outliers

If one text is far from all others, inspect it. It may be:

- a wrong file
- a different language
- a table or corrupted document
- a very unusual topic

### 4. Summarize Clusters With an LLM

After PCA shows clusters, an LLM can help summarize the documents in each cluster. But the LLM should not invent statistical conclusions. It should use the PCA as exploratory evidence.

## Responsible LLM Use

LLMs can help explain plots and draft interpretation, but they should follow these rules:

- Do not claim significance from PCA alone.
- Do not say PCA proves causality.
- Do not overinterpret mixed clusters.
- Always distinguish visible structure from formal statistical testing.
- Use metadata and downstream models to confirm hypotheses.

## Good Prompt Pattern

Give the LLM:

1. what rows represent
2. what columns represent
3. variance explained by PCs
4. what each color means
5. what downstream decision you need

Then ask for:

- visible patterns
- possible confounders
- model covariate suggestions
- cautions and limitations

