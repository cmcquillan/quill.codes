---
title: "Set Class Fields Using 'out' Parameters"
date: 2020-09-17T12:47:44-07:00
draft: false
description: "Learn a creative way that you can leverage 'out' parameters on your class methods."
author: "Casey McQuillan"
tags: ["CSharp", "Dotnet" "Syntax Tips"]
cover_image: https://quill-static.sfo2.digitaloceanspaces.com/images/tips/set_class_fields_with_out_parameters.png
---

## Did You Know?

### You can set class fields with 'out' method parameters

Whether you like `out` parameters or not in C#, they are here to stay. They decorate a number of common patterns in the .NET ecosystem.

* The `TryParse` pattern where the return is a `bool` that indicates success and your parse result comes from the `out` parameter.


However, very often you want to set your class field with the parse result. At first you would assume that you need to declare a temporary variable to hold the value and then assign the field.

```csharp
public class MyClass
{
  private int _parsedIntField;

  public MyClass(string strToParse)
  {
    if (!Int32.TryParse(strToParse, out int result))
    {
      throw new ArgumentException("Please provide a valid numerical string.", nameof(strToParse));
    }

    _parsedIntField = result;
  }
}
```

However, this isn't necessary. Turns out you can just set the field directly.

```csharp
public class MyClass
{
  private int _parsedIntField;

  public MyClass(string strToParse)
  {
    if (!Int32.TryParse(strToParse, out _parsedIntField))
    {
      throw new ArgumentException("Please provide a valid numerical string.", nameof(strToParse));
    }
  }
}
```
