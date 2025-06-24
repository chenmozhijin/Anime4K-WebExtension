# Anime4K WebExtension

中文 | [English](./README.en.md) | [日本語](./README.ja.md) | [Русский](./README.ru.md)

基于Anime4K-WebGPU的实时视频超分辨率浏览器扩展，支持多种增强模式和分辨率设置。

## 功能特性

- 🚀 实时视频超分辨率处理
- ⚙️ 6种超分辨率算法模式（A/B/C/A+A/B+B/C+A[详细说明](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md)）
- 📏 多种分辨率选项（2x/4x/8x/720p/1080p/4K）
- ⚡ WebGPU加速，高效低延迟
- 📋 页面白名单系统（默认关闭）
- 🌐 多语言支持（中/英/日/俄）

> [!WARNING]
> 此拓展无法作用于有Encrypted Media Extensions (EME) 或 DRM 保护的视频网站，如Netflix。

## 使用指南

### 安装扩展

#### 从应用商店安装（推荐）

- [Edge扩展商店](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- [Chrome应用商店](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek)

> [!NOTE]
> 由于审核流程，商店中的版本可能不是最新版。如需最新版，请使用预构建包或从源码构建。

#### 使用预构建包（推荐）

1. 前往[GitHub Releases](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)页面
2. 在"Assets"部分下载最新构建的 `anime4k-webextension.zip`
3. 解压zip文件
4. 在浏览器中加载解压后的目录：
   - Chrome: 打开拓展页面(`chrome://extensions`) → 启用"开发者模式" → "加载已解压的扩展程序" → 选择解压后的目录
   - Edge: 打开拓展页面(`edge://extensions`) → 启用"开发人员模式" → "加载解压缩的扩展" → 选择解压后的目录

#### 从源码安装

1. 克隆本仓库
2. 运行 `npm install` 安装依赖
3. 运行 `npm run build` 构建项目
4. 在浏览器中加载构建好的扩展：
   - Chrome: 打开拓展页面(`chrome://extensions`) → 启用"开发者模式" → "加载已解压的扩展程序" → 选择项目中的 `dist` 目录
   - Edge: 打开拓展页面(`edge://extensions`) → 启用"开发人员模式" → "加载解压缩的扩展" → 选择项目中的 `dist` 目录

### 基础使用

1. 安装扩展后访问包含视频元素的网站（如Bilibili、動畫瘋、youtube等）
2. 播放视频时，视频元素左中部会出现紫色"✨ 超分"按钮
3. 点击按钮启用超分辨率处理
4. 再次点击按钮关闭处理

### 高级设置

点击工具栏图标打开控制面板：

- **增强模式**：选择不同模式（[详细说明](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md)）
- **分辨率**：设置输出分辨率
- **白名单**：管理启用扩展的网站

### 白名单管理

1. 在弹出面板启用白名单功能
2. 添加规则类型：
   - 当前页面：`www.example.com/video/123`
   - 当前域名：`*.example.com/*`
   - 父路径：`www.example.com/video/*`
3. 在选项页管理所有规则

## 致谢

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
