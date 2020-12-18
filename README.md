# parse-sml (work-in-progress)

New users of Standard ML are often presented with error messages that
are incomprehensible (especially for a beginner), and other ML-like languages
are probably similar. In my opinion, this initial barrier to entry is a major
reason why ML-like languages are not more popular.

The goal of this project is to develop a custom lexer/parser for Standard ML
which helps both beginners and experts solve syntax errors quickly. Perhaps
it could also eventually provide SML tooling. (I would love to
have a comprehensive language server for SML...)

## Current Status

This project is very much in its initial stages.
Currently, I'm working on the lexer, which is far enough along to at least
provide a little bit of syntax highlighting. But don't expect any nice error
messages yet.

## Build and run

You'll need [`mlton`](http://mlton.org/) installed.

Do `make` and then pass a `.sml` file, for example:
```
$ make
$ ./main lex/Lexer.sml
```

This lexes the file and outputs it with highlighting to indicate token
classes. You'll need a terminal that supports colors via ANSI escapes, e.g.
iTerm2 on macOS.

## Design rationale

I decided not to use mllex/mlyacc for a number of reasons.
  * Using mllex/mlyacc would overly restrict the behavior of lexing and parsing.
  * The SML grammar is set in stone! This project doesn't need to specify or
  clarify the grammar itself---there are plenty of existing resources available
  for that.
  * I've always wanted to write a lexer and parser from scratch. Implementing
  finite state-machines (even large ones!) with a bunch of mutually recursive
  functions is fairly straightforward and pretty fun. The invariants of each
  state are easy to write down, and the code is somewhat self-documenting.