# NijiLucid

[中文](./README.md) | [English](./README.en.md) | 日本語 | [Русский](./README.ru.md)

[![Edge Store Users](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.activeInstallCount&style=flat-square&label=Edge%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://microsoftedge.microsoft.com/addons/detail/ffopffngebibpmeodlhhkdlaejnmdlam) [![Chrome Web Store Users](https://img.shields.io/chrome-web-store/users/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://chromewebstore.google.com/detail/hpmbccepehpoanjpjkamfdpdkbmfmhek) [![Mozilla Add-on Users](https://img.shields.io/amo/users/nijilucid?style=flat-square&label=Firefox%20%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC)](https://addons.mozilla.org/firefox/addon/nijilucid/)
 [![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/chenmozhijin/NijiLucid/total?style=flat-square&label=GitHub%E3%83%80%E3%82%A6%E3%83%B3%E3%83%AD%E3%83%BC%E3%83%89)](https://github.com/chenmozhijin/NijiLucid/releases/latest)

NijiLucid は WebGPU を利用してアニメ動画の画質をリアルタイムで高め、フレームごとにより鮮明でシャープな視聴体験を提供します！

## 機能特徴

- 🚀 **WebGPU リアルタイム超解像:** 先進的な WebGPU 技術を活用し、ブラウザ上で低遅延かつ高性能な動画リアルタイム超解像機能を実現します。
- ⚡ **複数のパフォーマンスティア:** 速い/バランス/品質/ウルトラ の4つのパフォーマンスティアを提供し、カスタムモードもサポート。画質向上とハードウェア負荷のバランスを柔軟に調整できます。
- 🧪 **高度なカスタムエフェクト:** 複数の強化エフェクトを自由に組み合わせて好みに合う画づくりができ、おすすめプリセットは選択したパフォーマンスティアに合わせてエフェクト構成を自動調整します。
- 📊 **ハードウェア性能評価:** 内蔵の GPU ベンチマークテストにより、お使いのハードウェアに最適な超解像ティア（段階）を推奨します。
- 📏 **柔軟な解像度制御:** 2x/4倍/8倍の拡大率をサポートし、2K/4K などの目標解像度に固定することも可能で、多様な視聴ニーズに応えます。
- ✨ **ワンクリック超解像:** 動画プレーヤー上に紫色の「✨ 超解像」ボタンが自動的に表示され、ワンクリックで画質を飛躍的に向上させます。
- 🛡️ **幅広い互換性:** 通常の DOM、オープンな Shadow DOM、iframe などの一般的なページ構造に対応。クロスオリジン動画の読み込みで問題が起きた場合は、クロスオリジン互換モードを試せます。
- 📋 **オンデマンド有効化メカニズム:** 正確なホワイトリスト戦略をサポートし、指定されたサイトでのみ有効になるため、リソースの無駄やページへの干渉を防ぎます。
- 🌈 **モダンな UI デザイン:** Material Design ガイドラインに準拠し、ライト/ダーク/システム設定に追従するテーマに適応し、快適でスムーズな視覚体験を提供します。
- 🌐 **国際化サポート:** 中国語、英語、日本語、ロシア語など多言語をサポートし、世界中のユーザーにサービスを提供します。

> [!WARNING]
> この拡張機能は、Encrypted Media Extensions (EME) または DRM で保護された動画サイト（Netflixなど）では動作しません。

## 使用ガイド

### 拡張機能のインストール

#### アプリストアからインストール（推奨）

- [![GitHub Release](https://img.shields.io/github/v/release/chenmozhijin/NijiLucid?style=flat-square&label=%E6%9C%80%E6%96%B0%E3%83%90%E3%83%BC%E3%82%B8%E3%83%A7%E3%83%B3)](https://github.com/chenmozhijin/NijiLucid/releases/latest)
- [![Edge Store Version](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fmicrosoftedge.microsoft.com%2Faddons%2Fgetproductdetailsbycrxid%2Fffopffngebibpmeodlhhkdlaejnmdlam&query=%24.version&style=flat-square&label=Edge%E6%8B%A1%E5%BC%B5%E6%A9%9F%E8%83%BD%E3%82%B9%E3%83%88%E3%82%A2)](https://microsoftedge.microsoft.com/addons/detail/ffopffngebibpmeodlhhkdlaejnmdlam)
- [![Chrome Web Store Version](https://img.shields.io/chrome-web-store/v/hpmbccepehpoanjpjkamfdpdkbmfmhek?style=flat-square&label=Chrome%E3%82%A6%E3%82%A7%E3%83%96%E3%82%B9%E3%83%88%E3%82%A2)](https://chromewebstore.google.com/detail/hpmbccepehpoanjpjkamfdpdkbmfmhek)
- [![Mozilla Add-on Version](https://img.shields.io/amo/v/nijilucid?style=flat-square&label=Firefox%20%E3%82%A2%E3%83%89%E3%82%A2%E3%83%B3)](https://addons.mozilla.org/firefox/addon/nijilucid/)

> [!NOTE]
>
> 1. 上記のバッジをクリックしてストアページに移動します。
> 2. 審査プロセスのため、ストアのバージョンは最新版ではない可能性があります。最新版が必要な場合は、ビルド済みパッケージの使用またはソースコードからのビルドを行ってください。

#### ビルド済みパッケージの使用

1. [GitHub Releases](https://github.com/chenmozhijin/NijiLucid/releases/latest) に移動
2. "Assets" セクションから最新の拡張機能パッケージをダウンロード：
   - Chrome/Edge: `nijilucid.zip`
   - Firefox: `nijilucid-firefox.zip`
3. ZIPファイルを解凍
4. 解凍した拡張機能をブラウザにロード：
   - Chrome: 拡張機能ページを開く (`chrome://extensions`) → 「デベロッパーモード」を有効化 → 「パッケージ化されていない拡張機能を読み込む」 → 解凍したディレクトリを選択
   - Edge: 拡張機能ページを開く (`edge://extensions`) → 「開発者モード」を有効化 → 「解凍された拡張機能を読み込む」 → 解凍したディレクトリを選択
   - Firefox: `about:debugging#/runtime/this-firefox` を開く → 一時的なアドオンを読み込む → 解凍したディレクトリの `manifest.json` を選択

#### ソースコードからインストール

1. 本リポジトリをクローン
2. `npm install` を実行して依存関係をインストール
3. 使用するブラウザに合わせてビルド：
   - Chrome/Edge: `npm run build:chrome` を実行
   - Firefox: `npm run build:firefox` を実行
4. ブラウザにビルドした拡張機能をロード：
   - Chrome/Edge: 拡張機能ページを開く (`chrome://extensions` または `edge://extensions`) → 開発者モードを有効化 → パッケージ化されていない拡張機能を読み込む → プロジェクトの `dist-chrome` ディレクトリを選択
   - Firefox: `about:debugging#/runtime/this-firefox` を開く → 一時的なアドオンを読み込む → `dist-firefox/manifest.json` を選択

### 一、 初回セットアップ (Onboarding)

拡張機能をインストールすると、自動的にオンボーディングページが開きます。最適な体験を得るために、ガイドに従って設定を完了してください：

1.  **GPU ベンチマーク**: 拡張機能は短いベンチマーク（目標：1080p -> 4K 24fps）を実行し、グラフィックカードの性能を評価します。
2.  **推奨ティア**: 結果に基づいて、拡張機能は適切なパフォーマンスティア (Performance Tier) を自動的に推奨します：
    *   🚀 **速い**: 統合グラフィックスや古いデバイス向けで、滑らかさを優先します。
    *   ⚖️ **バランス**: 画質とパフォーマンスのバランスを取り、ほとんどの中級デバイスに適しています。
    *   🎨 **品質**: より良い画像の詳細を提供し、個別のグラフィックカードに適しています。
    *   🔬 **ウルトラ**: 最高画質。強力なグラフィックカード性能が必要です。
3.  **適用**: 推奨を受け入れるか、手動で別のティアを選択できます。

### 二、 日常的な使用

1.  **強化を有効にする**：サポートされている動画サイト（Bilibili, YouTubeなど）で動画を再生します。
2.  **クリックで切り替え**：動画プレーヤーの左側中央付近にマウスを合わせると、紫色の **「✨ 超解像」** ボタンが表示されます。クリックすると超解像をオン/オフできます。起動中は「⏳ 起動中...」、有効後は「❌ キャンセル」と表示されます。
3.  **自動非表示**：マウスカーソルが動画プレーヤーの左側中央付近またはボタンから離れると、ボタンは自動的に非表示になり、画面を遮りません。

#### Firefox の権限と使用方法

Firefox ユーザーには、拡張機能の **「権限とデータ」** ページで **「すべてのウェブサイトのデータへのアクセス」** を有効にすることをおすすめします。有効にすると、対応する動画サイトごとに手動で有効化しなくても NijiLucid を直接使用できます。

すべてのウェブサイトへのアクセスを有効にしたくない場合は、必要なときだけ使用できます：

1. 動画を再生するウェブページを開きます。
2. Firefox のツールバーにある NijiLucid 拡張機能アイコンをクリックすると、現在のページが有効になります。
3. 現在のウェブサイトで NijiLucid の許可を継続したい場合は、拡張機能アイコンを右クリックし、メニューからそのウェブサイトでの継続的なアクセスを許可します。
4. まだ許可していない別のウェブサイトに移動した場合は、同じ手順を繰り返します。

### 三、 ポップアップパネルの設定

ブラウザのツールバーにある NijiLucid 拡張機能アイコンをクリックして、クイック設定パネルを開きます：

*   **パフォーマンスティア (Performance Tier)**: 4つのパフォーマンスティアを素早く切り替えます。
    *   *注意：「カスタムモード」が選択されている場合、カスタムモードは特定のエフェクトの組み合わせによって定義されるため、パフォーマンスティアは利用できません。*
*   **強化モード (Enhancement Mode)**:
    *   **内蔵モード**: 3つのおすすめプリセットと6つの互換モードを含みます。
    *   **おすすめプリセット**: ディテール保持、再圧縮クリーンアップ、ソフトスタイル。選択したパフォーマンスティアに合わせてエフェクト構成を調整します。
    *   **互換モード**: Mode A、Mode B、Mode C、Mode A+A、Mode B+B、Mode C+A。
    *   **カスタムモード**: 作成またはインポートしたモードで、エフェクトを自由に組み合わせられます。
*   **解像度 (Resolution)**: x2、x4、x8 の拡大、または 720p、1080p、2K (1440p)、4K (2160p) の固定目標解像度を選択できます。固定目標解像度は元動画のアスペクト比を維持します。Native は元の解像度で出力し、拡大は行いませんが、強化を無効にするわけではありません。
*   **ホワイトリスト (Whitelist)**:
    *   現在のページ、ドメイン、または親パスを素早くホワイトリストに追加します。
    *   ホワイトリスト機能をグローバルに有効/無効にします。

### 四、 詳細設定

パネル下部の **「設定」** ボタンをクリックして、詳細設定ページにアクセスします：

#### 1. 一般設定 (General)
*   **外観**: ライト/ダークテーマを切り替えます。
*   **互換性**: ブラウザのセキュリティポリシーにより強化できない動画（ネストされたサードパーティプレーヤーでよく見られます）では、**「クロスオリジン互換モード」**を有効にします。このモードはクロスオリジン読み込みの問題を修正しようとします。有効化後は、開いているページを更新してください。

#### 2. パフォーマンス設定 (Performance)
*   **GPUテスト**: いつでもベンチマークを再実行して、パフォーマンススコアを更新できます。
*   **現在のティア**: 現在有効なパフォーマンス構成を表示します。
*   **パフォーマンスモニター**: オフ、軽量、GPU 診断の3つのモードを提供します。軽量は全体のフレーム性能を表示し、GPU 診断はブラウザが GPU タイムスタンプクエリに対応している場合に各エフェクトの GPU 処理時間を表示します。HUD は折りたたみ、パフォーマンススナップショットのコピー、位置変更、幅の調整、閉じる操作に対応します。

#### 3. 強化モード (Enhancement Modes)
*   **ビジュアルエディタ**: 新しいカスタムモードを作成します。
*   **高度なエフェクト**: ArtCNN、ACNet、ARNet、CuNNy などをカスタムモードで手動追加できます。おすすめプリセットも、選択したパフォーマンスティアに応じたエフェクト構成を使用します。
*   **ドラッグ＆ドロップ並べ替え**: 適用するエフェクトの順序やモードリスト自体の順序を調整します。
*   **設定の共有**: カスタムモード設定をインポート/エクスポートします（JSON形式）。

#### 4. ホワイトリスト管理 (Whitelist Management)
*   **ルール管理**: 追加されたURLルールを表示、編集、または削除します。
*   **ワイルドカード**: `*` を使用して複数のページにマッチさせます（例：`*.bilibili.com/*`）。
*   **一致範囲**: ホワイトリストルールは `hostname + pathname` のみを照合します。プロトコル、ポート、クエリ、ハッシュは無視されます。たとえば `example.com/watch/*` は `https://example.com:8443/watch/1?from=home` に一致します。


## 謝辞

- [bloc97/Anime4K](https://github.com/bloc97/Anime4K)
- [Anime4K-WebGPU](https://github.com/Anime4KWebBoost/Anime4K-WebGPU)（歴史的な実装の参考）
- [ArtCNN](https://github.com/Artoriuz/ArtCNN)
- [ACNetGLSL](https://github.com/TianZerL/ACNetGLSL)
- [CuNNy](https://github.com/funnyplanter/CuNNy)

## ライセンス

プロジェクト本体は MIT ライセンスです。既定の拡張パッケージに含まれる
CuNNy 生成コンポーネントは LGPL-3.0-or-later です。詳細は
[THIRD_PARTY_NOTICES.md](./THIRD_PARTY_NOTICES.md) を参照してください。
