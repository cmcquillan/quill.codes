---
title: "Deploy Blazor WASM to Netlify"
date: 2020-08-09
draft: true
author: "Casey McQuillan"
tags: [ "dotnet", "blazor" ]
description: ""
---

## Static Sites... Be snappy

The mobile web has created major shifts in the way that we create sites, applications, and content. The introduction of systems like JAMStack have pushed toward a more lightweight, static system that depends upon similarly lightweight APIs in the background for dynamic content. 

One of the more recent entrants to the static web game has been Microsoft's Blazor framework. It leverages the power of Web Assembly (WASM) to allow your C# code to run in the browser and write your Single Page Application (SPA) using your .NET Core knowledge and experience. 

With services like [Netlify](https://www.netlify.com/) taking the lead and pushing their service for static site hosting, it's becoming increasingly more likely that the next blog you visit is really just a webserver holding a plain HTML file.

### Can Netlify Host a Blazor WASM App?

At its core, Netlify is just a host for sites built with static files. Since a Blazor WASM app is fundamentally an `index.html` file with a few static dependencies, this should be right up their alley. There are several examples of the web of how to use the Netlify CLI to deploy:

* [Glen McCallum showing a manual deployment](https://glenmccallum.com/2019/04/27/host-your-blazor-client-on-netlify/)
* [Johan Boström demonstrating with Azure Pipelines](https://johanbostrom.se/blog/how-to-host-and-deploy-blazor-webassembly-using-netlify-and-azure-pipelines)
* [Matthew Jones deploying with Github Actions](https://exceptionnotfound.net/deploying-a-net-core-blazor-app-to-netlify-using-github-actions/)

These are each great resources for different deployment methods. However, since [Netlify also provides their own continuous deployment service](https://www.netlify.com/blog/2015/09/17/continuous-deployment/), I wanted to demonstrate that we can use that to have our Blazor WASM app deploy automatically.

## What You Need
* Code Editor like [VS Code](https://code.visualstudio.com/)
* [.NET Core 5.0](https://dotnet.microsoft.com/download)
* [Github Account](https://github.com/)
* [Netlify Account](https://netlify.com/)

## Initialize a Blazor App

```powershell
mkdir BlazorNetlify
cd BlazorNetlify
dotnet new gitignore
dotnet new blazorwasm
```

You should now have a restored project

```powershell
The template "Blazor WebAssembly App" was created successfully.
This template contains technologies from parties other than Microsoft, see https://aka.ms/aspnetcore/5.0-third-party-notices for details.

Processing post-creation actions...
Running 'dotnet restore' on C:\Users\casey\source\scratch\BlazorNetlify\BlazorNetlify.csproj...
  Determining projects to restore...
  Restored C:\Users\casey\source\scratch\BlazorNetlify\BlazorNetlify.csproj (in 204 ms).
Restore succeeded.
```

```powershell
dotnet run
```

```powershell
Building...
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:5001
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Development
info: Microsoft.Hosting.Lifetime[0]
      Content root path: C:\Users\casey\source\scratch\BlazorNetlify
```

```powershell
mkdir BlazorNetlify
dotnet new blazorwasm

```


You should now be able to visit `https://localhost:5001` and see your blazor app.

![A browser window showing the initial project template for a Blazor WASM application.](blazor_netlify_init.png)

Since this post is just about deploying a Blazor app, this initial template on its own should suffice. Push this to Github or to your other favorite git host for Netlify.

## Set up Your Netlify Build


## Fourth Heading - Adding Redirects for handling direct links

[Redirect Documentation](https://docs.netlify.com/routing/redirects/)

## Fifth Heading - Conclusion



