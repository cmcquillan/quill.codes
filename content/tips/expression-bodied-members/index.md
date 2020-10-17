---
title: "Simplify C# with Expression-Bodied Members"
description: "Expression-bodied members are a fantastic feature of the C# language that simplifies and condenses your code."
date: 2020-10-15T14:39:57-07:00
author: "Casey McQuillan"
tags: ["CSharp", "Dotnet", "Syntax Tips"]
draft: false
---

## You Can Simplify Your Syntax With Effective Application of These Techniques

C# is a fantastic language because it constantly evolves in a way that simplifies syntax and makes the your code more expressive. Expression-bodied members were released in C# 6 and further enhanced in C# 7. At the time I was still a junior developer and had not yet decided that C# and .NET were going to be my long-term focus. 

I am not going to say that this feature "sealed the deal" for me and .NET, but it's definitely the feature I miss most when using any other language.

### Basics of Expression-bodied Members

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

When converted to an expression-bodied member this becomes:

```csharp
public int MyProperty => _myField;
```

You can even use it to simplify method bodies:

```csharp
public decimal CalculateTax(decimal rate) => _totalPrice * rate;
```

It saves you time, and it saves you space on your screen. Most C# style conventions say that the opening bracket `{` and closing bracket `}` belong on new lines (with some exceptions). You could argue with the style guide, but on a larger team that is probably a losing battle. This feature solves this problem by omitting the brackets entirely.

### Expression-bodied Members Can Reduce Boilerplate

Not impressed yet? What if I told you that you can use expression-bodied members on full properties? This means that you can use this technique for both a getter and setter to reduce the clutter associated with a fully-implemented C# property.

```csharp
private int _myField;

public int MyProperty 
{
  get => _myField; 
  set => _myField = value;  
}
```

That is a bit more efficient when reading your code, but honestly it is not *that* impressive until you have some more logic to call on your getter/setter. Extracting that logic to a method and using a `ref` parameter for your field can help clarify how your code functions.

```csharp
private int _myField;

public int MyProperty
{
  get => _myField;
  set => SetAndLogField(ref _myField, value);
}

private void SetAndLogField(ref int field, int value, [CallerMemberName]string memberName =  "")
{
  field = value;
  Console.WriteLine($"{memberName} was set to {value}.");
}

// Output for "MyProperty = 5"
// MyProperty was set to 5.
```

### Expression-Bodied Members Can be Used in Constructors

The most repetive boilerplate I see in my own C# code is when I am setting class fields in constructors. It accomplishes the critical task of initializing the object, but if someone is focused on making *simple* and *legible* objects with clear APIs, then the task often becomes repetive. 

When there is just a single assignment, expression-bodied members are extremely consise:

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

*Note: Keep in mind that if your parameters are all of similar types, like `string`, that getting them in the wrong order can be easy using this syntax. However, fields of different types will be caught by the compiles. Thus, I would only recommend it when assigning simple constructors with varied types for fields.*

### In Conclusion

I hope you enjoyed this quick overview of one of my favorite features of the C# language. This language feature can be used to improve readability, identify areas for logic encapsulation, and to simplify rote object construction. As C# continues to evolve, there are likely to be other improvements that enhance the expressiveness and overall cleanliness of the language.