---
title: "Securing Azure Functions with Easy Auth and Identity Server 4"
date: 2020-10-20
draft: true
author: "Casey McQuillan"
tags: [ "dotnet", "azure", "azure-functions", "identity-server", "oauth" ]
description: ""
---

## Open ID Providers are now in Preview

Set up identity server 

```
dotnet new sln
dotnet new -i identityserver4.templates
dotnet new is4inmem -n IdServer
dotnet sln . add IdServer

dotnet new blazorwasm -n Client
dotnet sln . add .\Client\
```

Set up function app

