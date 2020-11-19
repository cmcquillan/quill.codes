#!/bin/sh

npm install -g postcss postcss-cli
npm install -g autoprefixer

cd assets/apps/fiddle/src/Fiddle.Run.Client
npm install
ng build --prod --outputPath=../../../../../content/apps/fiddle --baseHref=/apps/fiddle/ --deployUrl=/apps/fiddle/ --deleteOutputPath=false
cd ../../../../..

cd themes/quill-codes/

npm install

cd ../..

hugo