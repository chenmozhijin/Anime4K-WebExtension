# Anime4K WebExtension

[中文](./README.md) | English | [日本語](./README.ja.md) | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=Edge%20Users)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%20Users)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![Mozilla Add-on Users](https://img.shields.io/amo/users/anime4k-webextension?style=flat-square&label=Firefox%20Users)](https://addons.mozilla.org/firefox/addon/anime4k-webextension/) [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/Anime4K-WebExtension/total?style=flat-square&label=GitHub%20Downloads)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)

Significantly improve the image quality of anime videos with the Anime4K real-time super-resolution algorithm, delivering a clearer and sharper visual experience frame by frame!

## Features

- 🚀 **Real-time Super-Resolution:** Leverage advanced WebGPU technology to achieve low-latency, high-performance real-time video super-resolution enhancement directly in the browser.
- ⚡ **Multiple Performance Tiers:** Offers four preset modes: Fast/Balanced/Quality/Ultra, and supports Custom Modes to flexibly balance image quality improvement and hardware load.
- 📊 **Hardware Performance Evaluation:** Built-in GPU benchmark test to recommend the best super-resolution tier for your hardware.
- 📏 **Flexible Resolution Control:** Supports 2x/4x/8x upscaling factors, or can lock to target resolutions like 2K/4K to meet diverse viewing needs.
- ✨ **One-Click Enhance:** A purple "✨ Enhance" button automatically appears on the video player for one-click image quality boost.
- 🛡️ **Broad Compatibility:** Adapts to Shadow DOM, iframes, and cross-origin video sources, breaking through technical limitations to cover the vast majority of video websites.
- 📋 **On-Demand Activation Mechanism:** Supports precise Whitelist strategy, effective only on specified sites to avoid resource waste and page interference.
- 🌈 **Modern UI Design:** Follows Material Design guidelines, adapting to Light/Dark/System themes for a comfortable and smooth visual experience.
- 🌐 **Internationalization Support:** Supports multiple languages including Chinese, English, Japanese, and Russian to serve global users.

> [!WARNING]
> This extension does not work on video websites with Encrypted Media Extensions (EME) or DRM protection, such as Netflix.

## User Guide

### Install the Extension

#### From App Store (Recommended)

- [![GitHub Release](https://img.shields.io/github/v/release/chenmozhijin/Anime4K-WebExtension?style=flat-square&label=Latest%20Version)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)
- [![Edge Store Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.version&style=flat-square&label=Edge%20Add-ons)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- [![Chrome Web Store Version](https://img.shields.io/chrome-web-store/v/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%20Web%20Store)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek)
- [![Mozilla Add-on Version](https://img.shields.io/amo/v/anime4k-webextension?style=flat-square&label=Firefox%20Add-on)](https://addons.mozilla.org/firefox/addon/anime4k-webextension/)

> [!NOTE]
>
> 1. Click the badges above to go to the store page.
> 2. Due to the review process, the version in the store may not be the latest. For the latest version, please use the pre-built package or build from source.

#### Using Pre-built Packages

1. Go to [GitHub Releases](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)
2. Under "Assets", download the latest `anime4k-webextension.zip`
3. Unzip the downloaded file
4. Load the unzipped directory in your browser:
   - Chrome: Open extensions page (`chrome://extensions`) → Enable "Developer mode" → "Load unpacked" → Select the unzipped directory
   - Edge: Open extensions page (`edge://extensions`) → Enable "Developer mode" → "Load unpacked" → Select the unzipped directory

#### From Source Code

1. Clone this repository
2. Run `npm install` to install dependencies
3. Run `npm run build` to build the project
4. Load the built extension in your browser:
   - Chrome: Open extensions page (`chrome://extensions`) → Enable "Developer mode" → "Load unpacked" → Select the `dist` directory in the project
   - Edge: Open extensions page (`edge://extensions`) → Enable "Developer mode" → "Load unpacked" → Select the `dist` directory in the project

### I. First Run (Onboarding)

After installing the extension, an onboarding page will automatically open. For the best experience, please follow the guide to complete the setup:

1.  **GPU Benchmark**: The extension will run a short benchmark (Target: 1080p -> 4K 24fps) to evaluate your graphics card performance.
2.  **Recommended Tier**: Based on the results, the extension will automatically recommend a suitable Performance Tier:
    *   🚀 **Performance**: Best for integrated graphics or older devices, prioritizing smoothness.
    *   ⚖️ **Balanced**: Balances quality and performance, suitable for most mid-range devices.
    *   🎨 **Quality**: Provides better image detail, suitable for discrete graphics cards.
    *   🔬 **Ultra**: Maximum quality, requires strong graphics card performance.
3.  **Apply**: You can accept the recommendation or manually select another tier.

### II. Daily Use

1.  **Enable Enhancement**: Play a video on a supported website (e.g., Bilibili, YouTube). A purple **"✨ Enhance"** button will appear on the left side of the video player when you hover over it.
2.  **Click to Toggle**: Click the button to enable real-time super-resolution. The button state will change from "⏳ Starting..." to "❌ Cancel".
3.  **Auto-hide**: The button will automatically hide when the mouse is moved away to maintain a clean viewing experience.

### III. Popup Panel Settings

Click the Anime4K extension icon in the browser toolbar to open the quick settings panel:

*   **Performance Tier**: Quickly switch between four presets.
    *   *Note: When a "Custom Mode" is selected, the Performance Tier is unavailable because custom modes are defined by their specific shader combinations.*
*   **Enhancement Mode**:
    *   **Built-in Modes**: Classic Anime4K presets like Mode A, Mode B, Mode C.
    *   **Custom Modes**: Advanced modes created or imported by you.
*   **Resolution**: Set the target output resolution (x2 scaling or fixed 1080p/4K, etc.).
*   **Whitelist**:
    *   Quickly add the current page, domain, or parent path to the whitelist.
    *   Enable/disable the global whitelist feature.

### IV. Advanced Options

Click the **"Settings"** button at the bottom of the panel to access the detailed settings page:

#### 1. General Settings
*   **Appearance**: Switch between Light/Dark themes.
*   **Compatibility**: Enable **"Cross-Origin Compatibility Mode"** to fix videos that fail to enhance due to browser security policies (common with nested third-party players).

#### 2. Performance Settings
*   **GPU Benchmark**: Re-run the benchmark at any time to update your performance score.
*   **Current Tier**: View the currently active performance configuration.

#### 3. Enhancement Modes
*   **Visual Editor**: Create brand new custom modes.
*   **Drag & Drop Sorting**: Adjust the order of applied shaders or the mode list itself.
*   **Share Config**: Import/Export your custom mode configurations (JSON format).

#### 4. Whitelist Management
*   **Rule Management**: View, edit, or delete added URL rules.
*   **Wildcard Support**: Use `*` to match multiple pages (e.g., `*.bilibili.com/*`).

## Acknowledgments

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
