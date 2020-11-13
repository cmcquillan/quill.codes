---
title: "Don't Fear the // Todo"
description: "Ever write a TODO and fear that it will be forgotten later? Use the Visual Studio Task List to keep track of work in progress."
date: 2020-09-16T13:58:39-07:00
draft: false
author: "Casey McQuillan"
tags: ["Visual Studio", "Productivity"]
images:
  - tips/dont-fear-the-todo/todo_cover.png
  - images/visual_studio_tips.png
cover_image: images/visual_studio_tips.png
cover_image_alt: "A CSharp class named App with a Main() method and a single comment that says 'TODO: Don't be afraid' with a sunglasses emoji."
---

## Did You Know?

### Visual Studio tracks your "// TODO" comments so you can find them later.

From within Visual Studio Go to **View** -> **Task List**. This will display the **Task List** window and show you any area of your open Solution that has existing comments that start with `// TODO`. You can filter down to your Current Project, Current Document, or Open Documents. It even will allow you to search the list.

![Visual Studio Task View showing two TODO comments](visual_studio_task_view.png)

It doesn't just recognize `// TODO`, but will also recognize `// HACK`
![Visual Studio Task View showing single HACK comment](visual_studio_task_view_hack.png)

### What if I Don't Use English?

You can customize the words that trigger a Task View entry in your Visual Studio options. 

1. Go to **Tools**
2. Go to **Options**
3. Expand the **Environment options**
4. Go to **Task List**
5. Enter any words you would like to highlight from your code comments.

![Visual Studio Options dialog showing the Task List menu](visual_studio_task_list_options.png)

### How Should I Use It?

Properly leveraging the **Task List** window can be fantastic for your productivity. Here are a few of the ways I have personally used this window to improve my workflow.

* Leaving occasional `// TODO` comments while prototyping when the unwritten code will not change functionality. It serves as a reminder to complete the code before delivering a milestone or making a final commit.
* When writing a Web API, create the first round of CRUD endpoints using fake data and add `// TODO` to the top of every method. When all of the base endpoints are in there is now an easy checklist to complete.
* Adding `// CONSIDER` to the list of words tracked by Visual Studio and using it to keep a list of places where long-term improvements can be made to a codebase. This can be set to a lower priority so that other tracked words stand out within the list.

## Additional Links

* [Microsoft Task View Documentation](https://docs.microsoft.com/en-us/visualstudio/ide/using-the-task-list?view=vs-2019)