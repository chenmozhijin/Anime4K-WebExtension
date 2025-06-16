# Anime4K WebExtension

[中文](./README.md) | [English](./README.en.md) | 日本語

Anime4K-WebGPUに基づくリアルタイム動画超解像ブラウザ拡張機能。複数の拡張モードと解像度設定をサポート。

## 機能特徴

- 🚀 リアルタイム動画超解像処理
- ⚙️ 6種類の超解像アルゴリズムモード（A/B/C/A+A/B+B/C+A）[詳細説明](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md)
- 📏 複数の解像度オプション（2x/4x/8x/720p/1080p/4K）
- ⚡ WebGPU加速、高効率・低遅延
- 📋 ページホワイトリストシステム（デフォルト無効）
- 🌐 多言語対応（中国語/英語/日本語）

> [!WARNING]
> この拡張機能は、Encrypted Media Extensions (EME) または DRM で保護された動画サイト（Netflixなど）では動作しません。

## 使用ガイド

### 拡張機能のインストール

#### アプリストアからインストール（推奨）

- **Edgeアドオンストア**: [https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- Chromeウェブストア：審査中（一時的に利用不可）

> [!NOTE]
> 審査プロセスのため、ストアのバージョンは最新版ではない可能性があります。最新版が必要な場合は、ビルド済みパッケージの使用またはソースコードからのビルドを行ってください。

#### ビルド済みパッケージの使用（推奨）

1. [GitHub Releases](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest) に移動
2. "Assets" セクションから最新の `anime4k-webextension.zip` をダウンロード
3. ZIPファイルを解凍
4. 解凍したディレクトリをブラウザにロード：
   - Chrome: 拡張機能ページを開く (`chrome://extensions`) → 「デベロッパーモード」を有効化 → 「パッケージ化されていない拡張機能を読み込む」 → 解凍したディレクトリを選択
   - Edge: 拡張機能ページを開く (`edge://extensions`) → 「開発者モード」を有効化 → 「解凍された拡張機能を読み込む」 → 解凍したディレクトリを選択

#### ソースコードからインストール

1. 本リポジトリをクローン
2. `npm install` を実行して依存関係をインストール
3. `npm run build` を実行してプロジェクトをビルド
4. ブラウザにビルドした拡張機能をロード：
   - Chrome: 拡張機能ページを開く (`chrome://extensions`) → 「デベロッパーモード」を有効化 → 「パッケージ化されていない拡張機能を読み込む」 → プロジェクトの `dist` ディレクトリを選択
   - Edge: 拡張機能ページを開く (`edge://extensions`) → 「開発者モード」を有効化 → 「解凍された拡張機能を読み込む」 → プロジェクトの `dist` ディレクトリを選択

### 基本使用

1. 拡張機能をインストール後、動画要素を含むウェブサイト（Bilibili、Ani-Oneなど）にアクセス
2. 動画再生時、動画要素の左中部に紫色の「✨ 超解像」ボタンが表示されます
3. ボタンをクリックして超解像処理を有効化
4. 再度クリックして処理を無効化

### 詳細設定

ツールバーアイコンをクリックしてコントロールパネルを開く：

- **拡張モード**: 異なるモードを選択（[詳細説明](https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md)）
- **解像度**: 出力解像度を設定
- **ホワイトリスト**: 拡張機能を有効にするウェブサイトを管理

### ホワイトリスト管理

1. ポップアップパネルでホワイトリスト機能を有効化
2. ルールタイプを追加：
   - 現在のページ：`www.example.com/video/123`
   - 現在のドメイン：`*.example.com/*`
   - 親パス：`www.example.com/video/*`
3. オプションページですべてのルールを管理

## 謝辞

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
