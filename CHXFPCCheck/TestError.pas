program TestError;
{
  Simplest error test: Program is only one file without any unit.

  ToDo: Add an Info message example.
}
var
  a, b, c : integer; // 2 Notes: "a" and "c" not used (with -vn argument)
                     // Only seen if successful compiled
begin
  a := b; // Warning: "b" not initialized (with -vw argument)

   NotExistsFunc; // Error: NotExistsFunc doesn't exists
end; // Fatal: Must be a dot
