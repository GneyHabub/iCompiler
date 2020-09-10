const reservedKeywords = [
  "var",
  "is",
  "routine",
  "end",
  "integer",
  "real",
  "boolean",
  "record",
  "array",
  "while",
  "loop",
  "for",
  "in",
  "reverse",
  "if",
  "then",
  "else",
  "and",
  "or",
  "xor",
  "true",
  "false",
];

bool isReserved(String identifier) {
  return reservedKeywords.contains(identifier);
}
