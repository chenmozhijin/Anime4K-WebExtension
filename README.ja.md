# Anime4K WebExtension

[中文](./README.md) | [English](./README.en.md) | 日本語 | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=Edge%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://microsoftedge.microsoft.com/addons/detail/anime4k-webextension/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://chromewebstore.google.com/detail/anime4k-webextension/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![Mozilla Add-on Users](https://img.shields.io/amo/users/anime4k-webextension?style=flat-square&label=Firefox%20%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://addons.mozilla.org/firefox/addon/anime4k-webextension/)
 [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/Anime4K-WebExtension/total?style=flat-square&label=GitHub%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89)](https://github.com/chenmozhijin/Anime4K-WebExtension/releases/latest)

Anime4Kリアルタイム超解像アルゴリズムを利用して、アニメ動画の画質を大幅に向上させ、フレームごとに、より鮮明でシャープな視覚体験を提供します！

## 機能特徴

- 🚀 **リアルタイム超解像:** ブラウザでの動画再生中にWebGPU技術を利用して、即時の超解像効果を提供します。
- ⚙️ **柔軟な強化モード:** 複数のプリセットモードを提供し、カスタムモードもサポート。さまざまな動画やデバイスに合わせて、異なる強化効果を自由に組み合わせることができます。
- 📏 **柔軟なスケーリング:** 2倍/4倍/8倍の出力、または720p/1080p/2K/4Kの固定出力解像度を提供します。
- ⚡ **ワンクリック強化:** ビデオプレーヤーに紫色の「✨ 超解像」ボタンが自動的に表示され、クリックするだけで超解像効果を有効にできます。
- 🛡️ **幅広い互換性:** Shadow DOM、iframe、クロスオリジンビデオをサポートし、できるだけ多くのウェブサイトに対応します。
- 📋 **正確なホワイトリスト:** 指定したウェブサイトやページでのみ機能し、干渉を避け、リソースを節約します。
- 🌈 **テーマ切り替え:** ライト/ダーク/自動テーマモードをサポートし、現代的なMaterial Designインターフェースを提供します。
- 🌐 **多言語インターフェース:** 中国語、英語、日本語、ロシア語などをサポート。

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

### 一、クイックスタート

1. **強化を有効にする**：拡張機能をインストールした後、サポートされている動画サイト（Bilibili, YouTubeなど）で動画を再生します。マウスをビデオプレーヤーに合わせると、左側に紫色の **「✨ 超解像」** ボタンが表示されます。
2. **クリックで切り替え**：ボタンをクリックすると、リアルタイム超解像が有効になります。処理中はボタンに「強化中...」と表示され、完了すると「強化をキャンセル」に変わります。もう一度クリックすると、強化効果がオフになります。
3. **自動非表示**：マウスを離すとボタンは自動的に非表示になり、すっきりとした視聴体験を維持します。

### 二、ポップアップパネルの設定

ブラウザのツールバーにあるAnime4K拡張機能アイコンをクリックすると、クイック設定パネルが開きます。

- **強化モード**：プリセットまたはカスタムの強化モードを素早く切り替えます。
- **出力解像度**：強化後のビデオの出力解像度を選択します。
- **倍率スケーリング**：`x2`, `x4`, `x8` は、元のビデオ解像度を対応する倍数で乗算します。
- **固定解像度**：`720p`, `1080p`, `2K`, `4K` は、ビデオを固定の解像度で出力します。
- **ホワイトリストスイッチ**：ホワイトリスト機能をグローバルに有効または無効にします。オフにすると、拡張機能はすべてのウェブサイトで実行を試みます。
- **ホワイトリストへのクイック追加**：
- **現在のページを追加**：現在のページの正確なURLのみをホワイトリストに追加します（クエリパラメータは含みません）。
- **現在のドメインを追加**：現在のウェブサイトのすべてのページをホワイトリストに追加します（例：`www.youtube.com/*`）。
- **親パスを追加**：現在のページの上位ディレクトリをホワイトリストに追加します（例：`site.com/videos/123` から `site.com/videos/*` を追加）。
- **詳細設定へ**：「詳細設定を開く」ボタンをクリックして、より包括的な機能を持つオプションページにアクセスします。

### 三、上級設定

オプションページでは、拡張機能を詳細にカスタマイズできます。

#### 1. 強化モードの管理

ここでは、強化効果の組み合わせを完全に制御できます：

- **新しいモードの作成**：「モードを追加」ボタンをクリックして、新しい空のモードを作成します。
- **モードのカスタマイズ**：
- **名前の変更**：モード名を直接クリックして編集します。
- **効果の調整**：モードカードの左側にある矢印をクリックして詳細を展開します。展開されたビューでは、ドラッグ＆ドロップで強化効果を**並べ替え**たり、`×` をクリックして効果を**削除**したりできます。
- **効果の追加**：展開されたビューで、ドロップダウンメニューから新しい強化効果を選択し、処理チェーンに追加します。
- **モードの管理**：モードカードをドラッグしてすべてのカスタムモードを**並べ替え**たり、「削除」ボタンをクリックして不要なカスタムモードを**削除**したりします（内蔵モードは削除したり、効果の組み合わせを変更したりすることはできません）。
- **インポート/エクスポート**：カスタムモードの設定をJSONファイルとして簡単に共有またはバックアップします。

#### 2. ホワイトリストの管理

拡張機能の適用範囲をきめ細かく制御します：

- **ルールリスト**：すべてのホワイトリストルールを一元管理します。ルールを手動で**編集**したり、チェックボックスで特定のルールを**有効/無効**にしたり、ルールを**削除**したりできます。
- **ルールの追加**：新しいURLマッチングルールを手動で追加します。ルールはワイルドカード `*` をサポートしており、たとえば `*.bilibili.com/*` はBilibiliのすべてのページにマッチします。
- **インポート/エクスポート**：ホワイトリストルールをJSONファイルとしてバックアップしたり、他の人から共有されたものをインポートしたりします。

#### 3. 一般設定

- **テーマモード:** インターフェースの外観テーマを選択します。ライトモード、ダークモード、またはシステム設定に従う自動モードをサポートします。
- **クロスオリジン互換モード**：「クロスオリジン」の制限により強化に失敗するビデオ（サードパーティのビデオソースを使用するサイトでよく見られる）に遭遇した場合、このモードは問題を自動的に修正しようとします。強化中にセキュリティエラーが表示された場合は、必ずこの機能を有効にしてください。

## 謝辞

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)
