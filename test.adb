with Ada.Text_IO; use Ada.Text_IO;

procedure test is
	subtype BPM is Integer range 2 .. 5;
begin
	Put_Line(Integer'Image(BPM'First));
end test;
