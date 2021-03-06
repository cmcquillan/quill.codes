#!/bin/sh

npm install -g postcss postcss-cli
npm install -g autoprefixer
npm install -g @angular/cli

cd assets/apps/fiddle/src/Fiddle.Run.Client
npm install
ng build --prod --outputPath=../../../../../content/apps/fiddle --baseHref=/apps/fiddle/ --deployUrl=/apps/fiddle/ --deleteOutputPath=false
cd ../../../../..

ls content/apps/fiddle

cd themes/quill-codes/

npm install

cd ../..

hugo