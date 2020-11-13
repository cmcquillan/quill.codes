---
title: "Build your own RSS Reader"
date: 2020-11-7
draft: true
author: "Casey McQuillan"
tags: [ "dotnet", "CSharp", "Prototyping" ]
series:
- "Fast Builds"
description: "Prototype an RSS reader that uses Blazor with browser APIs."
# images:
# - posts/fast-prototyping-url-shortener/fast-prototyping-quill-url-shortener.png
# cover_image: fast-prototyping-quill-url-shortener.png
# cover_image_alt: "A logo with the text 'Quill.Codes' and a picture of a large letter 'Q' with a quill pen superimposed over it. To the right is text stating 'Fast Builds with .NET'"
---





```powershell
dotnet new sln

npm i -g azure-functions-core-tools@3 --unsafe-perm true

dotnet new gitignore


dotnet new blazorwasm -n BlazorFeedReader -o Client -p


dotnet sln . add .\Client\
```
