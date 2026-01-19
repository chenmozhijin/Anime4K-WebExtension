# Anime4K WebExtension

[中文](./README.md) | [English](./README.en.md) | 日本語 | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=Edge%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![Mozilla Add-on Users](https://img.shields.io/amo/users/anime4k-webextension?style=flat-square&label=Firefox%20%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://addons.mozilla.org/firefox/addon/anime4k-webextension/)
 [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/Anime4K-WebExtension/total?style=flat-square&label=GitHub%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)

Anime4Kリアルタイム超解像アルゴリズムを利用して、アニメ動画の画質を大幅に向上させ、フレームごとに、より鮮明でシャープな視覚体験を提供します！

## 機能特徴

- 🚀 **WebGPU リアルタイム超解像:** 先進的な WebGPU 技術を活用し、ブラウザ上で低遅延かつ高性能な動画リアルタイム超解像機能を実現します。
- ⚡ **多段階のパフォーマンス設定:** 速い/バランス/品質/ウルトラ の4つのプリセットモードを提供し、カスタムモードもサポート。画質向上とハードウェア負荷のバランスを柔軟に調整できます。
- 📊 **ハードウェア性能評価:** 内蔵の GPU ベンチマークテストにより、お使いのハードウェアに最適な超解像ティア（段階）を推奨します。
- 📏 **柔軟な解像度制御:** 2x/4倍/8倍の拡大率をサポートし、2K/4K などの目標解像度に固定することも可能で、多様な視聴ニーズに応えます。
- ✨ **ワンクリック超解像:** 動画プレーヤー上に紫色の「✨ 超解像」ボタンが自動的に表示され、ワンクリックで画質を飛躍的に向上させます。
- 🛡️ **幅広い互換性:** Shadow DOM、iframe、およびクロスオリジン動画ソースに対応し、技術的な制限を突破して大多数の動画サイトをカバーします。
- 📋 **オンデマンド有効化メカニズム:** 正確なホワイトリスト戦略をサポートし、指定されたサイトでのみ有効になるため、リソースの無駄やページへの干渉を防ぎます。
- 🌈 **モダンな UI デザイン:** Material Design ガイドラインに準拠し、ライト/ダーク/システム設定に追従するテーマに適応し、快適でスムーズな視覚体験を提供します。
- 🌐 **国際化サポート:** 中国語、英語、日本語、ロシア語など多言語をサポートし、世界中のユーザーにサービスを提供します。

> [!WARNING]
> この拡張機能は、Encrypted Media Extensions (EME) または DRM で保護された動画サイト（Netflixなど）では動作しません。

## 使用ガイド

### 拡張機能のインストール

#### アプリストアからインストール（推奨）

- [![GitHub Release](https://img.shields.io/github/v/release/chenmozhijin/Anime4K-WebExtension?style=flat-square&label=%E6%9C%80%E6%96%B0%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)
- [![Edge Store Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.version&style=flat-square&label=Edge%E6%8B%A1%E5%BC%B5%E6%A9%9F%E8%83%BD%E3%82%B9%E3%83%88%E3%82%A2)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam)
- [![Chrome Web Store Version](https://img.shields.io/chrome-web-store/v/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E3%82%A6%E3%82%A7%E3%83%96%E3%82%B9%E3%83%88%E3%82%A2)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek)
- [![Mozilla Add-on Version](https://img.shields.io/amo/v/anime4k-webextension?style=flat-square&label=Firefox%20%E3%82%A2%E3%83%89%E3%82%A2%E3%83%B3)](https://addons.mozilla.org/firefox/addon/anime4k-webextension/)

> [!NOTE]
>
> 1. 上記のバッジをクリックしてストアページに移動します。
> 2. 審査プロセスのため、ストアのバージョンは最新版ではない可能性があります。最新版が必要な場合は、ビルド済みパッケージの使用またはソースコードからのビルドを行ってください。

#### ビルド済みパッケージの使用

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

### 一、 初回セットアップ (Onboarding)

拡張機能をインストールすると、自動的にオンボーディングページが開きます。最適な体験を得るために、ガイドに従って設定を完了してください：

1.  **GPU ベンチマーク**: 拡張機能は短いベンチマーク（目標：1080p -> 4K 24fps）を実行し、グラフィックカードの性能を評価します。
2.  **推奨ティア**: 結果に基づいて、拡張機能は適切なパフォーマンスティア (Performance Tier) を自動的に推奨します：
    *   🚀 **高速**: 統合グラフィックスや古いデバイス向けで、滑らかさを優先します。
    *   ⚖️ **バランス**: 画質とパフォーマンスのバランスを取り、ほとんどの中級デバイスに適しています。
    *   🎨 **画質**: より良い画像の詳細を提供し、個別のグラフィックカードに適しています。
    *   🔬 **究極**: 最高画質。強力なグラフィックカード性能が必要です。
3.  **適用**: 推奨を受け入れるか、手動で別のティアを選択できます。

### 二、 日常的な使用

1.  **強化を有効にする**：拡張機能をインストールした後、サポートされている動画サイト（Bilibili, YouTubeなど）で動画を再生します。マウスをビデオプレーヤーに合わせると、左側に紫色の **「✨ 超解像」** ボタンが表示されます。
2.  **クリックで切り替え**：ボタンをクリックすると、リアルタイム超解像が有効になります。ボタンの状態は「⏳ 起動中...」から「❌ キャンセル」に変わります。
3.  **自動非表示**：マウスを離すとボタンは自動的に非表示になり、すっきりとした視聴体験を維持します。

### 三、 ポップアップパネルの設定

ブラウザのツールバーにあるAnime4K拡張機能アイコンをクリックして、クイック設定パネルを開きます：

*   **パフォーマンスティア (Performance Tier)**: 4つのプリセットを素早く切り替えます。
    *   *注意：「カスタムモード」が選択されている場合、カスタムモードは特定のシェーダーの組み合わせによって定義されるため、パフォーマンスティアは利用できません。*
*   **強化モード (Enhancement Mode)**:
    *   **内蔵モード**: モードA、モードB、モードCなどのクラシックなAnime4Kプリセット。
    *   **カスタムモード**: 作成またはインポートした高度なモード。
*   **解像度 (Resolution)**: 目標出力解像度を設定します（x2スケーリングまたは固定1080p/4Kなど）。
*   **ホワイトリスト (Whitelist)**:
    *   現在のページ、ドメイン、または親パスを素早くホワイトリストに追加します。
    *   ホワイトリスト機能をグローバルに有効/無効にします。

### 四、 詳細設定

パネル下部の **「設定」** ボタンをクリックして、詳細設定ページにアクセスします：

#### 1. 一般設定 (General)
*   **外観**: ライト/ダークテーマを切り替えます。
*   **互換性**: ブラウザのセキュリティポリシーにより強化に失敗する動画（ネストされたサードパーティプレーヤーでよく見られます）を修正するには、**「クロスオリジン互換モード」**を有効にします。

#### 2. パフォーマンス設定 (Performance)
*   **GPUテスト**: いつでもベンチマークを再実行して、パフォーマンススコアを更新できます。
*   **現在のティア**: 現在有効なパフォーマンス構成を表示します。

#### 3. 強化モード (Enhancement Modes)
*   **ビジュアルエディタ**: 新しいカスタムモードを作成します。
*   **ドラッグ＆ドロップ並べ替え**: 適用されるシェーダーの順序やモードリスト自体の順序を調整します。
*   **設定の共有**: カスタムモード設定をインポート/エクスポートします（JSON形式）。

#### 4. ホワイトリスト管理 (Whitelist Management)
*   **ルール管理**: 追加されたURLルールを表示、編集、または削除します。
*   **ワイルドカード**: `*` を使用して複数のページにマッチさせます（例：`*.bilibili.com/*`）。

## 謝辞

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
