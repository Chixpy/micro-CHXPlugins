- `syntax/pascal.yaml`: Added `and` as operator.
- `CHXSplitLines` plugin:
  - A little clean up.
  - Better support for UTF8 multibyte characters. So it doesn't split early.
  - `CHXSplitLines` function: Keep indent when spliting lines.
  - Added `CHXSplitLines.CHXJustifyLine`:  Justifies  (and  splits if needed) a
    line.
  - Added  `CHXSplitLines.CHXJustifyParagraph`:  Joins,  re-splits  (if needed)
    and justifies paragraphs separated by empty lines.
