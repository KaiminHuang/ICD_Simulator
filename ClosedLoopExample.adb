with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with ImpulseGenerator;
with Measures;
with Heart;
with HRM;
with ICD;
with ClosedLoop;
--implements a scenario showing how to use your ClosedLoop package

Procedure ClosedLoopExample is 
	cl : ClosedLoop.ClosedLoopType; --The simulated Closed Loop
begin
	ClosedLoop.Init(cl); -- Initalise the Closed Loop
	ClosedLoop.switch(cl);-- Set the mode to On

	for I in Integer range 0..4 loop
		Put_Line("Loop Start");
		ClosedLoop.tick(cl);
		delay 0.1;
	end loop;
end ClosedLoopExample;