---
title: "Squeeze Extra Performance out of .NET Core with String.Create()"
date: 2020-10-21
draft: true
author: "Casey McQuillan"
tags: [ "dotnet", "csharp", "performance" ]
description: ""
---

KEYWORDS TO INCLUDE:
===
dotnet performance
How can I speed up my .NET application
How can I make my C# code run faster
===

When was the last time that a seemingly insignificant detail sparked a movement in your brain? As a programmer, I have a habit of seeing new code and hyper-focusing on the one tiny detail I have never seen before. At that point, the gears in my brain begin turning, and the machinery spins up in a way I might not have experienced in weeks. I love these moments. The ones where the tiniest piece of trivia sends me down a rabbit-hole of discovery.

What did that look like the last time it came to you?

It recently happened to me as I was browsing Twitter. I came upon this exchange between David Fowler and Damian Edwards, discussing .NET 

{{< tweet 1318638349544873985 >}}

It's a small thing, the **String.Create** method used in the screenshot was something I had not seen before. I had learned about **Span** as an API, but had not noticed the **Create** gem before. The machinery in my brain asked the question:

> "Why use this method for creating string over others?"

This was my latest rabbit-hole, and it took me to a few interesting places that I would like to share with you. In this article we will delve into...

* What is **String.Create**?
* How is it different from normally constructing a string?
* What does it do better?
* How much faster is it **really**?
* What pitfalls should be avoided?

### Definitions

To make the article a little easier, I am going to refer to the various ways of creating strings in the following ways:

* **Create** - Refers to using `String.Create()`.
* **Concat** - Refers to using `String.Concat()` or the plus (`+`) operator.
* **Format** - Rerfers to using `String.Format()`, one of its many overloads, or to string interpolation with the `$""` syntax.
* **StringBuilder** - Refers to constructing a string with the fluent `StringBuilder` class and API.

### How Does It Work?

Let's take a deep dive into the `String` object in C#. Since the .NET Runtime is now open source and developed in the open, the code is [available on GitHub](https://github.com/dotnet/runtime/blob/master/src/libraries/System.Private.CoreLib/src/System/String.cs). `String` also has many partial classes spread across other files, but the code we need is in the primary **String.cs** location. 

To naively build a string out of bytes, you need to use the constructor that requires a [pointer to a character array](https://github.com/dotnet/runtime/blob/master/src/libraries/System.Private.CoreLib/src/System/String.cs#L57). Using this API directly would require placing bytes into specific indexed (`[]`) locations. Below is the code that runs when you allocate a string using this constructor. There are many other ways to create strings, but this is what I consider the most comparable to the **Create** method. 

```csharp {hl_lines=["6-11"],linenostart=57}
string Ctor(char[]? value)
{
    if (value == null || value.Length == 0)
        return Empty;

    string result = FastAllocateString(value.Length);

    Buffer.Memmove(
        elementCount: (uint)result.Length, // derefing Length now allows JIT to prove 'result' not null below
        destination: ref result._firstChar,
        source: ref MemoryMarshal.GetArrayDataReference(value));

    return result;
}
```

To summarize the important steps:
1) Inputs are validated. The invalid-array case returns `String.Empty`.
2) We allocate memory using `FastAllocateString` based on the array `Length`.
3) We call `Buffer.Memmove`, which copies all bytes from the original array into the new allocation.
4) Return the resulting `string`.

In order to use this constructor, we need to supply it with a `char` array. After its job is complete, we end up with a `char` array and a `string`, each with identical data. If we were to modify the original `char` array, then the `string` would remain unmodified, because it is a distinct copy of the memory. In a high-performance .NET environment, saving object and array allocations can be extremely valuable because it reduces the total amount of work that the .NET Garbage Collector needs to do whenever it runs.

To contrast, this is the code that runs Constructing a string using the **Create** method:

