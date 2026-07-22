const path = require('node:path');

module.exports = {
  mode: 'development',
  entry: {
    'effect-runner': './test/verify/browser/effect-runner.ts',
  },
  output: {
    filename: '[name].js',
    chunkFilename: '[name].js',
    path: path.resolve(__dirname, 'test-results/verify/browser'),
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        loader: 'esbuild-loader',
        options: {
          loader: 'ts',
          target: 'es2022',
        },
        exclude: /node_modules/,
      },
      {
        test: /\.wgsl$/,
        type: 'asset/source',
      },
    ],
  },
  resolve: {
    extensions: ['.ts', '.js', '.wgsl'],
  },
  devtool: false,
};
