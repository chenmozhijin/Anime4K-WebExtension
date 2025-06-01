# Anime4K WebExtension

基于Anime4K-WebGPU的实时视频超分辨率浏览器扩展，支持多种增强模式和分辨率设置。

## 功能特性

- 🚀 实时视频超分辨率处理
- ⚙️ 6种超分辨率算法模式（A/B/C/A+A/B+B/C+A[详细说明](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md)）
- 📏 多种分辨率选项（2x/4x/8x/720p/1080p/4K）
- ⚡ WebGPU加速，高效低延迟
- 📋 页面白名单系统（默认关闭）
- 🌐 多语言支持（中/英）

## 使用指南

### 基础使用

1. 安装后访问包含视频元素的网站（如Bilibili、動畫瘋）
2. 播放视频时，视频元素左中部会出现紫色"超分"按钮
3. 点击按钮启用超分辨率处理
4. 再次点击按钮关闭处理

### 高级设置

点击工具栏图标打开控制面板：

- **增强模式**：选择算法（质量/速度平衡）
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
