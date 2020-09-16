# iCompiler

A compiler for an imaginary imperative language written in Dart.

## Try it out

You'll need a Dart compiler in order to run this project.

```bash
$ dart main.dart
```

## Project navigation

The compiler's starting point is the [`main.dart`](./main.dart) file. It is using the [`lexer.dart`](./lexer.dart) file to split the source code into tokens and then parses them into an AST consisting of classes defined in [`ast-nodes/`](./ast-nodes).
