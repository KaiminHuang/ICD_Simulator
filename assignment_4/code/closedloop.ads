with Measures; 
with Heart;
with HRM;
with ImpulseGenerator;
with ICD;

--# inherit Measures,
--#         Heart,
--#         HRM,
--#         ImpulseGenerator,
--#         ICD;
package ClosedLoop is
	type ClosedLoopType is
		record
			Hrt 		: Heart.HeartType;                	-- The simulated heart
	   		Monitor 	: HRM.HRMType;                		-- The simulated heart rate monitor
	   		Generator 	: ImpulseGenerator.GeneratorType; 	-- The simulated generator
	   		Icds 		: ICD.ICDType; 						-- The simulated ICD software 
   			IsOn 		: Boolean; 			-- Indeicates whether ICD is on

		end record;
	
	-- Create and initalise a ClosedLoop
	procedure Init(cl : out ClosedLoopType);
	--# derives cl from ;

	-- Switch between on/off mode
	procedure On (cl : in out ClosedLoopType);
	--# derives cl from cl;
	--# pre 	cl.IsOn = False;
   	--# post 	cl.IsOn = True;

	-- Switch between on/off mode
	procedure Off (cl : in out ClosedLoopType);
	--# derives cl from cl;
	--# pre 	cl.IsOn = True;
   	--# post 	cl.IsOn = False;

	-- Set Upper Bound for tachycardia
	procedure setTachycardiaBound (cl : in out ClosedLoopType; ub : in Integer);
	--# derives cl from ub, cl;

	-- Set Upper Bound for tachycardia
	procedure setFibrillationBound (cl : in out ClosedLoopType; ub : in Integer);
	--# derives cl from ub, cl;

	-- tick heart, monitor, ICD, Umpilse
	procedure tick (cl: in out ClosedLoopType);
	--# derives cl from cl;

	-- Get the status of system (on/off)?
	function IsOn(cl: in ClosedLoopType) return Boolean ;
	--# return cl.IsOn;
end ClosedLoop;

