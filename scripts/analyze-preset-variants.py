import argparse
import itertools
import json
from pathlib import Path

import cv2
import numpy as np


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Compare image outputs across preset variants.")
    parser.add_argument("--outputs", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--inspection", required=True, type=Path)
    parser.add_argument(
        "--chains",
        required=True,
        help="Comma-separated variant IDs to compare.",
    )
    return parser.parse_args()


def parse_variants(value: str) -> list[str]:
    variants = [item.strip() for item in value.split(",") if item.strip()]
    if len(variants) < 2:
        raise ValueError("--chains must contain at least two variant IDs.")
    if len(set(variants)) != len(variants):
        raise ValueError("--chains must not contain duplicate variant IDs.")
    return variants


def build_pairs(variants: list[str]) -> list[tuple[str, str, str]]:
    return [(first, second, f"{first} vs {second}") for first, second in itertools.combinations(variants, 2)]


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


def crop_ids(crop_dir: Path, variants: list[str]) -> list[str]:
    available = {}
    for variant in variants:
        prefix = f"{variant}--"
        available[variant] = {
            path.name[len(prefix) : -4]
            for path in crop_dir.iterdir()
            if path.is_file() and path.name.startswith(prefix) and path.name.endswith(".png")
        }
    common = set.intersection(*(values for values in available.values()))
    return sorted(common)


def discover_cases(
    output_root: Path,
    inspection_root: Path,
    variants: list[str],
    pairs: list[tuple[str, str, str]],
) -> list[dict]:
    if not output_root.exists():
        raise FileNotFoundError(f"Output directory does not exist: {output_root}")

    cases = []
    for source_dir in sorted(path for path in output_root.iterdir() if path.is_dir()):
        for input_dir in sorted(path for path in source_dir.iterdir() if path.is_dir()):
            crop_dirs = sorted(
                path for path in input_dir.iterdir()
                if path.is_dir() and path.name.startswith("crops-")
            )
            for crop_dir in crop_dirs:
                for crop_id in crop_ids(crop_dir, variants):
                    paths = {
                        variant: crop_dir / f"{variant}--{crop_id}.png"
                        for variant in variants
                    }
                    images = {variant: read_rgb(path) for variant, path in paths.items()}
                    pair_reports = [
                        {
                            "label": label,
                            "first": first,
                            "second": second,
                            **compare(images[first], images[second]),
                        }
                        for first, second, label in pairs
                    ]
                    primary_region = max(
                        (region for pair in pair_reports for region in pair["topDifferenceRegions"]),
                        key=lambda region: region["mae"],
                    )
                    inspection_dir = inspection_root / input_dir.name / crop_id
                    inspection_dir.mkdir(parents=True, exist_ok=True)
                    x = primary_region["x"]
                    y = primary_region["y"]
                    size = primary_region["size"]
                    for variant, image in images.items():
                        crop = image[y : y + size, x : x + size]
                        encoded = cv2.cvtColor(
                            np.clip(crop * 255.0, 0, 255).astype(np.uint8),
                            cv2.COLOR_RGB2BGR,
                        )
                        path = inspection_dir / f"{variant}.png"
                        if not cv2.imwrite(str(path), encoded):
                            raise RuntimeError(f"Unable to write {path}")
                    cases.append(
                        {
                            "sourceClass": source_dir.name,
                            "inputId": input_dir.name,
                            "cropId": crop_id,
                            "width": next(iter(images.values())).shape[1],
                            "height": next(iter(images.values())).shape[0],
                            "inspectionFiles": [f"{variant}.png" for variant in variants],
                            "inspectionRegion": primary_region,
                            "pairs": pair_reports,
                        }
                    )
    return cases


def main() -> None:
    args = parse_args()
    variants = parse_variants(args.chains)
    pairs = build_pairs(variants)
    cases = discover_cases(args.outputs, args.inspection, variants, pairs)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(
            {
                "schemaVersion": 1,
                "variants": variants,
                "cases": cases,
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    print(f"Preset variant difference index: {args.output}")


if __name__ == "__main__":
    try:
        main()
    except (FileNotFoundError, RuntimeError, ValueError) as error:
        raise SystemExit(str(error)) from error
