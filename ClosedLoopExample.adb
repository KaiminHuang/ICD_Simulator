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
	
	-- turn on the sys and set upper bound to 120
	ClosedLoop.switch(cl);
	Put_Line("-- Set the setUpperBound to 120");

	ClosedLoop.setUpperBound(cl, 105);

	Put_Line("-- Loop Start");
	for I in Integer range 0..100 loop
		ClosedLoop.tick(cl);
		delay 0.1;
	end loop;

	-- Turn off the monitor: should return -1.0 for the next readings
	Put_Line("-- Turn off the sys: should return -1.0");
	ClosedLoop.switch(cl);
	ClosedLoop.tick(cl);
	
	-- turn on the sys and set upper bound to 150
	Put_Line("-- Turn on the sys");
	ClosedLoop.switch(cl);
	Put_Line("-- Set the setUpperBound to 150");
	ClosedLoop.setUpperBound(cl, 135);

	Put_Line("-- Loop Start");
	for I in Integer range 0..100 loop
		ClosedLoop.tick(cl);
		delay 0.1;
	end loop;

end ClosedLoopExample;