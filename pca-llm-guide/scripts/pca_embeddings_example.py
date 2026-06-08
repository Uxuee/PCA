"""PCA example for embeddings or other high-dimensional numeric vectors.

This script uses synthetic vectors so it can run without private data.
Replace the synthetic section with a CSV of real embeddings when needed.
"""

from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler


OUTPUT_DIR = Path("outputs")
OUTPUT_DIR.mkdir(exist_ok=True)


def make_synthetic_embeddings(seed: int = 7) -> tuple[pd.DataFrame, pd.DataFrame]:
    rng = np.random.default_rng(seed)

    topics = ["neuroscience", "oncology", "cardiology"]
    centers = np.array(
        [
            [2.0, 0.0, 0.5],
            [-1.5, 1.5, -0.2],
            [-0.5, -1.7, 0.8],
        ]
    )

    rows = []
    meta_rows = []
    for topic_index, topic in enumerate(topics):
        base = centers[topic_index]
        for i in range(30):
            first_dims = base + rng.normal(0, 0.55, size=3)
            noise_dims = rng.normal(0, 0.35, size=47)
            vector = np.concatenate([first_dims, noise_dims])
            doc_id = f"{topic}_{i:02d}"
            rows.append((doc_id, vector))
            meta_rows.append({"doc_id": doc_id, "topic": topic})

    embeddings = pd.DataFrame(
        [vector for _, vector in rows],
        index=[doc_id for doc_id, _ in rows],
        columns=[f"dim_{i:03d}" for i in range(50)],
    )
    metadata = pd.DataFrame(meta_rows)
    return embeddings, metadata


def run_pca(matrix: pd.DataFrame, metadata: pd.DataFrame) -> pd.DataFrame:
    scaled = StandardScaler().fit_transform(matrix)
    pca = PCA(n_components=10, random_state=0)
    scores = pca.fit_transform(scaled)

    result = pd.DataFrame(scores[:, :2], columns=["PC1", "PC2"])
    result["doc_id"] = matrix.index.to_numpy()
    result = result.merge(metadata, on="doc_id", how="left")

    variance = pd.DataFrame(
        {
            "PC": [f"PC{i + 1}" for i in range(len(pca.explained_variance_ratio_))],
            "variance_explained": pca.explained_variance_ratio_,
        }
    )
    variance.to_csv(OUTPUT_DIR / "embedding_pca_variance_explained.csv", index=False)
    result.to_csv(OUTPUT_DIR / "embedding_pca_scores.csv", index=False)
    return result, pca.explained_variance_ratio_


def plot_scores(scores: pd.DataFrame, variance: np.ndarray) -> None:
    fig, ax = plt.subplots(figsize=(8, 6))

    for topic, group in scores.groupby("topic"):
        ax.scatter(group["PC1"], group["PC2"], label=topic, alpha=0.85, s=55)

    ax.set_title("PCA of synthetic text embeddings")
    ax.set_xlabel(f"PC1 ({variance[0] * 100:.1f}%)")
    ax.set_ylabel(f"PC2 ({variance[1] * 100:.1f}%)")
    ax.legend(title="Topic")
    ax.grid(alpha=0.25)
    fig.tight_layout()
    fig.savefig(OUTPUT_DIR / "embedding_pca_by_topic.png", dpi=180)


def main() -> None:
    embeddings, metadata = make_synthetic_embeddings()
    scores, variance = run_pca(embeddings, metadata)
    plot_scores(scores, variance)
    print("PCA complete. Results written to outputs/.")


if __name__ == "__main__":
    main()

