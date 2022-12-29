rm -r dist

spago bundle-module --main Main --to dist/index.js --platform node --source-maps

cp lambda.package.json dist/package.json