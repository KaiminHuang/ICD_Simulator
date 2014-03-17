with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures;
with Heart;
with HRM;

package body ICD is  

	procedure Init(Icd :out ICDType) is
	begin
		Icd.IsOn 				:= False;
		Icd.Rate 				:= Measures.BPM'First;
		Icd.isTachycardia 		:= False;
		Icd.isFibrillation		:= False;
		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.UpperBound 			:= 110;
		Icd.FibrillationBound 	:= 260;
		Icd.Offset 				:= 0;
		Icd.TickToNextImpulse 	:= 0;
		Icd.Signal 				:= 10;
		Icd.isInImpulseProcess 	:= False;
	end Init;
	
	procedure On(Icd: out ICDType ; Hm : in HRM.HRMType) is
	begin
	 	-- Get an initial reading for the heart
	 	Icd.IsOn := True;
		HRM.GetRate(Hm, Icd.Rate);

		--reset all values to default once it turned on
		Icd.isTachycardia 		:= False;
		Icd.isFibrillation		:= False;
		Icd.Rate 				:= Measures.BPM'First;

		Icd.isInImpulseProcess 	:= False;
    	Icd.TickToNextImpulse 	:= 0;
		Icd.Signal 				:= 10;
		Icd.UpperBound 			:= 110;   -- !!! change to defualt in measures later
		Icd.FibrillationBound 	:= 260;
		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.Offset 				:= 0;

	end On;

	procedure Off(Icd : out ICDType) is
	begin
    	Icd.IsOn := False;

   	end Off;
   
   	function IsOn(Icd : in ICDType) return Boolean is
  	begin
    	return Icd.IsOn;
	end IsOn;

	procedure GetRate (Icd : in ICDType ; Rate : out Measures.BPM) is
	begin
	  if Icd.IsOn then 
	     Rate := Icd.Rate;
	  else 
	     Rate := Measures.BPM'First;
	  end if;
	end GetRate;

	procedure isTachycardia(Icd : in out ICDType) is
	begin
		--check wheter the heart rate is higher than the upper bound
		if Icd.Rate >= Icd.UpperBound  then 
			Icd.isTachycardia := True;
			
		else
			Icd.isTachycardia := False;
		end if;
	end isTachycardia;

	procedure isFibrillation(Icd : in out ICDType) is
	begin
		--check wheter there os a Fibrillation
		if Icd.Rate >= Icd.FibrillationBound  then 
			Icd.isFibrillation := True;
			-- if there is a Fibrillation
			--Tachycardia should be turned off
			-- since Fibrillation is heavier
			Icd.isTachycardia := False;
		else
			Icd.isFibrillation := False;
		end if;
	end isFibrillation;

	procedure CalculateImpluse(Icd : out ICDType) is
	begin

		-- Put("* signal  = ");
		-- Put(Item => Icd.Signal);
		-- New_Line;

		-- Put("* TickToNextImpulse  = ");
		-- Put(Item => Icd.TickToNextImpulse);
		-- New_Line;

		-- reset impulse to 0 before each caculation
		Icd.Impulse := 0;
		--Check whether there is a Fibrillation
		if Icd.isFibrillation then
			Icd.Impulse := 4;
			-- since Fibrillation is heavier than Tachycardia
			-- then if a Fibrillation is detected, set impulse
			-- to 30, and terminate all in process impulse
			Icd.Impulse 			:= 4;
			Icd.isInImpulseProcess 	:= False;
			-- reset tick and sinal to it's defualt value
			Icd.TickToNextImpulse 	:= 0;
			Icd.Signal 				:= 10;
		else 
			Icd.Impulse := 0;
		end if;

		-- check whether there is a Tachycardia detected
		-- or a impulse treatment in process
		if Icd.isTachycardia or Icd.isInImpulseProcess then
			-- set the isInImpulseProcess to true indicatong that
			-- there is a treatment in process
			-- it will be changed to false when 
			-- a process is finised (signal == 0)
			Icd.isInImpulseProcess := True;
			--caculate the bpm, which equals Upper Bound + 15
			Icd.ImpulseRate := Icd.UpperBound + 15;
			--caculate the offset between inpulse
			Icd.offset := 600 / Icd.ImpulseRate;

			if Icd.TickToNextImpulse = 0 then
				-- if yes print "--Already in impulse procedure"
				Put("-- in impulse treatment procedure, there is");
				Put(Item => Icd.Signal);
				Put(" more singal to go");
				New_Line;
				-- set Impluse value to 2 j;
				Icd.Impulse := 2;
				-- update how many signal remains need to send
				Icd.Signal := Icd.Signal - 1;
				-- set next impulse time to offset once it is 0
				Icd.TickToNextImpulse := Icd.offset -1 ;
			else
				Icd.Impulse := 0;
				Icd.TickToNextImpulse := Icd.TickToNextImpulse - 1;
			end if;
			-- if singal equals to 0 means the treatment is fninished
			-- then set the isTachycardia to False
			-- set TickToNextImpulse to default 0
			-- reset singal to 10
			if Icd.Signal = 0 then

				Icd.TickToNextImpulse := 0;
				Put("--");
				Put(Item => Icd.Signal);
				Put("==");
				Icd.Signal := 10;
				Icd.isInImpulseProcess := False;
			end if;
							Put("TickToNextImpulse is");
				Put(Item => Icd.TickToNextImpulse);
				New_Line;

				
		end if;
	end CalculateImpluse;
	
	procedure setUpperBound (Icd : in out ICDType; ub : in Integer) is
	begin
		if Icd.IsOn then
			Icd.UpperBound := ub;
			Put("The Upper Bound has been changed to");
			Put(Item => Icd.UpperBound);
    		New_Line;     

		else
			Put_Line("The UpperBound can only be changed in Off mode");
			Put_Line("Please use Switch to change the mode");
    		New_Line;     

		end if;
	end setUpperBound;

	procedure Tick(Icd : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.GeneratorType) is
	begin


		
		-- read the heart rate from hrm
		HRM.GetRate(Hm, Icd.Rate);
		Put("Heart rate  = ");
		Put(Item => Icd.Rate);
		New_Line;
		if Icd.IsOn then
			--check whether there is a Tachycardia
			isTachycardia(Icd);
			--check whether there is a Fibrillation
			isFibrillation(Icd);

			if Icd.isTachycardia and not Icd.isInImpulseProcess then	
				Put_Line("A ventricular tachycardia was detected ");
			end if;

			if Icd.isFibrillation then
				Put_Line("May DAy May Day,  Fibrillation is detected!");
			end if;			

			-- calculate and set the impluse
			CalculateImpluse(Icd);
			ImpulseGenerator.SetImpulse(Gen, Icd.Impulse);
		else
			Put("the sys was swithced off, Please turn on first");
    		New_Line;     

		end if;
	end Tick;
end ICD;
