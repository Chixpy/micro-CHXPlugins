- Updating `README.md` and some others, to previous commit changes...
- `CHXSplitLines`: Adding return value to functions.
- `CHXStatusExt`:
  - Added functions to insert time, date and file path to current buffer.
  - Fixed showing wrong git directory if 2 or more files have same filename.
  - Fixed not cleaning cache on close file.
- `CHXSplitLines`:
  - Fixed `CHXNBSP` when cursor has selection.
  - Multicursor support for `CHXNBSP` function, inserting it with all cursors.
  - Fixing a  weird bug between  &nbps, ·,  º, ª, ¬  and other characters  when
    spliting.
- `CHXFastSearch`: Optimized, less hacked  and fixed searching characters  that
  are RegEx symbols.
- `jump` modified to use full file path. 
