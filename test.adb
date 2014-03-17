with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure test is
	subtype BPM is Integer range 2 .. 5;
	offset : Integer := 0;
begin
	Put_Line(Integer'Image(BPM'First));
	offset := 600 / 120;
	Put(Item => offset);

end test;
