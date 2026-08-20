import argparse
import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

cv2.setNumThreads(2)


def read_rgb(path: Path) -> np.ndarray:
    return np.asarray(Image.open(path).convert("RGB"), dtype=np.uint8)


def write_rgb(path: Path, image: np.ndarray) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(np.clip(image, 0, 255).astype(np.uint8), "RGB").save(path)


def flow_to_neighbor(current: np.ndarray, neighbor: np.ndarray) -> np.ndarray:
    current_gray = cv2.cvtColor(current, cv2.COLOR_RGB2GRAY)
    neighbor_gray = cv2.cvtColor(neighbor, cv2.COLOR_RGB2GRAY)
    return cv2.calcOpticalFlowFarneback(
        current_gray,
        neighbor_gray,
        None,
        0.5,
        4,
        21,
        4,
        7,
        1.5,
        0,
    )


def flow_reliability(current: np.ndarray, neighbor: np.ndarray, forward: np.ndarray) -> np.ndarray:
    reverse = flow_to_neighbor(neighbor, current)
    height, width = forward.shape[:2]
    grid_x, grid_y = np.meshgrid(np.arange(width, dtype=np.float32), np.arange(height, dtype=np.float32))
    sampled_x = cv2.remap(
        reverse[..., 0], grid_x + forward[..., 0], grid_y + forward[..., 1],
        cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=100,
    )
    sampled_y = cv2.remap(
        reverse[..., 1], grid_x + forward[..., 0], grid_y + forward[..., 1],
        cv2.INTER_LINEAR, borderMode=cv2.BORDER_CONSTANT, borderValue=100,
    )
    error = np.hypot(forward[..., 0] + sampled_x, forward[..., 1] + sampled_y)
    reliable = (error <= 1.5).astype(np.uint8) * 255
    reliable = cv2.erode(reliable, np.ones((3, 3), np.uint8), iterations=1)
    return reliable


def warp_neighbor(neighbor: np.ndarray, flow: np.ndarray, size: tuple[int, int]) -> np.ndarray:
    height, width = size
    resized = cv2.resize(neighbor, (width, height), interpolation=cv2.INTER_LANCZOS4)
    scale_x = width / flow.shape[1]
    scale_y = height / flow.shape[0]
    up_flow = cv2.resize(flow, (width, height), interpolation=cv2.INTER_LINEAR)
    up_flow[..., 0] *= scale_x
    up_flow[..., 1] *= scale_y
    grid_x, grid_y = np.meshgrid(np.arange(width, dtype=np.float32), np.arange(height, dtype=np.float32))
    return cv2.remap(
        resized,
        grid_x + up_flow[..., 0],
        grid_y + up_flow[..., 1],
        cv2.INTER_LANCZOS4,
        borderMode=cv2.BORDER_REFLECT101,
    )


def temporal_composite(previous: np.ndarray, current: np.ndarray, following: np.ndarray) -> np.ndarray:
    previous_luma = cv2.cvtColor(previous, cv2.COLOR_RGB2GRAY)
    current_luma = cv2.cvtColor(current, cv2.COLOR_RGB2GRAY)
    following_luma = cv2.cvtColor(following, cv2.COLOR_RGB2GRAY)
    return np.stack([previous_luma, current_luma, following_luma], axis=-1)


def temporal_chroma(composite: np.ndarray) -> np.ndarray:
    values = composite.astype(np.float32)
    mean = values.mean(axis=2, keepdims=True)
    return np.abs(values - mean).mean(axis=2)


