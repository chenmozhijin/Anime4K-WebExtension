import json
import os
from datetime import datetime, timezone
from pathlib import Path

import cv2
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
RESULT_ROOT = ROOT / os.environ.get(
    "PRESET_RESULT_ROOT",
    "test-results/user-image-evaluation/formal-evaluation/preset-finalists-6",
)
OUTPUT_ROOT = RESULT_ROOT / "outputs"
OUTPUT = RESULT_ROOT / "difference-index.json"
INSPECTION_ROOT = RESULT_ROOT / "inspection"

CHAINS = [
    "cunny-4x16-ds",
    "acnet-f8b18-box-hdn",
    "acnet-f8b18-hdn-cunny-4x16-ds",
    "acnet-f8b18-box-hdn-cunny-4x16-ds",
]

PAIRS = [
    (
        "acnet-f8b18-hdn-cunny-4x16-ds",
        "acnet-f8b18-box-hdn",
        "HDN plus CuNNy versus ACNet Box HDN",
    ),
    (
        "acnet-f8b18-box-hdn-cunny-4x16-ds",
        "acnet-f8b18-box-hdn",
        "Box HDN plus CuNNy versus ACNet Box HDN",
    ),
    (
        "acnet-f8b18-hdn-cunny-4x16-ds",
        "acnet-f8b18-box-hdn-cunny-4x16-ds",
        "HDN versus Box HDN before CuNNy",
    ),
    (
        "acnet-f8b18-hdn-cunny-4x16-ds",
        "cunny-4x16-ds",
        "HDN plus CuNNy versus CuNNy",
    ),
]


def read_rgb(path: Path) -> np.ndarray:
    image = cv2.imread(str(path), cv2.IMREAD_COLOR)
    if image is None:
        raise RuntimeError(f"Unable to read {path}")
    return cv2.cvtColor(image, cv2.COLOR_BGR2RGB).astype(np.float32) / 255.0


def edge_energy(rgb: np.ndarray) -> float:
    luma = rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722
    gx = cv2.Sobel(luma, cv2.CV_32F, 1, 0, ksize=3)
    gy = cv2.Sobel(luma, cv2.CV_32F, 0, 1, ksize=3)
    return float(np.mean(np.sqrt(gx * gx + gy * gy)))


def top_difference_regions(delta: np.ndarray, size: int = 256, stride: int = 128) -> list[dict]:
    height, width = delta.shape
    tile_size = min(size, height, width)
    candidates = []
    for y in range(0, max(1, height - tile_size + 1), stride):
        for x in range(0, max(1, width - tile_size + 1), stride):
            score = float(np.mean(delta[y : y + tile_size, x : x + tile_size]))
            candidates.append({"x": x, "y": y, "size": tile_size, "mae": score})
    candidates.sort(key=lambda item: item["mae"], reverse=True)
    selected = []
    for candidate in candidates:
        if all(
            abs(candidate["x"] - existing["x"]) >= tile_size
            or abs(candidate["y"] - existing["y"]) >= tile_size
            for existing in selected
        ):
            selected.append(candidate)
        if len(selected) == 3:
            break
    return selected


def compare(first: np.ndarray, second: np.ndarray) -> dict:
    absolute = np.abs(first - second)
    pixel_delta = np.mean(absolute, axis=2)
    first_edge = edge_energy(first)
    second_edge = edge_energy(second)
    return {
        "mae": float(np.mean(absolute)),
        "p95Abs": float(np.quantile(absolute, 0.95)),
        "changedPixelFraction1Over255": float(
            np.mean(np.max(absolute, axis=2) > (1.0 / 255.0))
        ),
        "edgeEnergyFirst": first_edge,
        "edgeEnergySecond": second_edge,
        "edgeEnergyRatio": first_edge / second_edge if second_edge else 1.0,
        "topDifferenceRegions": top_difference_regions(pixel_delta),
    }


def discover_cases() -> list[dict]:
    cases = []
    for source_dir in sorted(path for path in OUTPUT_ROOT.iterdir() if path.is_dir()):
        for input_dir in sorted(path for path in source_dir.iterdir() if path.is_dir()):
            crop_dir = input_dir / "crops-1x-native"
            for crop_id in ("crop-a", "crop-b"):
                paths = {
                    chain: crop_dir / f"{chain}--{crop_id}.png"
                    for chain in CHAINS
                }
                if not all(path.exists() for path in paths.values()):
                    raise RuntimeError(f"Incomplete finalist outputs in {crop_dir}/{crop_id}")
                images = {chain: read_rgb(path) for chain, path in paths.items()}
                pairs = []
                for first, second, label in PAIRS:
                    pairs.append(
                        {
                            "label": label,
                            "first": first,
                            "second": second,
                            **compare(images[first], images[second]),
                        }
                    )
                primary_region = pairs[0]["topDifferenceRegions"][0]
                inspection_dir = INSPECTION_ROOT / input_dir.name / crop_id
                inspection_dir.mkdir(parents=True, exist_ok=True)
                x = primary_region["x"]
                y = primary_region["y"]
                size = primary_region["size"]
                for chain, image in images.items():
                    crop = image[y : y + size, x : x + size]
                    encoded = cv2.cvtColor(
                        np.clip(crop * 255.0, 0, 255).astype(np.uint8),
                        cv2.COLOR_RGB2BGR,
                    )
                    path = inspection_dir / f"{chain}.png"
                    if not cv2.imwrite(str(path), encoded):
                        raise RuntimeError(f"Unable to write {path}")
                cases.append(
                    {
                        "sourceClass": source_dir.name,
                        "inputId": input_dir.name,
                        "cropId": crop_id,
                        "width": next(iter(images.values())).shape[1],
                        "height": next(iter(images.values())).shape[0],
                        "inspectionRegion": primary_region,
                        "inspectionPath": str(inspection_dir.relative_to(ROOT)).replace("\\", "/"),
                        "pairs": pairs,
                    }
                )
    return cases


def main() -> None:
    cases = discover_cases()
    OUTPUT.write_text(
        json.dumps(
            {
                "schemaVersion": 1,
                "generatedAt": datetime.now(timezone.utc).isoformat(),
                "cases": cases,
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    print(f"Preset finalist difference index: {OUTPUT}")


if __name__ == "__main__":
    main()
