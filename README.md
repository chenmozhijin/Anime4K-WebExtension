# Anime4K WebExtension

中文 | [English](./README.en.md) | [日本語](./README.ja.md) | [Русский](./README.ru.md)

利用Anime4K实时超分辨率算法显著提升动漫视频画质，逐帧呈现更清晰锐利的视觉体验！

## 功能特性

- 🚀 实时超分：在浏览器视频播放中利用WebGPU技术提供即时超分效果。
- ⚙️ 灵活的增强模式：提供多种预设模式并添加支持自定义模式，自由组合不同增强效果，适应不同视频和设备
- 📏 灵活缩放：提供 2倍/4倍/8倍输出，或固定输出 720p/1080p/2K/4K 分辨率
- ⚡ 一键增强：视频播放器自动浮现紫色「✨ 超分」按钮，点击即可启用 超分效果。
- 📋 精准白名单：只对您指定的网站或页面生效，避免干扰，节省资源。
- 🌐 多语言界面：支持中文、英文、日语、俄语等。

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