def best_crop(score: np.ndarray, crop_width: int, crop_height: int) -> tuple[int, int, int, int]:
    height, width = score.shape
    crop_width = min(crop_width, width)
    crop_height = min(crop_height, height)
    blurred = cv2.boxFilter(score.astype(np.float32), -1, (crop_width, crop_height), normalize=True)
    _, _, _, maximum = cv2.minMaxLoc(blurred)
    x = max(0, min(width - crop_width, maximum[0] - crop_width // 2))
    y = max(0, min(height - crop_height, maximum[1] - crop_height // 2))
    return x, y, crop_width, crop_height


def crop(image: np.ndarray, rectangle: tuple[int, int, int, int]) -> np.ndarray:
    x, y, width, height = rectangle
    return image[y:y + height, x:x + width]


def heat_overlay(current: np.ndarray, score: np.ndarray) -> np.ndarray:
    normalized = np.clip(score / max(1.0, np.percentile(score, 99.5)) * 255, 0, 255).astype(np.uint8)
    heat = cv2.applyColorMap(normalized, cv2.COLORMAP_TURBO)
    heat = cv2.cvtColor(heat, cv2.COLOR_BGR2RGB)
    return cv2.addWeighted(current, 0.55, heat, 0.45, 0)


def build_source_context(source_paths: list[Path], index: int, output_size: tuple[int, int]):
    source_previous = read_rgb(source_paths[index - 1])
    source_current = read_rgb(source_paths[index])
    source_following = read_rgb(source_paths[index + 1])
    previous_distance = float(np.abs(
        source_current.astype(np.int16) - source_previous.astype(np.int16)
    ).mean())
    following_distance = float(np.abs(
        source_current.astype(np.int16) - source_following.astype(np.int16)
    ).mean())
    if previous_distance > 20 or following_distance > 20:
        return None
    height, width = output_size
    previous_flow = flow_to_neighbor(source_current, source_previous)
    following_flow = flow_to_neighbor(source_current, source_following)
    previous_reliable = flow_reliability(source_current, source_previous, previous_flow)
    following_reliable = flow_reliability(source_current, source_following, following_flow)
    aligned_previous = warp_neighbor(source_previous, previous_flow, output_size)
    aligned_current = cv2.resize(source_current, (width, height), interpolation=cv2.INTER_LANCZOS4)
    aligned_following = warp_neighbor(source_following, following_flow, output_size)
    source_temporal = temporal_composite(aligned_previous, aligned_current, aligned_following)
    source_chroma = temporal_chroma(source_temporal)
    source_gray = cv2.cvtColor(aligned_current, cv2.COLOR_RGB2GRAY)
    source_gradient = cv2.magnitude(
        cv2.Sobel(source_gray, cv2.CV_32F, 1, 0, ksize=3),
        cv2.Sobel(source_gray, cv2.CV_32F, 0, 1, ksize=3),
    )
    reliability = cv2.resize(
        cv2.bitwise_and(previous_reliable, following_reliable),
        (width, height), interpolation=cv2.INTER_NEAREST,
    ).astype(np.float32) / 255
    reliability = cv2.erode(reliability, np.ones((5, 5), np.uint8), iterations=1)
    source_stable = (source_chroma < 12).astype(np.uint8)
    source_stable = cv2.erode(source_stable, np.ones((5, 5), np.uint8), iterations=1)
    return {
        "previousFlow": previous_flow,
        "followingFlow": following_flow,
        "sourceTemporal": source_temporal,
        "sourceChroma": source_chroma,
        "sourceGradient": source_gradient,
        "reliability": reliability,
        "sourceStable": source_stable,
    }


def score_candidate(output_paths: list[Path], index: int, context: dict, include_assets: bool = False) -> dict:
    output_previous = read_rgb(output_paths[index - 1])
    output_current = read_rgb(output_paths[index])
    output_following = read_rgb(output_paths[index + 1])
    height, width = output_current.shape[:2]
    aligned_previous = warp_neighbor(output_previous, context["previousFlow"], (height, width))
    aligned_following = warp_neighbor(output_following, context["followingFlow"], (height, width))
    output_temporal = temporal_composite(aligned_previous, output_current, aligned_following)
    output_chroma = temporal_chroma(output_temporal)
    output_gray = cv2.cvtColor(output_current, cv2.COLOR_RGB2GRAY)
    output_gradient = cv2.magnitude(
        cv2.Sobel(output_gray, cv2.CV_32F, 1, 0, ksize=3),
        cv2.Sobel(output_gray, cv2.CV_32F, 0, 1, ksize=3),
    )
    normalized_output = output_chroma / (2.0 + 0.20 * output_gradient)
    normalized_source = context["sourceChroma"] / (2.0 + 0.20 * context["sourceGradient"])
    normalized_excess = np.maximum(0.0, normalized_output - normalized_source)
    flat_excess = np.maximum(0.0, output_chroma - context["sourceChroma"]) * (output_gradient < 12)
    weighted = np.maximum(normalized_excess * 12.0, flat_excess)
    weighted *= context["reliability"] * context["sourceStable"]
    item = {
        "frameIndex": index,
        "scoreMean": float(weighted.mean()),
        "scoreP99": float(np.percentile(weighted, 99)),
        "scoreMax": float(weighted.max()),
        "reliableFraction": float(context["reliability"].mean()),
        "rectangle": best_crop(weighted, 512, 288),
    }
    if include_assets:
        item.update({
            "sourceTemporal": context["sourceTemporal"],
            "outputTemporal": output_temporal,
            "outputPrevious": aligned_previous,
            "outputCurrent": output_current,
            "outputFollowing": aligned_following,
            "overlay": heat_overlay(output_current, weighted),
        })
    return item


def select_events(scored: list[dict], top_events: int) -> list[dict]:
    ranked = sorted(scored, key=lambda item: (item["scoreP99"], item["scoreMean"]), reverse=True)
    selected = []
    for item in ranked:
        if any(abs(item["frameIndex"] - prior["frameIndex"]) < 5 for prior in selected):
            continue
        selected.append(item)
        if len(selected) >= top_events:
            break
    return selected


def analyze_clip_chains(
    source_paths: list[Path],
    output_paths_by_chain: dict[str, list[Path]],
    event_roots: dict[str, Path],
    top_events: int,
) -> dict[str, list[dict]]:
    first_output = read_rgb(next(iter(output_paths_by_chain.values()))[0])
    output_size = first_output.shape[:2]
    scored_by_chain = {chain: [] for chain in output_paths_by_chain}
    for index in range(1, len(source_paths) - 1):
        context = build_source_context(source_paths, index, output_size)
        if context is None:
            continue
        for chain, output_paths in output_paths_by_chain.items():
            scored_by_chain[chain].append(score_candidate(output_paths, index, context))
    selected_by_chain = {
        chain: select_events(scored, top_events) for chain, scored in scored_by_chain.items()
    }
    selected_by_frame: dict[int, list[tuple[str, int, dict]]] = {}
    for chain, selected in selected_by_chain.items():
        for rank, item in enumerate(selected, start=1):
            selected_by_frame.setdefault(item["frameIndex"], []).append((chain, rank, item))
    records_by_chain = {chain: [] for chain in output_paths_by_chain}
    for index, selections in selected_by_frame.items():
        context = build_source_context(source_paths, index, output_size)
        if context is None:
            continue
        for chain, rank, original in selections:
            item = score_candidate(output_paths_by_chain[chain], index, context, include_assets=True)
            event_id = f"event-{rank:02d}-frame-{index:06d}"
            rectangle = original["rectangle"]
            event_dir = event_roots[chain] / event_id
            assets = {
                "sourceTemporal": item["sourceTemporal"],
                "candidateTemporal": item["outputTemporal"],
                "candidatePreviousAligned": item["outputPrevious"],
                "candidateCurrent": item["outputCurrent"],
                "candidateFollowingAligned": item["outputFollowing"],
                "excessTemporalOverlay": item["overlay"],
            }
            paths = {}
            for name, image in assets.items():
                asset_path = event_dir / f"{name}.png"
                write_rgb(asset_path, crop(image, rectangle))
                paths[name] = str(asset_path)
            records_by_chain[chain].append({
                "eventId": event_id,
                "frameIndex": index,
                "scoreMean": original["scoreMean"],
                "scoreP99": original["scoreP99"],
                "scoreMax": original["scoreMax"],
                "reliableFraction": original["reliableFraction"],
                "crop": dict(zip(("x", "y", "width", "height"), rectangle)),
                "assets": paths,
            })
    for records in records_by_chain.values():
        records.sort(key=lambda item: item["eventId"])
    return records_by_chain


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--outputs", required=True, type=Path)
    parser.add_argument("--report", required=True, type=Path)
    parser.add_argument("--chains", required=True)
    parser.add_argument("--clips", default="")
    parser.add_argument("--top-events", type=int, default=8)
    args = parser.parse_args()
    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    chains = [value for value in args.chains.split(",") if value]
    selected_clips = {value for value in args.clips.split(",") if value}
    grouped: dict[str, list[dict]] = {}
    for item in manifest["inputs"]:
        grouped.setdefault(item["sourceClass"], []).append(item)
    report = {"schemaVersion": 1, "method": "source-guided-flow-temporal-rgb-v1", "clips": {}}
    for clip_id, items in grouped.items():
        if selected_clips and clip_id not in selected_clips:
            continue
        items.sort(key=lambda item: item["frameIndex"])
        source_paths = [(args.manifest.parent / item["path"]).resolve() for item in items]
        report["clips"][clip_id] = {}
        output_paths_by_chain = {}
        event_roots = {}
        for chain in chains:
            output_paths_by_chain[chain] = [
                args.outputs / "outputs" / clip_id / item["id"] / f"{chain}.png"
                for item in items
            ]
            missing = [str(path) for path in output_paths_by_chain[chain] if not path.exists()]
            if missing:
                raise FileNotFoundError(f"{chain}/{clip_id} is missing {len(missing)} outputs; first: {missing[0]}")
            event_roots[chain] = args.report / clip_id / chain
        report["clips"][clip_id] = analyze_clip_chains(
            source_paths, output_paths_by_chain, event_roots, args.top_events
        )
    args.report.mkdir(parents=True, exist_ok=True)
    (args.report / "motion-events.json").write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"Motion event report: {args.report / 'motion-events.json'}")


if __name__ == "__main__":
    main()
