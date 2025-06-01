const path = require('path');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const ExtensionManifestPlugin = require('webpack-extension-manifest-plugin');
const packageJson = require('./package.json');

const baseManifest = {
  manifest_version: 3,
  name: "Anime4K WebExtension",
  version: packageJson.version,
  description: packageJson.description,
  action: {
    default_popup: 'popup.html',
    default_icon: {
      '16': 'icons/icon16.png',
      '32': 'icons/icon32.png',
      '48': 'icons/icon48.png',
      '128': 'icons/icon128.png'
    }
  },
  options_page: 'options.html',
  background: {
    service_worker: 'background.js'
  },
  content_scripts: [
    {
      matches: ['<all_urls>'],
      js: ['content.js'],
      run_at: 'document_idle'
    }
  ],
  permissions: ['storage', 'activeTab'],
  host_permissions: ['<all_urls>'],
  default_locale: "en",
  icons: {
    '16': 'icons/icon16.png',
    '32': 'icons/icon32.png',
    '48': 'icons/icon48.png',
    '128': 'icons/icon128.png'
  }
};

module.exports = (env, argv) => {
  const isDevelopment = argv.mode === 'development';
  
  return {
    entry: {
      popup: './src/ui/popup/popup.ts',
      options: './src/ui/options/options.ts',
      content: './src/content.ts',
      background: './src/background.ts'
    },
    output: {
      filename: '[name].js',
      path: path.resolve(__dirname, 'dist'),
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
          { from: 'public/icons', to: 'icons' },
          { from: 'public/_locales', to: '_locales' },
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
          base: baseManifest
        }
      }),
    ].filter(Boolean),
    devtool: isDevelopment ? 'inline-source-map' : false,
    watch: isDevelopment,
  };
};