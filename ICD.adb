with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures;
with Heart;
with HRM;

package body ICD is  

	time : constant Integer := 5;
	procedure Init(Icd :out ICDType) is
	begin
		Icd.IsOn 				:= False;

		Icd.LastRate            := Measures.BPM'First;
		Icd.Rate 				:= Measures.BPM'First;

		Icd.isTachycardia 		:= False;

		Icd.isFibrillation		:= False;

		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.isInImpulseProcess 	:= False;


		Icd.TachycardiaBound 	:= Measures.TUB'First;
		Icd.FibrillationBound 	:= Measures.FUB'First;

		Icd.isWait				:= False;
		Icd.waitAfterShock      := 10;

		Icd.Offset 				:= 0;
		Icd.TickToNextImpulse 	:= 0;
		Icd.Signal 				:= 10;

	end Init;
	
	procedure On(Icd: out ICDType ; Hm : in out HRM.HRMType; Gen : out ImpulseGenerator.GeneratorType; Hrt: in Heart.HeartType) is
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
		Icd.TachycardiaBound 	:= Measures.TUB'First;
		Icd.FibrillationBound 	:= Measures.FUB'First;
		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.Offset 				:= 0;

		HRM.On(Hm, Hrt);
		ImpulseGenerator.On(Gen);
	end On;

	procedure Off(Icd: out ICDType ; Hm : in out HRM.HRMType; Gen : out ImpulseGenerator.GeneratorType) is
	begin
    	--Icd.IsOn := False;
    	-- Since ICD is the controller
    	-- it should never be turned down

    	Icd.IsOn := False;
    	HRM.Off(Hm);
		ImpulseGenerator.Off(Gen);
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
		if Icd.Rate >= Icd.TachycardiaBound  then 
			Icd.isTachycardia := True;
			
		else
			Icd.isTachycardia := False;
		end if;
	end isTachycardia;

	procedure isFibrillation(Icd : in out ICDType) is
	begin
		-- if abs(Icd.LastRate - Icd.Rate) >= Icd.FibrillationBound then
		-- 	Icd.isFibrillation := True;
		-- 	Icd.isTachycardia := False;
		-- else
		-- 	Icd.isFibrillation := False;
		-- end if;
		GetAbnormalNum(Icd);

	end isFibrillation;

	procedure isWait(Icd : in out ICDType) is
	begin
		if Icd.isWait then
			Icd.waitAfterShock := Icd.waitAfterShock -1 ;
			if Icd.waitAfterShock = 0 then
				Icd.waitAfterShock := 10;
				Icd.isWait := False;
			end if;
		end if;
	end isWait;

	procedure CalculateImpluse(Icd : out ICDType) is
	begin

		-- reset impulse to 0 before each caculation
		Icd.Impulse := 0;
		--Check whether there is a Fibrillation

		if not Icd.isWait then

			if Icd.isFibrillation then
				Put_Line("May DAy May Day,  Fibrillation is detected!");

				-- since Fibrillation is heavier than Tachycardia
				-- then if a Fibrillation is detected, set impulse
				-- to 30, and terminate all in process impulse
				Icd.Impulse 			:= 30;
				Icd.isInImpulseProcess 	:= False;
				Icd.isWait				:= True;
				-- reset tick and sinal to it's defualt value
				Icd.TickToNextImpulse 	:= 0;
				Icd.Signal 				:= 10;
			end if;
				
			if Icd.isTachycardia and not Icd.isInImpulseProcess then	
				Put_Line("A ventricular tachycardia was detected ");
			end if;
			-- check whether there is a Tachycardia detected
			-- or a impulse treatment in process
			if (Icd.isTachycardia or Icd.isInImpulseProcess) then
				-- set the isInImpulseProcess to true indicatong that
				-- there is a treatment in process
				-- it will be changed to false when 
				-- a process is finised (signal == 0)
				Icd.isInImpulseProcess := True;
				--caculate the bpm, which equals Upper Bound + 15
				Icd.ImpulseRate := Icd.TachycardiaBound + 15;
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
					Icd.Signal := 10;
					Icd.isInImpulseProcess := False;
				end if;
			end if;
		end if;

	end CalculateImpluse;
	
	procedure setTachycardiaBound (Icd : in out ICDType; ub : in Integer) is
	begin
		if not Icd.IsOn then
			-- make sure the Ub is in the range
			Icd.TachycardiaBound := Measures.LimitTUB(ub);
			Put("-- The Tachycardia Upper Bound has been changed to");
			Put(Item => Icd.TachycardiaBound, width => 0);
    		New_Line;     
		else
			Put_Line("-- The Tachycardia UpperBound can only be changed in Off mode");
			Put_Line("-- Please use Switch to change the mode");
			Put("-- The Tachycardia Upper Bound is still ");
			Put(Item => Icd.TachycardiaBound, width => 0);
    		New_Line;     

		end if;
	end setTachycardiaBound;

	procedure BPMArrayUpdate (Icd : in out ICDType) is
	begin 
		for I in Integer range 0..4 loop
			Icd.Last6Rate(4 - I + 1) := Icd.Last6Rate(4 -I);
		end loop;
	end BPMArrayUpdate;

	procedure GetAbnormalNum (Icd : in out ICDType) is
	AbnormalNum : Integer := 0;
	begin 
		for I in Integer range 0..4 loop
			if abs(Icd.Last6Rate(I) - Icd.Last6Rate(I + 1)) >= Icd.FibrillationBound then
				AbnormalNum := AbnormalNum + 1;
			end if;
		end loop;
		if AbnormalNum > 3 then
			Icd.isFibrillation := true;
		end if;
	end GetAbnormalNum;	

	procedure Tick(Icd : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.GeneratorType) is
	begin
	
		-- read the heart rate from hrm
		HRM.GetRate(Hm, Icd.Rate);
		BPMArrayUpdate(icd);
		Icd.Last6Rate(0) := Icd.Rate;

		-- Put("   This last 6 Rate  ");
		-- Put(Item => Icd.Last6Rate(0));
		-- Put(Item => Icd.Last6Rate(1));
		-- Put(Item => Icd.Last6Rate(2));
		-- Put(Item => Icd.Last6Rate(3));
		-- Put(Item => Icd.Last6Rate(4));
		-- Put(Item => Icd.Last6Rate(5));

		New_Line;
		--check whether there is 1s after giving a shock
		isWait(icd);
		--check whether there is a Tachycardia
		isTachycardia(Icd);
		--check whether there is a Fibrillation
		isFibrillation(Icd);		
		CalculateImpluse(Icd);

		-- calculate and set the impluse
		ImpulseGenerator.SetImpulse(Gen, Icd.Impulse);    


		Put("Heart rate  = ");
		Put(Item => Icd.Rate);
		New_Line;
	end Tick;
end ICD;
