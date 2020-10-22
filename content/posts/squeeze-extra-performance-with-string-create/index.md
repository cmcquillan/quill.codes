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

Have you ever seen something insignificant that sparked a movement in your brain? The tiniest piece of trivia that sends you down a rabbit-hole of discovery?

When you came out. Did what did it look like? 

Often, it doesn't look like what you expected, but might still shine some light on a subject you want to learn more about.

### Inspiration

It happened for me when I saw this Tweet Exchange between David Fowler and Damien Edwards. 

{{< tweet 1318638349544873985 >}}

It's a small thing, and you may not have known about it previously, but the `String.Create()` method used in Damien's tweet made me think.

> "Why use this method for creating string over others?"

### How Does It Work?

Let's take a deep dive into the `String` object in C#. Since the .NET Runtime is now open source and developed in the open, the code is available on GitHub(link this). 

Building a string from the constructor requires a [pointer to a character array](https://github.com/dotnet/runtime/blob/master/src/libraries/System.Private.CoreLib/src/System/String.cs#L57). 


Constructing a string using `String.Create()` 

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


Constructing a string normally

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

***Make a graphic: Constructor version should show that it's taking an input, making a copy, and then giving back both the original and the copy. String.Create() version should show it it's creating something and delivering it.***

A good example would be in graphic design. Perhaps you designed your own logo in photoshop as a bitmap, but you decided that what you *really* needed was a vector image, so that you could scale it without degrading quality. You delivered your original logo to a graphic designer and they send back a logo in SVG format. At the end of the day, you still have your original bitmap, but you are unlikely to use it since you now have your logo in a more usable format. 

The process for `String.Create()` is closer to if you had started by reaching out to the designer, telling them *exactly* what you wanted from the beginning, and taking delivery of a usable SVG. You end up with only one artifact, and it happens to be in the form you need.

### Why is this useful

1) It pre-allocates a bucket and gives you an interface to fill that bucket *safely*.
2) It avoids extra copy-operations of data. In some situations it may also avoid the extra string allocation.
3) It allows you to focus on the task at hand (building your desired string) rather than managing buffer pools in order to avoid the extra allocations. 

### Use Cases for String.Create()

Ultimately, `String.Create()` is at its most useful when you already know the length of your string. Within this one restriction

#### Generating IDs

Consider this class from the ASP.NET Core repository:

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

#### Performance-Sensitive Concatenation



#### Formatting of Complex Strings

### When NOT To Use String.Create()

* When readability is important. Ultimately, this API is not maintenance-friendly. Your scenario really should demand screaming performance and your code should be well-factored with unit tests.
* 

### Conclusion


