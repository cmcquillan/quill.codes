#!/bin/sh

npm install -g postcss
npm install -g postcss-cli
npm install -g autoprefixer
npm install -g @angular/cli

cd assets/apps/fiddle/src/Fiddle.Run.Client
npm install
ng build --aot --build-optimizer --output-path=../../../../../content/apps/fiddle --base-href=/apps/fiddle/ --deploy-url=/apps/fiddle/ --delete-output-path=false
cd ../../../../..

ls content/apps/fiddle

cd themes/quill-codes/

npm install

cd ../..

hugo