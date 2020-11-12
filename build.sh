#!/bin/sh

pushd assets/apps/fiddle/src/Fiddle.Run.Client
npm install
ng build --prod --outputPath=../../../../../content/apps/fiddle --baseHref=/apps/fiddle/ --deployUrl=/apps/fiddle/ --deleteOutputPath=false
popd

hugo -d public