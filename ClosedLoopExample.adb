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
	ClosedLoop.On(cl);
	Put_Line("== Trying to set the Tachycardia UpperBound to 90");
	Put_Line("== but Expecting failure since it's in on mode");

	ClosedLoop.setTachycardiaBound(cl, 90);

	Put_Line("== Loop Start");
	for I in Integer range 0..100 loop
		ClosedLoop.tick(cl);
		delay 0.1;
	end loop;
	Put_Line("== Loop End");
	New_Line;
	New_Line;
	New_Line;

	-- Turn off the monitor: should return -1.0 for the next readings
	Put_Line("== Turn off the sys: should return -1.0");
	ClosedLoop.Off(cl);
	ClosedLoop.tick(cl);
	
	Put_Line("== Set the Tachycardia UpperBound to 150");
	Put_Line("== Expecting Success");
	ClosedLoop.setTachycardiaBound(cl, 135);

	Put_Line("== Trying to set the Fibrillation Bound to 5");
	Put_Line("== Expecting Success");
	ClosedLoop.setFibrillationBound(cl, 5);

	-- turn on the sys and set upper bound to 150
	Put_Line("== Turn on the sys");
	ClosedLoop.On(cl);
	

	Put_Line("-- Loop Start");
	for I in Integer range 0..100 loop
		ClosedLoop.tick(cl);
		delay 0.1;
	end loop;
	Put_Line("== Loop End");
	New_Line;
	New_Line;
	New_Line;
end ClosedLoopExample;