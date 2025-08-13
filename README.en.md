# Anime4K WebExtension

[中文](./README.md) | English | [日本語](./README.ja.md) | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=Edge%20Users)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%20Users)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/Anime4K-WebExtension/total?style=flat-square&label=GitHub%20Downloads)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)

Significantly improve the image quality of anime videos with the Anime4K real-time super-resolution algorithm, delivering a clearer and sharper visual experience frame by frame!

## Features

- 🚀 **Real-time Super-Resolution:** Provides instant super-resolution effects during video playback in the browser using WebGPU technology.
- ⚙️ **Flexible Enhancement Modes:** Offers multiple preset modes and supports custom modes, allowing free combination of different enhancement effects to suit various videos and devices.
- 📏 **Flexible Scaling:** Provides 2x/4x/8x output, or fixed output resolutions of 720p/1080p/2K/4K.
- ⚡ **One-Click Enhancement:** A purple "✨ Enhance" button automatically appears on the video player; click to enable the effect.
- 🛡️ **Broad Compatibility:** Supports Shadow DOM, iframes, and cross-origin videos, aiming to be compatible with as many websites as possible.
- 📋 **Precise Whitelist:** Works only on specified websites or pages to avoid interference and save resources.
- 🌐 **Multi-language Interface:** Supports Chinese, English, Japanese, Russian, etc.

> [!WARNING]
> This extension does not work on video websites with Encrypted Media Extensions (EME) or DRM protection, such as Netflix.

## User Guide

### Install the Extension

#### From App Store (Recommended)

- [![GitHub Release](https://img.shields.io/github/v/release/chenmozhijin/Anime4K-WebExtension?style=flat-square&label=Latest%20Version)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)
- [![Edge Store Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.version&style=flat-square&label=Edge%20Add-ons)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- [![Chrome Web Store Version](https://img.shields.io/chrome-web-store/v/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%20Web%20Store)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek)

> [!NOTE]
>
> 1. Click the badges above to go to the store page.
> 2. Due to the review process, the version in the store may not be the latest. For the latest version, please use the pre-built package or build from source.

#### Using Pre-built Packages (Recommended)

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

### I. Quick Start

1. **Enable Enhancement**: After installing the extension, play a video on a supported website (e.g., Bilibili, YouTube). A purple **"✨ Enhance"** button will appear on the left side of the video player when you hover over it.
2. **Click to Toggle**: Click the button to enable real-time super-resolution. The button will show "Enhancing..." during processing and change to "Disable Enhancement" when complete. Clicking it again will turn off the enhancement.
3. **Auto-hide**: The button will automatically hide when the mouse is moved away to maintain a clean viewing experience.

### II. Popup Panel Settings

Click the Anime4K extension icon in the browser toolbar to open the quick settings panel.

- **Enhancement Mode**: Quickly switch between different preset or custom enhancement modes.
- **Output Resolution**: Select the output resolution for the enhanced video.
- **Scaling Factor**: `x2`, `x4`, `x8` will multiply the original video resolution by the corresponding factor.
- **Fixed Resolution**: `720p`, `1080p`, `2K`, `4K` will output the video to a fixed resolution.
- **Whitelist Switch**: Globally enable or disable the whitelist feature. If turned off, the extension will attempt to run on all websites.
- **Quick Add to Whitelist**:
- **Add Current Page**: Adds only the exact URL of the current page to the whitelist (excluding query parameters).
- **Add Current Domain**: Adds all pages of the current website to the whitelist (e.g., `www.youtube.com/*`).
- **Add Parent Path**: Adds the parent directory of the current page to the whitelist (e.g., adds `site.com/videos/*` from `site.com/videos/123`).
- **Go to Advanced Settings**: Click the "Open Advanced Settings" button to access the more comprehensive options page.

### III. Advanced Settings

On the options page, you can deeply customize the extension.

#### 1. Enhancement Mode Management

Here, you have full control over the combination of enhancement effects:

- **Create New Mode**: Click the "Add Mode" button to create a new blank mode.
- **Customize Mode**:
- **Rename**: Click the mode name directly to edit it.
- **Adjust Effects**: Click the arrow on the left of the mode card to expand details. In the expanded view, you can **reorder** enhancement effects by dragging and dropping, or **remove** an effect by clicking `×`.
- **Add Effect**: In the expanded view, select and add new enhancement effects to the processing chain from the dropdown menu.
- **Manage Modes**: **Sort** all custom modes by dragging their cards, or **delete** unwanted custom modes by clicking the "Delete" button. (Built-in modes cannot be deleted or have their effect combinations modified).
- **Import/Export**: Easily share or back up your custom mode configurations as a JSON file.

#### 2. Whitelist Management

Achieve fine-grained control over the extension's scope:

- **Rule List**: Centrally manage all whitelist rules. You can manually **edit** rules, **enable/disable** specific rules via checkboxes, or **delete** rules.
- **Add Rule**: Manually add new URL matching rules. Rules support the wildcard `*`, for example, `*.bilibili.com/*` can match all pages on Bilibili.
- **Import/Export**: Back up your whitelist rules or import them from others' shares as a JSON file.

#### 3. General Settings

- **Cross-Origin Compatibility Mode**: When encountering videos that fail to enhance due to "cross-origin" restrictions (common on websites using third-party video sources), this mode will attempt to automatically fix the issue. If a security error appears during enhancement, be sure to enable this feature.

## Acknowledgments

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
