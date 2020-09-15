---
title: "Practical Objects: A Beginning Approach to Object Oriented Design"
date: 2020-08-09
draft: false
author: "Casey McQuillan"
description: "The first entry in a series where share strategies for Object Oriented Design in a practical way that considers time, resources, and maintainability."
---

## The Goal of Practical Objects

**I *love* programming, but programming is hard and existing paradigms that inflexibly insist upon perfection do not make it easier.** This is not to say that paradigms and patterns produce bad code, but certain statements from peers, thought leaders, and friends permeate the space in my head when attempting to solve problems.

* "This approach is better because it runs faster"
* "This code violates SOLID"
* "We should roll our own library instead of using this framework"

I took these statements to heart. I over-analyzed, I created problems to solve where none had previously existed, I anticipated issues rather than solving the ones at hand. I think the goal I had was controlling complexity, but many times the complexity created just by by adhering to "best practices" grew out of control. We have a tendency to think of our classes as little gardens. We sprinkle design patterns throughout our code as if words like *Decorator*, *Factory*, and *Flyweight* because we want the satisfaction of seeing those words the next time we open the editor and not because they actually solved a problem.

I love design patterns. They can solve many problems, but they do add complexity and keeping away from that complexity is the focus of this series. I want to express my thoughts on preventing complexity and introducing it *slowly*. Don't worry, we will write plenty of code along the way. This is a journey into the practical usage of objects and how to use them to solve problems productively.

## What You Need for This Article

Unfortunately, this is not a "beginning C#" article. Fundamentally, I am hoping you already understand the C# programming language (or at least a language with classes, so that you follow the general outline of the code being written). So to understand this material you should probably have at least some familiarity with:

* The C# Programming Language
* A code editor or IDE
* The `dotnet` command line tools

## Let's Talk about Sudoku

<figure>
<svg width="297" height="297">
  <style>
    .number { font-size: 16px; }
  </style>
  <rect x="0" y="0" width="297" height="297" style="fill:white; stroke:black; stroke-width:4;" />
  <line x1="33" y1="0" x2="33" y2="297" style="stroke:black;stroke-width: 2;" /> 
  <line x1="66" y1="0" x2="66" y2="297" style="stroke:black;stroke-width: 2;" /> 
  <line x1="99" y1="0" x2="99" y2="297" style="stroke:black;stroke-width: 4;" /> 
  <line x1="132" y1="0" x2="132" y2="297" style="stroke:black;stroke-width: 2;" /> 
  <line x1="165" y1="0" x2="165" y2="297" style="stroke:black;stroke-width: 2;" /> 
  <line x1="198" y1="0" x2="198" y2="297" style="stroke:black;stroke-width: 4;" /> 
  <line x1="231" y1="0" x2="231" y2="297" style="stroke:black;stroke-width: 2;" /> 
  <line x1="264" y1="0" x2="264" y2="297" style="stroke:black;stroke-width: 2;" /> 
  <line x1="0" y1="33" x2="297" y2="33" style="stroke:black;stroke-width: 2;" /> 
  <line x1="0" y1="66" x2="297" y2="66" style="stroke:black;stroke-width: 2;" /> 
  <line x1="0" y1="99" x2="297" y2="99" style="stroke:black;stroke-width: 4;" /> 
  <line x1="0" y1="132" x2="297" y2="132" style="stroke:black;stroke-width: 2;" /> 
  <line x1="0" y1="165" x2="297" y2="165" style="stroke:black;stroke-width: 2;" /> 
  <line x1="0" y1="198" x2="297" y2="198" style="stroke:black;stroke-width: 4;" /> 
  <line x1="0" y1="231" x2="297" y2="231" style="stroke:black;stroke-width: 2;" /> 
  <line x1="0" y1="264" x2="297" y2="264" style="stroke:black;stroke-width: 2;" />
  <text x="47" y="22" fill="black" class="number">9</text>
  <text x="47" y="55" fill="black" class="number">5</text>
  <text x="80" y="22" fill="black" class="number">6</text>
  <text x="80" y="55" fill="black" class="number">3</text>
  <text x="113" y="55" fill="black" class="number">2</text>
  <text x="179" y="55" fill="black" class="number">4</text>
  <text x="212" y="55" fill="black" class="number">9</text>
  <text x="278" y="55" fill="black" class="number">6</text>
  <text x="14" y="88" fill="black" class="number">2</text>
  <text x="146" y="88" fill="black" class="number">9</text>
  <text x="80" y="121" fill="black" class="number">1</text>
  <text x="245" y="121" fill="black" class="number">9</text>
  <text x="80" y="154" fill="black" class="number">7</text>
  <text x="113" y="154" fill="black" class="number">5</text>
  <text x="14" y="187" fill="black" class="number">6</text>
  <text x="113" y="187" fill="black" class="number">8</text>
  <text x="146" y="187" fill="black" class="number">3</text>
  <text x="212" y="187" fill="black" class="number">5</text>
  <text x="47" y="220" fill="black" class="number">7</text>
  <text x="113" y="220" fill="black" class="number">9</text>
  <text x="212" y="220" fill="black" class="number">6</text>
  <text x="14" y="253" fill="black" class="number">1</text>
  <text x="47" y="253" fill="black" class="number">8</text>
  <text x="146" y="253" fill="black" class="number">6</text>
  <text x="245" y="253" fill="black" class="number">4</text>
  <text x="113" y="286" fill="black" class="number">4</text>
  <text x="146" y="286" fill="black" class="number">1</text>
  <text x="212" y="286" fill="black" class="number">7</text>
  <text x="245" y="286" fill="black" class="number">3</text>
  <text x="278" y="286" fill="black" class="number">8</text>
