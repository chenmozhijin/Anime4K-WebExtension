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

#### From Source Code

1. Clone this repository
2. Run `npm install` to install dependencies
3. Run `npm run build` to build the project
4. Load the built extension in your browser:
   - Chrome: Open extensions page (`chrome://extensions`) → Enable "Developer mode" → "Load unpacked" → Select the `dist` directory in the project
   - Edge: Open extensions page (`edge://extensions`) → Enable "Developer mode" → "Load unpacked" → Select the `dist` directory in the project

#### Using Pre-built Packages

1. Go to [GitHub Actions](https://github.com/chenmozhijin/Anime4K-WebExtension/actions), click on the latest "Build and Package" workflow run
2. Download the latest built `anime4k-webextension` from Artifacts
3. Unzip the downloaded file
4. Load the unzipped directory in your browser (same steps as above)

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
