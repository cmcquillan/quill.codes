---
title: "Dont Fear the // Todo"
description: "Ever write a TODO and fear that it will be forgotten later? Use the Visual Studio Task List to keep track of work in progress."
date: 2020-09-16T13:58:39-07:00
draft: false
author: "Casey McQuillan"
tags: ["Visual Studio", "Productivity"]
---

## Did You Know?

### Visual Studio tracks your "// TODO" comments so you can find them later.

From within Visual Studio Go to View -> Task List. This will display the **Task List** window and show you any area of your open Solution. You can even filter down to your Current Project, Current Document, or Open Documents.

![Visual Studio Task View showing two TODO comments](https://quill-static.sfo2.digitaloceanspaces.com/images/tips/visual_studio_task_view.PNG)

It doesn't just recognize `// TODO`, but will also recognize `// HACK`
![Visual Studio Task View showing single HACK comment](https://quill-static.sfo2.digitaloceanspaces.com/images/tips/visual_studio_task_view_hack.PNG)

### What if I Don't Use English?

You can customize the words that trigger a Task View entry in your Visual Studio options. 

1. Go to *Tools*
2. Go to *Options*
3. Expand the *Environment options*
4. Go to *Task List*
5. Enter any words you would like to highlight from your code comments.

![Visual Studio Options dialog showing the Task List menu](https://quill-static.sfo2.digitaloceanspaces.com/images/tips/visual_studio_task_list_options.PNG)

## Additional Links

* [Microsoft Task View Documentation](https://docs.microsoft.com/en-us/visualstudio/ide/using-the-task-list?view=vs-2019)