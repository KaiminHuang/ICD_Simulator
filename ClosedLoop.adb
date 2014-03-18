with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with ImpulseGenerator;
with Measures;
with Heart;
with HRM;
with ICD;

Package body ClosedLoop is 

	procedure Init(cl : out ClosedLoopType) is
	begin
   		--Initalise hrt, monitor, gen, icd
		Heart.Init(cl.Hrt);
		HRM.Init(cl.Monitor);
		ICD.Init(cl.Icds);
		ImpulseGenerator.Init(cl.Generator);

	end Init;

	procedure Off (cl : in out ClosedLoopType) is
	begin
		-- set all components to Off
		ICD.Off(cl.Icds, cl.Monitor, cl.Generator);
		Put_Line("Switched to Off mode");

	end Off;

	procedure On (cl : in out ClosedLoopType) is
	begin
		-- Set all components to On 
		ICD.On(cl.Icds, cl.Monitor, cl.Generator, cl.Hrt);
		Put_Line("Switched to On mode");

	end On;

	procedure setUpperBound (cl : out ClosedLoopType; ub : in Integer) is
	begin
		ICD.setTachycardiaBound(cl.Icds, ub);
	end setUpperBound;

	procedure tick (cl: in out ClosedLoopType) is 
	begin
		Heart.Tick(cl.Hrt);
	
		HRM.Tick(cl.Monitor, cl.Hrt);

		ICD.Tick(cl.Icds, cl.Monitor, cl.Generator);
		ImpulseGenerator.Tick(cl.Generator, cl.Hrt);

	end tick;
	

end ClosedLoop;