```csharp {hl_lines=["13-14"],linenostart=363}
public static string Create<TState>(int length, TState state, SpanAction<char, TState> action)
{
    if (action == null)
        throw new ArgumentNullException(nameof(action));

    if (length <= 0)
    {
        if (length == 0)
            return Empty;
        throw new ArgumentOutOfRangeException(nameof(length));
    }

    string result = FastAllocateString(length);
    action(new Span<char>(ref result.GetRawStringData(), length), state);

    return result;
}
```

The steps are similar but contain a critical difference:
1) Inputs are validated. Invalid `action` or negative `Length` will throw and `Length` of 0 returns Empty;
2) We allocate memory using `FastAllocateString` based on the `length` parameter.
3) Convert the newly-allocated `string` to a `Span<char>`.
4) Invoke the provided `action` and pass in the new `Span<char>` along with the provided `state`.
5) Return the resulting `string`.

***Make a graphic: Constructor version should show that it's taking an input, making a copy, and then giving back both the original and the copy. String.Create() version should show it it's creating something and delivering it.***

A good example would be in graphic design. Perhaps you designed your own logo in photoshop as a bitmap, but you decided that what you *really* needed was a vector image, so that you could scale it without degrading quality. You delivered your original logo to a graphic designer and they send back a logo in SVG format. At the end of the day, you still have your original bitmap, but you are unlikely to use it since you now have your logo in a more usable format. 

The process for `String.Create()` is closer to if you had started by reaching out to the designer, telling them *exactly* what you wanted from the beginning, and taking delivery of a usable SVG. You end up with only one artifact, and it happens to be in the form you need.

### Why is this useful

There are a few reasons why the 

1) It pre-allocates a bucket and gives you an interface to fill that bucket *safely*. Performing similar work at the same performance level would require writing your own `unsafe` code. Luckily, the .NET Core team has written that code for you.
2) It avoids extra copy-operations of your data. In some situations it may also avoid the extra string allocation.
3) It allows you to focus on the task at hand (building your desired string) rather than managing buffer pools in order to avoid the extra allocations. 

### Use Cases for String.Create()

You can only use the `String.Create()` method by providing a positive integer length. This piece of the method signature shows that it is only useful when you already know the length of your final string. However, by working within this constraint, we can discover a number of ways to leverage `String.Create()`. I also did a search through the codebases for dotnet/aspnetcore and dotnet/runtime to see where the Microsoft team decided to utilize the method. The rest of this article will dive deep on three trends that I found:
1) Generating IDs
2) Performance-Sensitive Concatenations
3) Formatting Complex Strings

#### Generating IDs

Consider this class from the ASP.NET Core repository used for generating correlation IDs on each web request. The format is 13 characters chosen from the numbers (0-9) and most upper-case letters (A-V). The algorithm is brief: 
1) Start your correlation ID at the latest tick count for UTC time. The tick count is a 64-bit integer.
2) Increment by one on each ID request.
3) For each of 13 characters:
    1) Shift the value by 5 additional bits.
    2) Grab the rightmost 5 bits (`& 31`) and choose a character based upon a predetermined table.

```csharp {hl_lines=["23-40"]}
// Copyright (c) .NET Foundation. All rights reserved.
// Licensed under the Apache License, Version 2.0. See License.txt in the project root for license information.

using System;
using System.Threading;

namespace Microsoft.AspNetCore.Connections
{
    internal static class CorrelationIdGenerator
    {
        // Base32 encoding - in ascii sort order for easy text based sorting
        private static readonly char[] s_encode32Chars = "0123456789ABCDEFGHIJKLMNOPQRSTUV".ToCharArray();

        // Seed the _lastConnectionId for this application instance with
        // the number of 100-nanosecond intervals that have elapsed since 12:00:00 midnight, January 1, 0001
        // for a roughly increasing _lastId over restarts
        private static long _lastId = DateTime.UtcNow.Ticks;

        public static string GetNextId() => GenerateId(Interlocked.Increment(ref _lastId));

        private static string GenerateId(long id)
        {
            return string.Create(13, id, (buffer, value) =>
            {
                char[] encode32Chars = s_encode32Chars;

                buffer[12] = encode32Chars[value & 31];
                buffer[11] = encode32Chars[(value >> 5) & 31];
                buffer[10] = encode32Chars[(value >> 10) & 31];
                buffer[9] = encode32Chars[(value >> 15) & 31];
                buffer[8] = encode32Chars[(value >> 20) & 31];
                buffer[7] = encode32Chars[(value >> 25) & 31];
                buffer[6] = encode32Chars[(value >> 30) & 31];
                buffer[5] = encode32Chars[(value >> 35) & 31];
                buffer[4] = encode32Chars[(value >> 40) & 31];
                buffer[3] = encode32Chars[(value >> 45) & 31];
                buffer[2] = encode32Chars[(value >> 50) & 31];
                buffer[1] = encode32Chars[(value >> 55) & 31];
                buffer[0] = encode32Chars[(value >> 60) & 31];
            });
        }
    }
}
```

