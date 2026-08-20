import json
from pathlib import Path

import cv2
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "test-results/user-image-evaluation/formal-corpus/formal-corpus-manifest.json"
NEW_ROOT = ROOT / "test-results/user-image-evaluation/formal-evaluation/quality-single-model-36/outputs"
BALANCED_ROOT = ROOT / "test-results/user-image-evaluation/formal-evaluation/balanced-formal-36/outputs"
TIER_ROOT = ROOT / "test-results/user-image-evaluation/formal-evaluation/tier-expansion-10/outputs"
OUTPUT = ROOT / "test-results/user-image-evaluation/formal-evaluation/quality-single-model-36/difference-index.json"


PAIRS = [
    ("cunny-8x32-ds", "cunny-4x16-ds", "CuNNy capacity 8x32 vs 4x16"),
    ("cunny-8x32-ds", "cunny-4x32-ds", "CuNNy capacity 8x32 vs 4x32"),
    ("current-cnnvl-cunny-8x32-ds", "cunny-8x32-ds", "Restore contribution before 8x32"),
    ("cunny-4x16-soft", "cunny-4x16-ds", "CuNNy 4x16 SOFT vs DS"),
    ("cunny-4x24-soft", "cunny-4x24-ds", "CuNNy 4x24 SOFT vs DS"),
    ("cunny-4x32-soft", "cunny-4x32-ds", "CuNNy 4x32 SOFT vs DS"),
    ("acnet-f8b8-hdn", "acnet-f8b8-neutral", "ACNet F8B8 HDN vs neutral"),
    ("acnet-f8b8-box", "acnet-f8b8-neutral", "ACNet F8B8 Box vs neutral"),
    ("acnet-f8b8-box-hdn", "acnet-f8b8-hdn", "ACNet F8B8 Box HDN vs HDN"),
    ("acnet-f8b18-hdn", "acnet-f8b18-neutral", "ACNet F8B18 HDN vs neutral"),
    ("acnet-f8b18-box", "acnet-f8b18-neutral", "ACNet F8B18 Box vs neutral"),
    ("acnet-f8b18-box-hdn", "acnet-f8b18-hdn", "ACNet F8B18 Box HDN vs HDN"),
    ("arnet-f8b16-hdn", "arnet-f8b16-neutral", "ARNet F8B16 HDN vs neutral"),
    ("arnet-f8b16-box", "arnet-f8b16-neutral", "ARNet F8B16 Box vs neutral"),
    ("arnet-f8b16-box-hdn", "arnet-f8b16-hdn", "ARNet F8B16 Box HDN vs HDN"),
    ("arnet-f8b32-hdn", "arnet-f8b32-neutral", "ARNet F8B32 HDN vs neutral"),
    ("arnet-f8b32-box", "arnet-f8b32-neutral", "ARNet F8B32 Box vs neutral"),
    ("arnet-f8b32-box-hdn", "arnet-f8b32-hdn", "ARNet F8B32 Box HDN vs HDN"),
    ("arnet-f8b64-hdn", "arnet-f8b64-neutral", "ARNet F8B64 HDN vs neutral"),
    ("arnet-f8b64-box", "arnet-f8b64-neutral", "ARNet F8B64 Box vs neutral"),
    ("arnet-f8b64-box-hdn", "arnet-f8b64-hdn", "ARNet F8B64 Box HDN vs HDN"),
    ("arnet-f8b64-neutral", "arnet-f8b32-neutral", "ARNet neutral B64 vs B32"),
    ("arnet-f8b64-hdn", "arnet-f8b32-hdn", "ARNet HDN B64 vs B32"),
    ("arnet-f8b64-box", "arnet-f8b32-box", "ARNet Box B64 vs B32"),
    ("arnet-f8b64-box-hdn", "arnet-f8b32-box-hdn", "ARNet Box HDN B64 vs B32"),
    ("artcnn-c4f16-dn", "artcnn-c4f16", "ArtCNN C4F16 DN vs neutral"),
    ("artcnn-c4f16-ds", "artcnn-c4f16-dn", "ArtCNN C4F16 DS vs DN"),
    ("artcnn-c4f32-dn", "artcnn-c4f32-neutral", "ArtCNN C4F32 DN vs neutral"),
    ("artcnn-c4f32-ds", "artcnn-c4f32-dn", "ArtCNN C4F32 DS vs DN"),
    ("artcnn-c4f32-neutral", "artcnn-c4f16", "ArtCNN neutral F32 vs F16"),
    ("artcnn-c4f32-dn", "artcnn-c4f16-dn", "ArtCNN DN F32 vs F16"),
    ("artcnn-c4f32-ds", "artcnn-c4f16-ds", "ArtCNN DS F32 vs F16"),
]


