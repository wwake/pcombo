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

##Basic Parsers
`satisfy { closure over $0 }` - the closure is evaluated as a boolean and tells whether the first element of input succeeds

`satisfy("message") {closure over $0 }` - you may optionally specify an error message. Default is "Did not find expected value"

##Combinators
`<|>` - **Alternative** - addition precedence - `p1 <|> p2` succeeds if either parser succeeds. On failure, returns the failure that got the farthest.

`<%>` - **Name** - addition precedence - `p1 <%> "message"` - uses the result of p1 if it succeeds or makes any progress, or a failure with the specified message if it makes no progress.

`<&>` - **Sequence** - multiplication precedence - `p1 <&> p2`

* For all variations, on failure it reports the point where it failed to find an acceptable value.
* If p1 and p2 have the same target type, returns an array of results. 
* If p1 and p2 have different target types, returns a tuple of the two results.

`<*>` - **Many (0 or more)** - prefix operator - `<*>p` returns an array of 0 or more values. (It can't return failure.)

`<+>` - **Many1 (1 or more)** - prefix operator - `<+>p` returns an array of 1 or values if the parse succeeds at least once, else returns failure 

`|>` - **Pipe** - multiplication precedence - `parser |> function` runs the parser. If it succeeds, it transforms the result via the function; if it fails, it returns failure. 
