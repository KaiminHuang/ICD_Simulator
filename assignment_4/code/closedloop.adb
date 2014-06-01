with Measures;
with Heart;
with HRM;
with ImpulseGenerator;
with ICD;

package body ClosedLoop is
 	procedure Init(cl : out ClosedLoopType) is
	begin
		
   		--Initalise hrt, monitor, gen, icd
		Heart.Init(cl.Hrt);
		HRM.Init(cl.Monitor);
		ICD.Init(cl.Icds);
		ImpulseGenerator.Init(cl.Generator);

		cl.IsOn 				:= False;

	end Init;

	procedure Off (cl : in out ClosedLoopType) is
	begin
		if cl.IsOn = True then
			-- set all components to Off
			ICD.Off(cl.Icds);
			HRM.Off(cl.Monitor);
			ImpulseGenerator.Off(cl.Generator);
			cl.IsOn := False;
		end if;
	end Off;

	procedure On (cl : in out ClosedLoopType) is
	begin
		if cl.IsOn = False then
			HRM.On(cl.Monitor, cl.Hrt);
			ImpulseGenerator.On(cl.Generator);
			Heart.Init(cl.Hrt);
			HRM.GetRate(cl.Monitor, cl.Icds.Rate);
			ICD.On(cl.Icds);
			cl.IsOn := True;
		end if;
	end On;

	procedure setTachycardiaBound (cl : in out ClosedLoopType; ub : in Integer) is
	begin
		ICD.setTachycardiaBound(cl.Icds, ub);
	end setTachycardiaBound;

	procedure setFibrillationBound (cl : in out ClosedLoopType; ub : in Integer) is
	begin
		ICD.setFibrillationBound(cl.Icds, ub);
	end setFibrillationBound;

	procedure tick (cl: in out ClosedLoopType) is 
	begin
		-- tick all components
		Heart.Tick(cl.Hrt);
		HRM.Tick(cl.Monitor, cl.Hrt);
		ICD.Tick(cl.Icds, cl.Monitor, cl.Generator);
		ImpulseGenerator.Tick(cl.Generator, cl.Hrt);

	end tick;

	function IsOn(cl: in ClosedLoopType) return Boolean is
  	begin
    	return cl.IsOn;
	end IsOn;
	
end ClosedLoop;