def output_path(source_class: str, input_id: str, chain_id: str) -> Path | None:
    for root in (NEW_ROOT, BALANCED_ROOT, TIER_ROOT):
        candidate = root / source_class / input_id / f"{chain_id}.png"
        if candidate.exists():
            return candidate
    return None


def read_rgb(path: Path) -> np.ndarray:
    # This index only locates visually interesting cases. Reduced decode avoids
    # repeatedly expanding hundreds of 4K PNGs; native files remain untouched.
    image = cv2.imread(str(path), cv2.IMREAD_REDUCED_COLOR_4)
    if image is None:
        raise RuntimeError(f"Unable to read {path}")
    return cv2.cvtColor(image, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0


def edge_energy(rgb: np.ndarray) -> float:
    luma = rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722
    gx = cv2.Sobel(luma, cv2.CV_32F, 1, 0, ksize=3)
    gy = cv2.Sobel(luma, cv2.CV_32F, 0, 1, ksize=3)
    return float(np.mean(np.sqrt(gx * gx + gy * gy)))


def compare(first: np.ndarray, second: np.ndarray) -> dict:
    delta = np.abs(first - second)
    first_edge = edge_energy(first)
    second_edge = edge_energy(second)
    return {
        "mae": float(np.mean(delta)),
        "p95Abs": float(np.quantile(delta, 0.95)),
        "maxAbs": float(np.max(delta)),
        "changedPixelFraction1Over255": float(np.mean(np.max(delta, axis=2) > (1.0 / 255.0))),
        "edgeEnergyFirst": first_edge,
        "edgeEnergySecond": second_edge,
        "edgeEnergyRatio": first_edge / second_edge if second_edge else 1.0,
        "meanSignedRgb": [float(value) for value in np.mean(first - second, axis=(0, 1))],
    }


def main() -> None:
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    inputs = [item for item in manifest["inputs"] if item.get("enabled", True)]
    pair_reports = []
    for first_id, second_id, label in PAIRS:
        cases = []
        for item in inputs:
            first_path = output_path(item["sourceClass"], item["id"], first_id)
            second_path = output_path(item["sourceClass"], item["id"], second_id)
            if first_path is None or second_path is None:
                continue
            metrics = compare(read_rgb(first_path), read_rgb(second_path))
            cases.append({
                "inputId": item["id"],
                "sourceClass": item["sourceClass"],
                "firstPath": str(first_path.relative_to(ROOT)).replace("\\", "/"),
                "secondPath": str(second_path.relative_to(ROOT)).replace("\\", "/"),
                **metrics,
            })
        ordered = sorted(cases, key=lambda item: item["mae"], reverse=True)
        pair_reports.append({
            "label": label,
            "first": first_id,
            "second": second_id,
            "caseCount": len(cases),
            "meanMae": float(np.mean([item["mae"] for item in cases])) if cases else None,
            "meanEdgeEnergyRatio": float(np.mean([item["edgeEnergyRatio"] for item in cases])) if cases else None,
            "largestDifferences": ordered[:6],
            "smallestDifferences": list(reversed(ordered[-3:])),
            "cases": ordered,
        })
    OUTPUT.write_text(json.dumps({
        "schemaVersion": 1,
        "generatedAt": __import__("datetime").datetime.now(__import__("datetime").timezone.utc).isoformat(),
        "pairs": pair_reports,
    }, indent=2), encoding="utf-8")
    print(f"Quality difference index: {OUTPUT}")


if __name__ == "__main__":
    main()