For our baseline comparison, we will use a naive implementation that uses `StringBuilder`. I chose this option because `StringBuilder` is [often recommended](https://docs.microsoft.com/en-us/troubleshoot/dotnet/csharp/string-concatenation) as a best practice for performance over regular string concatenation. In the github repo for this post, there are also implementations using `StringBuilder` with a specified capacity and using `String.Concat()`. The GitHub code for each method is linked below.

* [StringCreate](https://www.google.com/)
* [StringConcatenation](https://www.google.com/)
* [StringBuilder](https://www.google.com/)
* [StringBuilderNoCapacity](https://www.google.com/)

|                  Method |      Mean |    Error |    StdDev |   StdErr | Ratio | RatioSD | Rank |
|------------------------ |----------:|---------:|----------:|---------:|------:|--------:|-----:|
|            StringCreate |  16.58 ns | 0.366 ns |  0.342 ns | 0.088 ns |  0.26 |    0.02 |    1 |
|           StringBuilder |  59.81 ns | 1.555 ns |  4.511 ns | 0.458 ns |  1.00 |    0.00 |    2 |
| StringBuilderNoCapacity |  64.04 ns | 2.426 ns |  7.077 ns | 0.715 ns |  1.08 |    0.15 |    3 |
|     StringConcatenation | 342.23 ns | 6.872 ns | 18.579 ns | 2.015 ns |  5.76 |    0.52 |    4 |

The `String.Create()` method shows the best performance in both speed (20 nanoseconds) and allocations (only 48 bytes!). Interestingly, the `StringBuilder` with no capacity specified also shows a small edge over the regular `StringBuilder` (it still loses to `String.Create()`, but that is interesting to note for future `StringBuilder` use). 

#### Performance-Sensitive Concatenation

The C# Roslyn compiler is very intelligent about optimizing poor concatenations. The compiler will tend to convert multiple uses of the plus `+` operator into singular calls to **Concat** and likely has many additional tricks. For these reasons, concatenation is generally a fast operation, but it still can be edged out by **Create** for simple scenarios.

The sample code to demonstrate concatenation with the **Create** method is relatively straightforward.

```csharp
public static class ConcatenationStringCreate
{
    public static string Concat(string first, string second)
    {
        first ??= string.Empty;
        int length = second != null ? first.Length + 1 + second.Length : first.Length;
        return string.Create(length, (first, second),
        (dst, v) =>
        {
            ReadOnlySpan<char> prefix = v.first;
            prefix.CopyTo(dst);

            if (v.second != null)
            {
                dst[prefix.Length] = ' ';

                ReadOnlySpan<char> detail = v.second;
                detail.CopyTo(dst.Slice(prefix.Length + 1, detail.Length));
            }
        });
    }
}
```

I crafted this particular case after finding only [one real example](https://github.com/dotnet/runtime/blob/a9b1173e64f628c7233850be6b762a58897bc6be/src/libraries/System.Diagnostics.TextWriterTraceListener/src/System/Diagnostics/XmlWriterTraceListener.cs) in the .NET Core source code. This feels like a case that could be reasonably abstracted and sprinkled throughout a codebase that is making excessive use of the plus `+` operator or `String.Concat` very frequently. The likely reason that I did not find more cases is that the benchmarks bear this out as being a marginal gain. 

|       Method |   FirstPart |          SecondPart |     Mean |    Error |   StdDev |   StdErr |   Median | Ratio | RatioSD | Rank |
|------------- |------------ |-------------------- |---------:|---------:|---------:|---------:|---------:|------:|--------:|-----:|
|       Create |           ? |                   ? | 54.84 ns | 2.361 ns | 3.534 ns | 0.645 ns | 53.77 ns |  0.87 |    0.08 |    1 |
|       Normal |           ? |                   ? | 63.69 ns | 3.825 ns | 5.726 ns | 1.045 ns | 63.50 ns |  1.00 |    0.00 |    2 |
|              |             |                     |          |          |          |          |          |       |         |      |
|       Create |           ? | Sedf(...)ctus [307] | 51.11 ns | 1.570 ns | 2.349 ns | 0.429 ns | 50.43 ns |  0.84 |    0.05 |    1 |
|       Normal |           ? | Sedf(...)ctus [307] | 61.08 ns | 2.601 ns | 3.893 ns | 0.711 ns | 60.38 ns |  1.00 |    0.00 |    2 |
|              |             |                     |          |          |          |          |          |       |         |      |
|       Create | Lorem Ipsum |                   ? | 55.88 ns | 4.070 ns | 6.092 ns | 1.112 ns | 52.59 ns |  0.95 |    0.09 |    1 |
|       Normal | Lorem Ipsum |                   ? | 58.66 ns | 1.005 ns | 1.505 ns | 0.275 ns | 58.44 ns |  1.00 |    0.00 |    2 |
|              |             |                     |          |          |          |          |          |       |         |      |
|       Create | Lorem Ipsum | Sedf(...)ctus [307] | 50.26 ns | 0.794 ns | 1.188 ns | 0.217 ns | 50.18 ns |  0.86 |    0.06 |    1 |
|       Normal | Lorem Ipsum | Sedf(...)ctus [307] | 59.04 ns | 3.779 ns | 5.656 ns | 1.033 ns | 57.72 ns |  1.00 |    0.00 |    2 |

These results are particularly interesting. Even for generalized **Concat** usage, the **Create** method is marginally faster by a few percentage points. Since it is possible to generalize a string concatenation, the tradeoff of maintenance vs performance becomes much cleaner. You could wrap all of your concatenation methods in a static class, add your unit tests, and never touch them again. From a maintenance perspective, **String.Concat** is still cleaner, and more recognizeable to other developers. However, if you are concatenating strings at the pace of millions per second, these few percentage points may be worth it.

#### Formatting of Complex Strings

Complex formats can also be built using **Create** when you know the length of all the string segments involved. Usually this will be when you have these strings encapsulated as properties of a single class or within the parameters of a single method. It may also be advantageous to use **Create** when dealing with rows of fixed-width or delimited data, such as a CSV file. 

I found a [great example](https://github.com/dotnet/aspnetcore/blob/8a81194f372fa6fe63ded2d932d379955854d080/src/Http/Headers/src/SetCookieHeaderValue.cs) in the ASP.NET Core repository in the form of the `SetCookieHeaderValue` class. This class contains all of the properties necessary to write out a cookie HTTP header. Conveniently, this class also included a method that used **StringBuilder** to accomplish the same formatting task. This gave me a great opportunity to develop a quick benchmark. 

Here is the table that shows the two methods up against one another:

|        Method |     Mean |    Error |   StdDev |  StdErr |   Median | Ratio | RatioSD | Rank |
|-------------- |---------:|---------:|---------:|--------:|---------:|------:|--------:|-----:|
|        Create | 538.5 ns | 10.80 ns | 30.99 ns | 3.18 ns | 528.7 ns |  0.67 |    0.05 |    1 |
| StringBuilder | 810.9 ns | 15.75 ns | 24.52 ns | 4.33 ns | 809.0 ns |  1.00 |    0.00 |    2 |

While the `SetCookieHeaderValue` class provides a very great data point, its logic is rather long and complex, so I have constructed a simpler class to demonstrate the same principles below.

```csharp
public class Dog
{
    public string Name { get; set; }

    public int? Age { get; set; }

    public string Color { get; set; }

    public override string ToString()
    {
        return StringCreate();
    }

    /// <summary>
    /// Format the description string of the Dog class using String.Create()
    /// </summary>
    public string StringCreate()
    {
        var length = 0;
        // Constants
        const string dogPrefix = "[DOG] ";
        const string unknownName = "Unknown";
        const string leftAgeChunk = " (";
        const char rightAgeChunk = ')';
        const string leftColorChunk = " [";
        const char rightColorChunk = ']';
        static int integerLength(int val) => (int)Math.Floor(Math.Log10((double)val) + 1);

        /* Compute Lengths */
        length += dogPrefix.Length + (Name ?? unknownName).Length; // Prefix + Name

        if (Color is string)
        {
            length += 3 /* left + right chunk length */ + Color.Length;
        }

        if (Age.HasValue)
        {
            length += 3 /* left + right chunk length */ + integerLength(Age.Value); /* Digits in age */
        }
        /* Use State + Computed Length to Build String */
        return String.Create<Dog>(length, this, (buffer, dog) =>
        {
            var prefixSpan = dogPrefix.AsSpan();
            prefixSpan.CopyTo(buffer);
            var span = buffer.Slice(prefixSpan.Length);

            var nameSpan = (dog.Name ?? unknownName).AsSpan();
            nameSpan.CopyTo(span);
            span = span.Slice(nameSpan.Length);

            if(dog.Color is string)
            {
                leftColorChunk.AsSpan().CopyTo(span);
                span = span.Slice(2);
                var colorSpan = dog.Color.AsSpan();
                colorSpan.CopyTo(span);
                span = span.Slice(colorSpan.Length);
                span[0] = rightColorChunk;
                span = span.Slice(1);
            }

            if(dog.Age.HasValue)
            {
                leftAgeChunk.AsSpan().CopyTo(span);
                span = span.Slice(2);
                dog.Age.Value.TryFormat(span, out int written, provider: CultureInfo.InvariantCulture);
                span = span.Slice(written);
                span[0] = rightAgeChunk;
            }
        });
    }

    /// <summary>
    /// Format the description string of the Dog class using basic concatenation.
    /// </summary>
    public string Concatenation() 
    {
        var val = "[DOG] " + (Name ?? "Unknown");

        if(Color is string)
        {
            val += " [" + Color + "]";
        }

        if(Age.HasValue)
        {
            val += " (" + Age.Value + ")";
        }

        return val;
    }

    /// <summary>
    /// Format the description string of the Dog class using String.Format()
    /// </summary>
    public string StringFormat()
    {
        return String.Format("[DOG] {0}{5}{4}{6}{2}{1}{3}",
            Name ?? "Unknown",
            Age,
            Age.HasValue ? " (" : String.Empty,
            Age.HasValue ? ")" : String.Empty,
            Color,
            Color is string ? " [" : String.Empty,
            Color is string ? "]" : String.Empty);
    }
}
```

The `Dog` class above contains three methods that should produce identical output: `StringCreate`, `Concatenation` and `StringFormat`. Each method uses a formatting strategy that matches its name. Despite being much more complex, the actual strategy of `StringCreate` is relatively simple:
1) Pre-emptively calculate the length of each property of the `Dog` class. Some properties may require some creative logic in order to calculate lenth without materializing the full string (`Int32` is a good example). 
2) Invoke `String.Create` using the current class (`this`) as the `state` parameter along with the pre-calculated length.
3) Use the `Span<T>` APIs to fill the newly instantiated `buffer` variable and return the final string.

Overall, it is easy to see that `StringFormat` and `Concatenation` are far shorter and less complex. This well exemplifies the difficulties one might have when properly formatting complex strings using `String.Create()` and why it is best to use only on hot paths in your own code. However, utilizing this method appropriately can pay dividends in overall performance.

|        Method |                  Dog |      Mean |    Error |    StdDev | Ratio | Rank |
|-------------- |--------------------- |----------:|---------:|----------:|------:|-----:|
|  StringCreate | [DOG] Fido (20) [23] |  68.73 ns | 1.218 ns |  1.017 ns |  0.18 |    1 |
| Concatenation | [DOG] Fido (20) [23] | 105.18 ns | 2.118 ns |  2.828 ns |  0.27 |    2 |
|  StringFormat | [DOG] Fido (20) [23] | 377.44 ns | 7.363 ns | 19.653 ns |  1.00 |    3 |
|               |                      |           |          |           |       |      |
| Concatenation |         [DOG] Fluffy |  18.60 ns | 0.451 ns |  0.901 ns |  0.06 |    1 |
|  StringCreate |         [DOG] Fluffy |  27.85 ns | 0.630 ns |  1.213 ns |  0.09 |    2 |
|  StringFormat |         [DOG] Fluffy | 295.93 ns | 5.952 ns |  9.440 ns |  1.00 |    3 |
|               |                      |           |          |           |       |      |
|  StringCreate | [DOG] Pluto [Yellow] |  37.60 ns | 0.835 ns |  1.325 ns |  0.12 |    1 |
| Concatenation | [DOG] Pluto [Yellow] |  51.16 ns | 1.437 ns |  4.213 ns |  0.16 |    2 |
|  StringFormat | [DOG] Pluto [Yellow] | 318.94 ns | 6.312 ns | 17.595 ns |  1.00 |    3 |

The benchmarks methods I chose show another reason to carefully consider this use case for the **Create** method. You can see that simple concatenation performs slightly better when we have very few operations to perform, but quickly becomes a worse option the more we have to concatenate. **Format** is consistently the slowest option, though is arguably the fastest method to write initially. 

It is also worth noting that these results almost runs counter to our separate concatenation benchmark above. We showed above that just concatenating two strings in marginally faster, so why doesn't the simplest cast for the `Dog` class run faster? In this case, the additional overhead of the string formatting method is adding up and overtaking the gains we made using by using **Create**. Checks for null can add up, especially because they are done twice (once when calculating length and once when building the full string). This overhead could be further optimized (potentially to the point that **Create** is always better for this `Dog` object), but that further emphasizes the point that this level of optimization is hard to do correctly.

### When NOT To Use String.Create()

**Create** shows great promise in performance-critical code, but there are many legitimate reasons to avoid it. As software engineers, we often become more tied to the metrics of our systems at the expense of the big picture. Generally, I think good maintenance should prevail over fantastic performance. That leads me to prescribe three general cases when you should avoid using **Create**, even if it sacrifices performance.

#### 1) Do Not Use When Readability is Important

Ultimately, this API is not maintenance-friendly. Your scenario should demand *very* high performance and your code should be well-factored with unit tests. There are many alternatives that are more readable:

* **Format** or **String Interpolation** when generating simple strings with dynamic values.
* **StringBuilder** when creating strings that require a loop.
* **Concat** or a simple `+` when you just need to combine a small number of strings.

#### 2) Do Not Use When Culture is Important

**Format**, **String Interpolation**, and most `ToString()` methods respect cultural formatting options. This gives your code the crucial ability to adapt to culture-specific date, numeral, and other formats without having to provide that complex logic yourself. **Create** does not offer any support for these APIs on its own, and attempting to mimic the behavior in your own code would often require allocating additional strings anyway, thus defeating the purpose of using **Create**.

#### 3) (Probably) Do Not Use When the Output is for Humans

This situation is a bit subjective. The reason I would not recommend using **Create** for human-readable formatting is because humans **tend to want things to change**. Since formatting using the **Create** method is extremely verbose, any changes are likely to cause increases in complexity, and thereby generate technical debt. In my opinion, the best usage of **Create** is on machine-readable strings or more generalized string-writing APIs (such as **String.Format**) that are unlikely to change in the future. As is often the case in software development, the specifics of your situation are the most important, but I think is a good general rule to avoid this for any code you anticipate modifying frequently in the future.

### Conclusion


