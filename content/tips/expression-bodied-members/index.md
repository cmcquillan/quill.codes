---
title: "Simplify C# with Expression-Bodied Members"
date: 2020-10-15T14:39:57-07:00
author: "Casey McQuillan"
tags: ["CSharp", "Dotnet", "Syntax Tips"]
draft: false
---

## You Can Simplify Your Syntax

C# is a fantastic language because it constantly evolves in a way that simplifies syntax and makes the your code more expressive. Expression-bodied members were released in C# 6 and further enhanced in C# 7. At the time I was still a junior developer and had not yet decided that C# and .NET were going to be my long-term focus. 

I am not going to say that this feature "sealed the deal" for me and .NET, but it's definitely the feature I miss most when using any other language.

### Simple Expression-bodied Members

The simplest form is just to take any existing read-only property and condense it down.

```csharp
public int MyProperty
{
  get 
  {
    return _myField;
  }
}
```

This becomes:

```csharp
public int MyProperty => _myField;
```

You can even use it for simple method bodies:

```csharp
public decimal CalculateTax(decimal rate) => _totalPrice * rate;
```

It saves you time, and it saves you space on your screen. Most C# style conventions say that the opening bracket `{` and closing bracket `}` belong on new lines (with some exceptions). You could argue with the style guide, but on a larger team that is probably a losing battle. This feature solves this problem by omitting the brackets entirely.

### Expression-bodied Members Can Help Reduce Boilerplate

Not impressed yet? What if I told you that you can use expression-bodied members on full properties?

```csharp
private int _myField;

public int MyProperty 
{
  get => _myField; 
  set => _myField = value;  
}
```

That is pretty nifty, but honestly not impressive unless you have logic to call on your getter/setter. 

```csharp
private int _myField;

private void SetField(ref int field, int value, [CallerMemberName]string memberName =  "")
{
  field = value;
  Console.WriteLine($"{memberName} was set to {value}.");
}

public int MyProperty
{
  get => _myField;
  set => SetField(ref _myField, value);
}

// Output for "MyProperty = 5"
// MyProperty was set to 5.
```

### Expression-Bodied Members Can be Used in Constructors

The most repetive boilerplate you tend to get with C# is setting class fields in constructors.

```csharp
public class Cake
{
  private readonly IFrosting _frosting;

  public Cake(IFrosting frosting) => _frosting = frosting;
}
```

This simplifies your single-assignment constructors greatly. However, you can also combine this with tuple syntax in order to perform multiple assignments at once.

```csharp
public class Cake
{
  private readonly ISprinkles _sprinkles;
  private readonly IFrosting _frosting;

  public Cake(ISprinkles sprinkles, IFrosting frosting)
    => (_sprinkles, _frosting) = (sprinkles, frosting);
}
```

This syntax will assign the fields in the order that they appear in the tuple. 

*Note: Keep in mind that if your parameters are all of similar types, like `string`, that getting them in the wrong order can be easy using this syntax. However, fields of different types will be caught by the compiles. Thus, I would only recommend it when assigning a set of varied fields.*

Hope you enjoyed this quick overview of one of my favorite features of C#!