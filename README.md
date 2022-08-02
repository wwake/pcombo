# pcombo

This package is designed for parsing using parser combinators (top-down with backtracking).

## Parser Structures
Input = input to parser eg Character or Token

Target = result type of parser

The failure response has a location and a message string.

```
public enum ParseResult<Input, Target> {
  case success(Target, ArraySlice<Input>)
  case failure(Int, String)
}
```

```public protocol Parser {
  associatedtype Input
  associatedtype Target
  func parse(_: ArraySlice<Input>) -> ParseResult<Input, Target>
}
```

## Basic Parsers
`satisfy { closure over $0 }` - the closure is evaluated as a boolean and tells whether the first element of input succeeds

`satisfy("message") {closure over $0 }` - you may optionally specify an error message. Default is "Did not find expected value"

## Combinators

### Alternatives
`<|>` - **Alternative** - addition precedence - `p1 <|> p2` succeeds if either parser succeeds. On failure, returns the failure that got the farthest.

`<%>` - **Name** - addition precedence - `p1 <%> "message"` - uses the result of p1 if it succeeds or makes any progress, or a failure with the specified message if it makes no progress.

### Sequences
`<&>` - **Sequence** - multiplication precedence - `p1 <&> p2`

* For all variations, on failure it reports the point where it failed to find an acceptable value.
* If p1 and p2 have the same target type, returns an array of results.
* If p1 is of a type, and p2 is an array of that type, returns an array of results.
* If p2 is of a type, and p1 is an array of that type, returns an array of results. 
* If p1 and p2 have different target types, returns a tuple of the two results.

`<&` - Left child of sequence - both parsers must succeed, but only returns the result of the first one

`&>` - Right child of sequence - both parsers must succeed, but only returns the result of the second one

### Optional
`<?>` - **Optional - 0 or 1** - succeeds whether or not the parser does; returns the parser's value or nil

### Repetition
`<*>` - **Many (0 or more)** - prefix operator - `<*>p` returns an array of 0 or more values. (It can't return failure.)

`<+>` - **Many1 (1 or more)** - prefix operator - `<+>p` returns an array of 1 or values if the parse succeeds at least once, else returns failure 

`<&&>` - A <&&> B = A <&> <*>(B <&> A) - return tuples or arrays depending on whether types match

`<&&` - A <&& B = A <&> <*>(B &> A) - matches as <&&> but ignores the B results and returns [A]

### Transformation
`|>` - **Pipe** - multiplication precedence - `parser |> function` runs the parser. If it succeeds, it transforms the result via the function; if it fails, it returns failure. 


### Specialized
`peek(parser)` - **Peek** - runs the parser. If it fails, return failure. If it succeeds, return (0, input) ie untouched input. This lets you fail early rather than go down a long but incorrect path.

`Bind()` - **Bind** - allows you to wrap a parsing function so that you can define recursive parsers, or use parsers with non-standard names.

Example:
```
    let one = satisfy { $0 == 1 } |> { [ $0 ]}
    let two = satisfy { $0 == 2 }

    let expr = Bind<Int, [Int]>()
    let parser = one <|> two <&> expr
    expr.bind(parser.parse)

    let result = expr.parse([2,2,1,9])

    checkSuccess(result, [2,2,1], [9])
```

`<&|` - **Check** -  parser <&| function - if the parser fails, return the failure. If it succeeds, run the check function. If that returns nil, there was no problem, so return the parse result. If not nil, it returns a location and message, used to return .failure. 

```
  func sumShouldBeEven(_ values: [Int]) -> (Int, String)? {
    let sum = values.reduce(0, +)
    if sum.isMultiple(of: 2) { return nil }
    return (values.count, "sum was odd")
  }

  func testReturnsParseResultWhenCheckSucceeds() {
    let one = satisfy { $0 == 1 }
    let parser = <+>one <&| sumShouldBeEven
    let result = parser.parse([1,1,1,1,2])
    checkSuccess(result, [1,1,1,1], [2])
  }
``` 
