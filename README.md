# NijiLucid

中文 | [English](./README.en.md) | [日本語](./README.ja.md) | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=edge%E7%94%A8%E6%88%B7)](https://microsoftedge.microsoft.com/addons/detail/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=chrome%E7%94%A8%E6%88%B7)](https://chromewebstore.google.com/detail/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![Mozilla Add-on Users](https://img.shields.io/amo/users/nijilucid?style=flat-square&label=Firefox%E7%94%A8%E6%88%B7)](https://addons.mozilla.org/firefox/addon/nijilucid/) [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/NijiLucid/total?style=flat-square&label=GitHub%E4%B8%8B%E8%BD%BD)](https://github.com/chenmozhijin/NijiLucid/releases/latest)

NijiLucid 利用 WebGPU 实时提升动漫视频画质，逐帧呈现更清晰锐利的视觉体验！

## 功能特性

- 🚀 WebGPU 实时超分: 依托先进的 WebGPU 技术，在浏览器端实现低延迟、高性能的视频实时超分辨率增强。
- ⚡ 多档性能档位: 提供 快速/均衡/质量/极致 四种性能档位，并支持自定义模式，灵活平衡画质提升与硬件负载。
- 🧪 高级自定义效果: 支持自由组合多种增强效果，打造更符合个人偏好的画面风格；推荐预设会随性能档位自动调整效果配置。
- 📊 硬件性能评估: 内置 GPU 基准测试，为您推荐适合硬件性能的超分档位。
- 📏 灵活分辨率控制: 支持 2x/4x/8x 倍率放大，亦可锁定 2K/4K 等目标分辨率，满足多样化观影需求。
- ✨ 一键增强: 视频播放器自动浮现紫色「✨ 超分」按钮，一键开启画质飞跃。
- 🛡️ 广泛兼容: 适配普通 DOM、开放 Shadow DOM、iframe 等常见网页结构；遇到跨域视频加载问题时，可开启跨域兼容模式尝试修复。
- 📋 按需启用机制: 支持精准白名单策略，仅在指定站点生效，避免资源浪费与页面干扰。
- 🌈 现代化 UI 设计: 遵循 Material Design 规范，自适应 浅色/深色/跟随系统 主题，视觉体验舒适流畅。
- 🌐 国际化支持: 支持中、英、日、俄等多国语言，服务全球用户。

> [!WARNING]
> 此拓展无法作用于有Encrypted Media Extensions (EME) 或 DRM 保护的视频网站，如Netflix。

## 使用指南

### 安装扩展

#### 从应用商店安装（推荐）

- [![GitHub Release](https://img.shields.io/github/v/release/chenmozhijin/NijiLucid?style=flat-square&label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC)](https://github.com/chenmozhijin/NijiLucid/releases/latest)
- [![Edge Store Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.version&style=flat-square&label=Edge%E6%89%A9%E5%B1%95%E5%95%86%E5%BA%97)](https://microsoftedge.microsoft.com/addons/detail/ffopffngebibpmeodlhhkdlaejnmdlam)
- [![Chrome Web Store Version](https://img.shields.io/chrome-web-store/v/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E5%BA%94%E7%94%A8%E5%95%86%E5%BA%97)](https://chromewebstore.google.com/detail/hpmbccepehpoanjpjkamfdpdkbmfmhek)
- [![Mozilla Add-on Version](https://img.shields.io/amo/v/nijilucid?style=flat-square&label=Firefox%E9%99%84%E5%8A%A0%E7%BB%84%E4%BB%B6)](https://addons.mozilla.org/firefox/addon/nijilucid/)

> [!NOTE]
>
> 1. 点击上面的徽章跳转到商店页面
> 2. 由于审核流程，商店中的版本可能不是最新版。如需最新版，请使用预构建包或从源码构建。

#### 使用预构建包

1. 前往[GitHub Releases](https://github.com/chenmozhijin/NijiLucid/releases/latest)页面
2. 在"Assets"部分下载最新构建的扩展包：
   - Chrome/Edge: `nijilucid.zip`
   - Firefox: `nijilucid-firefox.zip`
3. 解压 ZIP 文件
4. 在浏览器中加载解压后的扩展：
   - Chrome: 打开拓展页面(`chrome://extensions`) → 启用"开发者模式" → "加载已解压的扩展程序" → 选择解压后的目录
   - Edge: 打开拓展页面(`edge://extensions`) → 启用"开发人员模式" → "加载解压缩的扩展" → 选择解压后的目录
   - Firefox: 打开 `about:debugging#/runtime/this-firefox` → 临时载入附加组件 → 选择解压目录中的 `manifest.json`

#### 从源码安装

1. 克隆本仓库
2. 运行 `npm install` 安装依赖
3. 根据所用浏览器构建项目：
   - Chrome/Edge: 运行 `npm run build:chrome`
   - Firefox: 运行 `npm run build:firefox`
4. 在浏览器中加载构建好的扩展：
   - Chrome/Edge: 打开拓展页面(`chrome://extensions` 或 `edge://extensions`) → 启用开发者模式 → 加载已解压的扩展 → 选择项目中的 `dist-chrome` 目录
   - Firefox: 打开 `about:debugging#/runtime/this-firefox` → 临时载入附加组件 → 选择项目中 `dist-firefox/manifest.json`

### 一、初次设置 (Onboarding)

安装扩展后，会自动打开引导页面。为了获得最佳体验，请跟随指引完成设置：

1.  **GPU 性能基准测试**：扩展会运行一段简短的基准测试 (目标: 1080p -> 4K 24fps)，评估您的显卡性能。
2.  **推荐档位**：根据测试结果，扩展会自动为您推荐合适的性能档位 (Performance Tier)：
    *   🚀 **快速**: 适合集成显卡或老旧设备，优先保证流畅度。
    *   ⚖️ **均衡**: 平衡画质与性能，适合大多数中端设备。
    *   🎨 **质量**: 提供更好的画面细节，适合独立显卡用户。
    *   🔬 **极致**: 最高画质，需要较强的显卡性能支持。
3.  **确认应用**：您可以接受推荐，也可以手动选择其他档位。

### 二、日常使用

1.  **启用增强**：在支持的视频网站（如 Bilibili, YouTube 等）播放视频。
2.  **点击开关**：将鼠标悬停在视频播放器左侧中部，会浮现一个紫色的 **「✨ 超分」** 按钮；点击即可开启或关闭超分。
    *   启动时按钮会显示“⏳ 启动中...”，开启后显示“❌ 取消”；再次点击即可关闭超分。
    *   鼠标离开播放器左侧中部或按钮后，按钮会自动隐藏，以免遮挡画面。

### 三、快捷设置面板

点击浏览器工具栏中的 NijiLucid 扩展图标，打开弹出面板：

*   **性能档位 (Performance Tier)**: 快速切换四个性能档位。
    *   *注意：当选择了“自定义模式”时，性能档位将不可用，因为自定义模式由具体的效果组合决定。*
*   **增强模式 (Enhancement Mode)**:
    *   **内置模式**: 包含三种推荐预设和六种兼容模式。
    *   **推荐预设**: 细节保留、重压缩清理、柔和风格，会随性能档位调整效果配置。
    *   **兼容模式**: Mode A、Mode B、Mode C、Mode A+A、Mode B+B、Mode C+A。
    *   **自定义模式**: 您自己创建或导入的模式，可自由组合效果。
*   **分辨率 (Resolution)**: 支持 x2、x4、x8 倍率放大，以及 720p、1080p、2K (1440p)、4K (2160p) 固定目标分辨率。固定目标分辨率会保持原视频比例；Native 使用原始分辨率输出，不进行放大，但不等同于关闭增强。
*   **白名单 (Whitelist)**:
    *   快速将当前页面、域名或父路径加入白名单。
    *   启用/禁用全局白名单功能。

### 四、高级选项

点击面板底部的 **“设置”** 按钮进入详细设置页面：

#### 1. 常规设置 (General)
*   **外观**: 切换 浅色/深色 主题。
*   **兼容性**: 当视频因浏览器安全策略无法增强时（常见于嵌套的第三方播放器），可开启 **"跨域兼容模式"** (Cross-Origin Mode)。此模式会尝试修复跨域加载问题；启用后请刷新已打开的页面。

#### 2. 性能设置 (Performance)
*   **GPU 测试**: 随时重新运行基准测试，更新您的性能评分。
*   **当前档位**: 查看当前生效的性能配置。
*   **性能监视器**: 提供关闭、轻量和 GPU 诊断三种模式。轻量显示整体帧性能；GPU 诊断在浏览器支持 GPU 时间戳查询时显示各效果的 GPU 耗时。HUD 支持折叠、复制性能快照、切换位置、调整宽度和关闭。

#### 3. 增强模式 (Enhancement Modes)
*   **可视化编辑器**: 创建全新的自定义模式。
*   **高级效果**: 自定义模式可手动添加 ArtCNN、ACNet、ARNet、CuNNy 等效果；推荐预设也会随性能档位使用相应的效果配置。
*   **拖拽排序**: 调整效果的应用顺序，或调整模式列表顺序。
*   **分享配置**: 导入/导出您的自定义模式配置 (JSON 格式)。

#### 4. 白名单管理 (Whitelist)
*   **规则管理**: 查看、编辑或删除已添加的网址规则。
*   **支持通配符**: 使用 `*` 匹配多个页面（如 `*.bilibili.com/*`）。
*   **匹配范围**: 白名单规则只匹配 `hostname + pathname`，不会匹配协议、端口、查询参数或 hash。例如 `example.com/watch/*` 可匹配 `https://example.com:8443/watch/1?from=home`。

## 致谢

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)（历史实现参考）
- [ArtCNN](https://github.com/Artoriuz/ArtCNN)
- [ACNetGLSL](https://github.com/TianZerL/ACNetGLSL)
- [CuNNy](https://github.com/funnyplanter/CuNNy)

## 许可证

主项目核心代码使用 MIT 许可证。随默认扩展包提供的 CuNNy 生成组件使用
LGPL-3.0-or-later；对应源码说明详见
[THIRD_PARTY_NOTICES.md](./THIRD_PARTY_NOTICES.md)。
