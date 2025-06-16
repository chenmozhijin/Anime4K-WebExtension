# Anime4K WebExtension

[中文](./README.md) | English | [日本語](./README.ja.md)

A real-time video super-resolution browser extension based on Anime4K-WebGPU, supporting multiple enhancement modes and resolution settings.

## Features

- 🚀 Real-time video super-resolution processing
- ⚙️ 6 super-resolution algorithm modes (A/B/C/A+A/B+B/C+A) [Detailed Explanation](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md)
- 📏 Multiple resolution options (2x/4x/8x/720p/1080p/4K)
- ⚡ WebGPU acceleration, high efficiency and low latency
- 📋 Page whitelist system (disabled by default)
- 🌐 Multi-language support (Chinese/English/Japanese)

> [!WARNING]
> This extension does not work on video websites with Encrypted Media Extensions (EME) or DRM protection, such as Netflix.

## User Guide

### Install the Extension

#### From App Store (Recommended)

- **Edge Add-ons Store**: [https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- Chrome Web Store: Under review (temporarily unavailable)

> [!NOTE]
> Due to the review process, the version in the store may not be the latest. For the latest version, please use the pre-built package or build from source.

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

### Basic Usage

1. After installing the extension, visit websites with video elements (e.g., Bilibili, Ani-One)
2. When playing a video, a purple "✨ Enhance" button will appear at the middle-left of the video element
3. Click the button to enable super-resolution processing
4. Click the button again to disable processing

### Advanced Settings

Click the toolbar icon to open the control panel:

- **Enhancement Mode**: Select different modes ([Detailed Explanation](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md))
- **Resolution**: Set output resolution
- **Whitelist**: Manage websites where the extension is enabled

### Whitelist Management

1. Enable whitelist function in the popup panel
2. Add rule types:
   - Current page: `www.example.com/video/123`
   - Current domain: `*.example.com/*`
   - Parent path: `www.example.com/video/*`
3. Manage all rules in the options page

## Acknowledgments

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