</svg>
<figcaption>An example Sudoku puzzle.</figcaption>
</figure>

To introduce the concepts in this series of articles, we are going to focus on the Sudoku puzzle game. If you haven't seen Sudoku before, the basic premise is that you are given a 9x9 grid. This grid can be viewed as 9 independent rows, 9 independent columns, and 9 independent 3x3 squares. The goal of Sudoku is to fill out each of these independent items with the numbers 1 through 9. If you use the same number twice in one of these places (rows, columns, squares), then the puzzle is invalid. 

We use Sudoku for a few reasons:

1. It's a well-explored problem. There is a ton of theory as well as a lot of concrete detail on how Sudoku works. This means that you can take any lesson I give you here and go deeper into the subject without me. 
2. Sudoku as a game has a surprising amount of use cases. This means that we can explore validating puzzles, solving puzzles, creating new puzzles, creative presentations, and much more.
3. Fundamentally, the representation is simple (it's just 81 numbers in a box), so we can start off with something trivial and introduce new abstractions as the problem becomes more complex.

## Today's Problem: Validating a Puzzle

Imagine you work a small publisher, potentially a newspaper that has daily circulation. Your job title is **Web Developer** but since you know how computers work, you often get these one-off projects from other departments. Usually they involve rebooting computers or writing excel formulas, but one morning you receive this email from your manager.

*Hey Quill, the editor for our daily puzzle section has a project for you. I think you might find this one interesting! He gets Sudoku puzzles from a contractor every day and they frequently have mistakes. Can you write him a quick utility so that he can double-check that it's a valid puzzle? The puzzles are really important to our readers, so can you cook something up by the end of the day?*

We do not find this interesting. But we're scrappy! We will take opportunity to uncover a challenge.

However, we also have to figure out why the website keeps crashing so this problem needs to be *off our plate*. Also, part of the problem being solved is that the editor is already fed up with mistakes in his puzzles. This means we need to put as much effort as possible into getting the answer right. This gives us two priorities:

* Development Speed
* Correctness

We may briefly think that these two are at odds, but with a little thought to our process and by leveraging objects appropriately, we can achieve both.

## The Decision to Use Objects

If our primary concerns are speed and correctness, then we have basically decided that the overall quality of the code is either less important. However, we also want it to be *correct*, so a great way to achieve that is to write preliminary tests relatively early on in the process. This may sound like more work overall, but it will save us time with a well-understood problem like Sudoku. Remember, this is about achieving two challenging goals at once and providing the requested business value (you know, the reason you're paid to write code) on time. Let's go over the benefits of using an object as an abstraction.

### Objects shield *our* problems from *our user's* problems

Our current task is to solve a business problem for our editor. To do this we need to give them a solution that removes as much mental overhead as possible. Fundamentally, this is the purpose of an interface. Keep in mind I am not talking about the concept of a C# interface, but simply the idea of creating a set of commands that allow our user (the editor in this case) to focus on the problem they want to solve and not on the details of how we are assisting them. We then take the data this interface provides us and use that to more narrowly define our own business problem. In doing this, we shrink the problem for our user down to a manageable piece and give ourselves a well-defined space to work in.

```csharp
public class Sudoku
{
    public Sudoku(int[] puzzleInitializer)
    {
    }

    public bool Check()
    {
        throw new NotImplementedException();
    }
}
```

When we examine the problem given to us above, it really doesn't have to be anymore complicated than this. We create a **Sudoku** class, tell our consumer that they need to provide us a list of integers that represent the puzzle, and then provide a simple method (Check) to evaluate whether our puzzle is valid. Whoever consumes this object has to know two things:

1. How to instantiate a Sudoku class
2. What is means for a call to Check() to return true or false.

> *Note: Now, realistically, *we* are still the consumers of this object, because we're obviously not going to hand our user a C# class and a pat on the back, but User Interface will be a subject of a future blog post* 😁

### Objects hide the details until we need them
	
Now that we have a way to tell our user what we need and what we will give back to them, we need to actually solve our own problem, which is validating a Sudoku puzzle. At this point, our primary concern is speed, so we will take a naive approach and simply copy the list of numbers to an internal representation. We might also validate the numbers *just a little* to ensure that nothing unexpected is entering our puzzle's problem space.

```csharp
public class Sudoku
{
    /*
        *      Cols
        *        1  2  3  4  5  6  7  8  9
        * Rows +--------------------------+
        *   1  | 0| 1| 2| 3| 4| 5| 6| 7| 8|
        *   2  | 9|10|11|12|13|14|15|16|17|
        *   3  |18|19|20|21|22|23|24|25|26|
        *   4  |27|28|29|30|31|32|33|34|35|
        *   5  |36|37|38|39|40|41|42|43|44|
        *   6  |45|46|47|48|49|50|51|52|52|
        *   7  |54|55|56|57|58|59|60|61|62|
        *   8  |63|64|65|66|67|68|69|70|71|
        *   9  |72|73|74|75|76|77|78|79|80|
        *      +--------------------------+
        * 
        * Represents the numbers in the puzzle.
        * We will use 0 to denote an unfilled spot.
        */
    public readonly int[] _puzzle = new int[81];

    public Sudoku(int[] puzzleInitializer)
    {
        if (puzzleInitializer.Length < _puzzle.Length)
            throw new ArgumentException("Not enough spaces to initialize the puzzle.", nameof(puzzleInitializer));

        for (int i = 0; i < _puzzle.Length; i++)
        {
            if (puzzleInitializer[i] > 9 || puzzleInitializer[i] < 0)
                throw new ArgumentException("All numbers must be be 0 (no entry), or 1 thru 9.");

            _puzzle[i] = puzzleInitializer[i];
        }
    }

// ...
```

What did we gain by writing code this way?  We allowed ourselves to take a naive approach and just use an array. We could have used multi-dimensional array or a jagged array and stored our numbers in a structure that more closely matched a grid. However, we fundamentally just wanted our user to enter a list of numbers, so any internal representation that deviated from that would have to be translated, meaning we would spend more time on the constructor and not on the problem before us. This might have been a more maintainable approach in the long-term, but this was a trade-off we made in the interest of time. This is probably the most relevant lesson I am hoping to impart with this series. I want to teach you strategies to evaluate these trade-offs with confidence. 

*It's also important to note that "more maintainable" is a very subjective measure. You could just as easily find a flat array to be the most naive approach depending upon your skill-set and abstract thinking skills. The most important thing to note here is that this approach afforded us the luxury of writing something that **we** could reason about **fast***. 

### Objects enable testing our solution efficiently

A lot of this boils down to our ability to focus on a given problem and handle it with minimal distraction. Fundamentally, the last piece we need in order to free us from distractions is a process that allows us to write code, get fast feedback, and understand what is going wrong. For an object-oriented approach, few things accomplish this like a unit test. It may sound counterintuitive to spend more time writing code to just test our existing code, but this is where the developer tools can be used to speed up our process. And realistically, you are going to test your code on a valid puzzle anyway, so writing code to repeat that test forever will eventually save you more time than it uses.

```csharp
public static class ValidPuzzles
{
    public static int[] Puzzle1 = new int[]
    {
        4, 3, 5, 2, 6, 9, 7, 8, 1,
        6, 8, 2, 5, 7, 1, 4, 9, 3,
        1, 9, 7, 8, 3, 4, 5, 6, 2,

        8, 2, 6, 1, 9, 5, 3, 4, 7,
        3, 7, 4, 6, 8, 2, 9, 1, 5,
        9, 5, 1, 7, 4, 3, 6, 2, 8,

        5, 1, 9, 3, 2, 6, 8, 7, 4,
        2, 4, 8, 9, 5, 7, 1, 3, 6,
        7, 6, 3, 4, 1, 8, 2, 5, 9
    };

    public static int[] PartiallyFinished1 = new int[]
    {
        4, 3, 0, 2, 6, 0, 7, 8, 1,
        6, 8, 2, 5, 7, 1, 4, 9, 3,
        1, 9, 0, 0, 0, 4, 5, 0, 2,

        0, 2, 6, 1, 9, 5, 3, 4, 7,
        3, 0, 4, 6, 0, 2, 0, 1, 5,
        9, 5, 0, 7, 4, 3, 6, 2, 8,

        5, 1, 9, 3, 0, 6, 8, 7, 4,
        2, 0, 8, 9, 0, 0, 1, 0, 6,
        7, 6, 3, 4, 0, 0, 2, 5, 9
    };
}

public class SudokuTests
{
    [Fact]
    public void Sudoku_Check_ValidPartiallyFinishedPuzzlesShouldCheckAsTrue()
    {
        // Arrange
        var puzzle = new Sudoku(ValidPuzzles.PartiallyFinished1);

        // Act
        var result = puzzle.Check();

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void Sudoku_Check_ValidPuzzlesShouldCheckAsTrue()
    {
        // Arrange
        var puzzle = new Sudoku(ValidPuzzles.Puzzle1);

        // Act
        var result = puzzle.Check();

        // Assert
        Assert.True(result);
    }
}
```

I ended up writing more tests overall, but I felt comfortable starting with just two. The goal is to write and tweak code until these pass. The real power comes from just running these tests live. If you use the `dotnet` command line tools, this is simple.

```powershell
❯ dotnet watch -p .\QuillGames.sln test
watch : Started
  Determining projects to restore...
  All projects are up-to-date for restore.
Microsoft (R) Test Execution Command Line Tool Version 16.7.0
Copyright (c) Microsoft Corporation.  All rights reserved.

Starting test execution, please wait...

A total of 1 test files matched the specified pattern.

Test Run Successful.
Total tests: 2
     Passed: 2
 Total time: 1.0838 Seconds
watch : Exited
watch : Waiting for a file to change before restarting dotnet...
```

It's that last line that is most important: `Waiting for a file to change before restarting dotnet...`. This allows us to make changes quickly, save a file, and see if our changed worked right in the console. At this point, just line up your console window next to your text editor, and refactor your way to glory. If you run into a problem or find yourself stuck, you can always run your code in a debugger and step through slowly, but this is great when you generally know what you need to write and just want confirmation that your work is complete.

## Now for the Big Finish

By this point, it should be apparent that the actual code for the Sudoku puzzle solver is not really the point of this post, but it would also be incomplete without it. If you are interested in practicing the approach I've outlined, then I would encourage you to set up a project and write your own naive approach. Give yourself a time limit if you want a challenge. I will include the code for the Sudoku checker class below, and if you would like to peruse the whole solution, you can check out [this Github link](https://github.com/cmcquillan/QuillGames/tree/lesson-1.1-sudoku-checker). 

```csharp
using System;
using System.Collections;
using System.Linq;
using System.Runtime.CompilerServices;

namespace QuillGames.Sudoku
{
    public class Sudoku
    {
        /*
         *      Cols
         *        1  2  3  4  5  6  7  8  9
         * Rows +--------------------------+
         *   1  | 0| 1| 2| 3| 4| 5| 6| 7| 8|
         *   2  | 9|10|11|12|13|14|15|16|17|
         *   3  |18|19|20|21|22|23|24|25|26|
         *   4  |27|28|29|30|31|32|33|34|35|
         *   5  |36|37|38|39|40|41|42|43|44|
         *   6  |45|46|47|48|49|50|51|52|52|
         *   7  |54|55|56|57|58|59|60|61|62|
         *   8  |63|64|65|66|67|68|69|70|71|
         *   9  |72|73|74|75|76|77|78|79|80|
         *      +--------------------------+
         * 
         * Represents the numbers in the puzzle.
         * We will use 0 to denote an unfilled spot.
         */
        public readonly int[] _puzzle = new int[81];

        public Sudoku(int[] puzzleInitializer)
        {
            if (puzzleInitializer.Length < _puzzle.Length)
                throw new ArgumentException("Not enough spaces to initialize the puzzle.", nameof(puzzleInitializer));

            for (int i = 0; i < _puzzle.Length; i++)
            {
                if (puzzleInitializer[i] > 9 || puzzleInitializer[i] < 0)
                    throw new ArgumentException("All numbers must be be 0 (no entry), or 1 thru 9.");

                _puzzle[i] = puzzleInitializer[i];
            }
        }

        public bool Check()
        {
            bool IsValid(int[] numbers)
            {
                var count = numbers.Where(p => p != 0).Count();
                var distinct = numbers.Where(p => p != 0).Distinct().Count();

                return distinct == count;
            };

            // Assume valid until we see a bad row, col, or square.
            bool valid = true;
            int ix = 0;
            do
            {
                // Row
                valid = valid && IsValid(GetRow(ix + 1));

                // Col
                valid = valid && IsValid(GetCol(ix + 1));

                // Square
                valid = valid && IsValid(GetSquare(ix + 1));

                ix++;
            } while (valid && ix < 9);

            return valid;
        }

        /// <summary>
        /// Gets a single cell from the puzzle. Rows and columns are indexed starting at 1.
        /// </summary>
        /// <remarks>
        /// Every access to a number should go through this method. If we follow
        /// this rule, then changing the way that the puzzle is 'backed' (such as 
        /// from a single array to a multi-dimensional), would only require changing
        /// this method.
        /// </remarks>
        /// <returns>The number at the cell.</returns>
        public int GetCell(int row, int col)
        {
            int r = row - 1, c = col - 1;
            return _puzzle[(r * 9) + c];
        }

        /// <summary>
        /// Gets a single row from the puzzle. Rows are indexed starting at 1.
        /// </summary>
        /// <returns>A sequence of integers in the row.</returns>
        public int[] GetRow(int row)
        {
            int[] rowNumbers = new int[9];
            for (int i = 0; i < rowNumbers.Length; i++)
            {
                rowNumbers[i] = GetCell(row, i + 1);
            }

            return rowNumbers;
        }

        /// <summary>
        /// Gets a single column from the puzzle. Columns are indexed starting at 1.
        /// </summary>
        /// <returns>A sequence of integers in the column.</returns>
        public int[] GetCol(int col)
        {
            int[] colNumbers = new int[9];
            for (int i = 0; i < colNumbers.Length; i++)
            {
                colNumbers[i] = GetCell(i + 1, col);
            }

            return colNumbers;
        }

        /// <summary>
        /// Gets a single square from the puzzle. Squares are indexed starting at 1.
        /// </summary>
        /// <returns>A sequence of integers in the square.</returns>
        public int[] GetSquare(int square)
        {
            int[] squareNumbers = new int[9];
            int rowOffset = ((square - 1) % 3 * 3) + 1;
            int colOffset = ((square - 1) % 3 * 3) + 1;

            int ix = 0;
            for (int row = 0; row < 3; row++)
            {
                for (int col = 0; col < 3; col++)
                {
                    squareNumbers[ix] = GetCell(row + rowOffset, col + colOffset);
                    ix++;
                }
            }

            return squareNumbers;
        }
    }
}
```

## What's Next
Right now, my goal is that this series continues and helps outline my strategies for making practical trade-offs with object oriented programming. Some other topics I'll approach in the future are:

* Refactoring for maintainability
* Refactoring for performance
* Extending your objects with more features
* Extending the configurability of your objects

If you enjoyed this, or if there is something you wanted to see in the future, feel free to reach out on [Twitter](https://twitter.com/QuillCodes).