#!/usr/bin/env bash

echo "Starting web project starter..."
if [ -z ${1+x} ]; then
  echo "Please provide the root directory of the web project as argument."
else
  ROOT=$1
  echo "Creating new web project in $ROOT..."
  if [ ! -d "$ROOT" ]; then
    mkdir -p "$ROOT"
  fi
  cd "$ROOT"
  echo "Initialize web project..."
  npm init -y

  echo "Create src directory..."
  mkdir -p "$ROOT/src"

    echo "Create index.html..."
  cat << EOF > "$ROOT"/src/index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <title><%= htmlWebpackPlugin.options.title %></title>
  </head>
  <body>
    <div id="app">
    </div>
  </body>
</html>
EOF

  echo "Create Index.tsx..."
  cat << EOF > "$ROOT"/src/Index.tsx
import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'

ReactDOM.render(
    <React.StrictMode>
        <App />
    </React.StrictMode>,
    document.getElementById('app')
)
EOF

  echo "Create App.tsx..."
  cat << EOF > "$ROOT"/src/App.tsx
import React from 'react'

const App: React.FC = () => {
    return (
        <>Start</>
    )
}

export default App
EOF

  echo "Create dist directory..."
  mkdir -p "$ROOT/dist"

  echo "Install Webpack and corresponding modules..."
  npm i -D webpack webpack-cli webpack-dev-server html-webpack-plugin fork-ts-checker-webpack-plugin eslint-webpack-plugin

  echo "Create webpack.config.js..."
  cat << EOF > webpack.config.js
const HtmlWebpackPlugin = require('html-webpack-plugin')
const path = require('path')
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')
const ESLintPlugin = require('eslint-webpack-plugin')

module.exports = {
  entry: './src/Index.tsx',
  output: {
    path: path.resolve(__dirname, './dist'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.(js|ts)x?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
        },
      },
    ],
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.jsx', '.js'],
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: 'Test',
      template: './src/index.html'
    }),
    new ForkTsCheckerWebpackPlugin({
      async: false
    }),
    new ESLintPlugin({
      extensions: ["js", "jsx", "ts", "tsx"],
    })
  ],
  devServer: {
    contentBase: path.resolve(__dirname, './dist')
  }
}
EOF

  echo "Install react and react-dom..."
  npm i react react-dom

  echo "Install babel..."
  npm i -D @babel/core babel-loader @babel/preset-react @babel/preset-env core-js regenerator-runtime @babel/plugin-proposal-class-properties @babel/plugin-proposal-object-rest-spread @babel/preset-typescript @babel/plugin-transform-runtime @babel/runtime

  echo "Create babel.config.json..."
  cat << EOF > babel.config.json
{
  "presets": [
    "@babel/preset-typescript",
    [
      "@babel/preset-env",
      {
        "useBuiltIns": "usage",
        "corejs": 3
      }
    ],
    "@babel/preset-react"
  ],
  "plugins": [
    "@babel/proposal-class-properties",
    "@babel/proposal-object-rest-spread",
    [
      "@babel/plugin-transform-runtime",
      {
        "regenerator": true
      }
    ]
  ]
}
EOF

  echo "Install TypeScript..."
  npm i -D typescript @types/react @types/react-dom
  echo "Create tsconfig.json..."
  cat << EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "umd",
    "lib": [
      "ES2015",
      "ES2016",
      "ES2017",
      "ES2018",
      "ES2019",
      "ES2020",
      "ESNext",
      "dom"
    ],
    "jsx": "react",
    "noEmit": true,
    "sourceMap": true,
    /* Strict Type-Checking Options */
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,

    /* Module Resolution Options */
    "moduleResolution": "node",
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true
  },
  "include": ["./src/**/*"],
  "exclude": [
    "node_modules",
    "**/__tests__/*"
  ]
}
EOF

  echo "Install prettier..."
  npm i -D prettier
  echo "Create .prettierrc..."
  cat << EOF > .prettierrc
{
  "semi": false,
  "trailingComma": "none",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 4
}
EOF

  echo "Install ESLint..."
  npm i -D eslint eslint-plugin-react eslint-plugin-react-hooks @typescript-eslint/parser @typescript-eslint/eslint-plugin
  echo "Create .eslintrc..."
  cat << EOF > .eslintrc
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2018,
    "sourceType": "module"
  },
  "plugins": [
    "@typescript-eslint",
    "react-hooks"
  ],
  "extends": [
    "plugin:react/recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",
    "react/prop-types": "off"
  },
  "settings": {
    "react": {
      "pragma": "React",
      "version": "detect"
    }
  }
}
EOF

  echo "Create .eslintignore..."
  cat << EOF > .eslintignore
node_modules
dist
EOF

  echo "Modify package.json..."
  python3 - << EOF
import json

result = {}

with open("$ROOT/package.json") as fp:
  data = json.load(fp)
  data["scripts"] = {
    "format": "prettier --write \"src/**/*.{js,jsx,ts,tsx,json,md}\"",
    "lint": "eslint --max-warnings=0 src --ext .ts,.tsx",
    "dev": "webpack serve --mode development --open --hot",
    "build": "webpack --mode production"
  }
  result = json.dumps(data, indent=4)

with open("$ROOT/package.json", "w") as fp:
  fp.write(result)

EOF

  echo "Finished setting up web project."
fi
