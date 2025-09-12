const path = require('path');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const ExtensionManifestPlugin = require('webpack-extension-manifest-plugin');

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';
  const targetBrowser = process.env.TARGET_BROWSER || 'chrome';

  const manifest = require('./manifest.json');
  
  // 据目标浏览器修改 manifest
  if (targetBrowser === 'firefox') {
      // Firefox 特定的转换
      delete manifest.background.service_worker;
      manifest.background.scripts = ['background.js'];
      manifest.browser_specific_settings = {
        gecko: {
          id: 'anime4k-webextension@chenmozhijin',
        },
      };
    }

  
  return {
    entry: {
      popup: './src/ui/popup/popup.ts',
      options: './src/ui/options/options.ts',
      content: './src/content.ts',
      background: './src/background.ts',
      'anime4k-module': './src/anime4k-module.ts'
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, 'dist-' + targetBrowser),
      clean: true, // 清理输出目录
    },
    module: {
      rules: [
        {
          test: /\.ts$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
        {
          test: /\.css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader'
          ],
        },
      ],
    },
    resolve: {
      extensions: ['.ts', '.js'],
    },
    plugins: [
      new CleanWebpackPlugin(),
      new CopyWebpackPlugin({
        patterns: [
          { from: '*.png', context: 'public/icons', to: 'icons' },
          { from: 'public/_locales', to: '_locales' },
          { from: 'rules.json' },
        ],
      }),
      new HtmlWebpackPlugin({
        filename: 'popup.html',
        template: './src/ui/popup/popup.html',
        chunks: ['popup'],
      }),
      new HtmlWebpackPlugin({
        filename: 'options.html',
        template: './src/ui/options/options.html',
        chunks: ['options'],
      }),
      new MiniCssExtractPlugin({
        filename: '[name].css',
      }),
      new ExtensionManifestPlugin({
        config: {
          base: manifest,
        },
        pkgJsonProps: [
          'version'
        ]
      }),
    ].filter(Boolean),
    devtool: isDevelopment ? 'inline-source-map' : false,
    watch: isDevelopment,
  };
};