# Vue

This directory contains our vue app and other javascript packed with webpack.

## Webpack

Webpack is used to compile these files. The compiled packs are included in the asset pipeline of rails.

```
cd ~/rails/your_platform

# Run webpack once
bin/pack

# Keep webpack running and recompiling on file changes
bin/webpack-dev-server
```

In preparation of deployment or tests, run `rake your_platform:install:node_modules`.

The webpack configuration is in `config/webpack.config.js`.

## Node modules

Add new node modules using `yarn` from the your-platform root directry.

```
cd ~/rails/your_platform
yarn add vue
bin/pack
```

## VueJS

We have a basic VueJS app in place. Register new components in `VueApp.coffee`.

