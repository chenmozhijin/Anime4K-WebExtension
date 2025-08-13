# Anime4K WebExtension

中文 | [English](./README.en.md) | [日本語](./README.ja.md) | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=edge%E7%94%A8%E6%88%B7)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=chrome%E7%94%A8%E6%88%B7)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/Anime4K-WebExtension/total?style=flat-square&label=GitHub%E4%B8%8B%E8%BD%BD)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)

利用Anime4K实时超分辨率算法显著提升动漫视频画质，逐帧呈现更清晰锐利的视觉体验！

## 功能特性

- 🚀 实时超分：在浏览器视频播放中利用WebGPU技术提供即时超分效果。
- ⚙️ 灵活的增强模式：提供多种预设模式并添加支持自定义模式，自由组合不同增强效果，适应不同视频和设备
- 📏 灵活缩放：提供 2倍/4倍/8倍输出，或固定输出 720p/1080p/2K/4K 分辨率
- ⚡ 一键增强：视频播放器自动浮现紫色「✨ 超分」按钮，点击即可启用 超分效果。
- 🛡️ 广泛兼容：支持 Shadow DOM、iframe 及跨域视频，尽可能支持更多网站。
- 📋 精准白名单：只对您指定的网站或页面生效，避免干扰，节省资源。
- 🌐 多语言界面：支持中文、英文、日语、俄语等。

> [!WARNING]
> 此拓展无法作用于有Encrypted Media Extensions (EME) 或 DRM 保护的视频网站，如Netflix。

## 使用指南

### 安装扩展

#### 从应用商店安装（推荐）

- [![GitHub Release](https://img.shields.io/github/v/release/chenmozhijin/Anime4K-WebExtension?style=flat-square&label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)
- [![Edge Store Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.version&style=flat-square&label=Edge%E6%89%A9%E5%B1%95%E5%95%86%E5%BA%97)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- [![Chrome Web Store Version](https://img.shields.io/chrome-web-store/v/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E5%BA%94%E7%94%A8%E5%95%86%E5%BA%97)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek)

> [!NOTE]
>
> 1. 点击上面的徽章跳转到商店页面
> 2. 由于审核流程，商店中的版本可能不是最新版。如需最新版，请使用预构建包或从源码构建。

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

### 一、快速上手

1. **启用增强**：安装扩展后，在支持的视频网站（如 Bilibili, YouTube 等）播放视频。将鼠标悬停在视频播放器上，左侧会浮现一个紫色的 **「✨ 超分」** 按钮。
2. **点击切换**：点击该按钮即可启用实时超分。处理过程中按钮会显示“增强中...”，完成后变为“取消增强”。再次点击按钮则会关闭增强效果。
3. **自动隐藏**：按钮在鼠标移开后会自动隐藏，以保持观看体验的清爽。

### 二、弹出面板设置

点击浏览器工具栏中的 Anime4K 扩展图标，可以打开快捷设置面板。

- **增强模式**：快速切换不同的预设或自定义增强模式。
- **输出分辨率**：选择视频增强后的输出分辨率。
  - **倍率缩放**：`x2`, `x4`, `x8` 会将原视频分辨率乘以相应倍数。
  - **固定分辨率**：`720p`, `1080p`, `2K`, `4K` 会将视频输出到固定的分辨率。
- **白名单开关**：全局启用或禁用白名单功能。如果关闭，扩展将在所有网站上尝试运行。
- **快速添加白名单**：
  - **添加当前页面**：仅将当前页面的精确网址加入白名单。(不包含请求参数)
  - **添加当前域名**：将当前网站的所有页面都加入白名单 (例如 `www.youtube.com/*`)。
  - **添加父路径**：将当前页面的上级目录加入白名单 (例如，从 `site.com/videos/123` 添加 `site.com/videos/*`)。
- **进入高级配置**：点击“打开高级设置”按钮，进入功能更全面的选项页面。

### 三、进阶设置

在选项页面，您可以对扩展进行深度自定义。

#### 1. 增强模式管理

在这里，您可以完全控制增强效果的组合：

- **创建新模式**：点击“添加模式”按钮创建一个新的空白模式。
- **自定义模式**：
  - **重命名**：直接点击模式名称进行修改。
  - **调整效果**：点击模式卡片左侧的箭头展开详情。在展开的视图中，可以通过拖放来**重新排序**增强效果，或点击 `×` **移除**效果。
  - **添加效果**：在展开的视图中，从下拉菜单选择并添加新的增强效果到处理链中。
- **管理模式**：通过拖动模式卡片对所有自定义模式进行**排序**，或点击“删除”按钮**删除**不需要的自定义模式。（内置模式无法删除或修改效果组合）。
- **导入/导出**：以JSON文件的形式轻松分享或备份您的自定义模式配置。

#### 2. 白名单管理

实现对扩展生效范围的精细化控制：

- **规则列表**：集中管理所有白名单规则。您可以手动**编辑**规则、通过复选框**启用/禁用**特定规则，或**删除**规则。
- **添加规则**：手动添加新的URL匹配规则。规则支持通配符 `*`，例如 `*.bilibili.com/*` 可以匹配B站的所有页面。
- **导入/导出**：以JSON文件的形式备份或从他人分享中导入您的白名单规则。

#### 3. 常规设置

- **跨域兼容模式**：当遇到因“跨域”限制而导致增强失败的视频时（常见于使用第三方视频源的网站），此模式会尝试自动修复问题。如果增强时出现安全错误提示，请务必开启此功能。

## 致谢

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
