with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Measures;
with Heart;
with HRM;

package body ICD is  

	time : constant Integer := 5;
	procedure Init(Icd :out ICDType) is
	begin
		Icd.Rate 				:= Measures.BPM'First;
		Icd.Last6Rate           := (0,0,0,0,0,0);

		Icd.IsOn 				:= False;
		--Tachycardia realated variables
		Icd.TachycardiaBound 	:= Measures.TUB'First;
		Icd.isTachycardia 		:= False;
		Icd.isInImpulseProcess 	:= False;
		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.Offset 				:= 0;
		Icd.TickToNextImpulse 	:= 0;
		Icd.Signal 				:= 10;
		--Fibrillation realated variables
		Icd.FibrillationBound 	:= Measures.FUB'First;
		Icd.isFibrillation		:= False;
		Icd.isWait				:= False;
		Icd.waitAfterShock      := 10;
		Icd.AbnormalNum         := 0;
	end Init;
	
	procedure On(Icd: out ICDType ; Hm : in out HRM.HRMType; Gen : out ImpulseGenerator.GeneratorType; Hrt: in out Heart.HeartType) is
	begin
		-- re-set the Icd, which setting all variable to default value, excepting TachycardiaBound 
		-- and FibrillationBound, because they might be changed in off mode
		Icd.Rate 				:= Measures.BPM'First;
		Icd.Last6Rate           := (0,0,0,0,0,0);

		Icd.IsOn 				:= True;
		--Tachycardia realated variables
		Icd.isTachycardia 		:= False;
		Icd.isInImpulseProcess 	:= False;
		Icd.Impulse 			:= 0;
		Icd.ImpulseRate 		:= 0;
		Icd.Offset 				:= 0;
		Icd.TickToNextImpulse 	:= 0;
		Icd.Signal 				:= 10;
		--Fibrillation realated variables
		Icd.isFibrillation		:= False;
		Icd.isWait				:= False;
		Icd.waitAfterShock      := 10;
		Icd.AbnormalNum         := 0;
		-- turn on Hrm and Gen
		HRM.On(Hm, Hrt);
		ImpulseGenerator.On(Gen);
		-- re-init Heart
		Heart.Init(Hrt);
		-- Get an initial reading for the heart
		HRM.GetRate(Hm, Icd.Rate);

	end On;

	procedure Off(Icd: out ICDType ; Hm : in out HRM.HRMType; Gen : out ImpulseGenerator.GeneratorType) is
	begin
    	-- Since ICD is the controller, it should never be turned down, only turn down Hrm and Gen
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
		-- check wheter the heart rate is higher than the upper bound
		if Icd.Rate >= Icd.TachycardiaBound  then 
			Icd.isTachycardia := True;
		else
			Icd.isTachycardia := False;
		end if;
	end isTachycardia;

	procedure isFibrillation(Icd : in out ICDType) is
	begin
		-- if there are 3 abnormal rate in 5 ticks then it is considered as a Fibrillation
		GetAbnormalNum(Icd);
		if Icd.AbnormalNum > 3 then
			Icd.isFibrillation := true;
			-- when a Fibrillation is detected Tachycardia detection should be turn off, since Fibrillationis more serious than Tachycardia
			Icd.isTachycardia := False;
		else
			Icd.isFibrillation := False;
		end if;
	end isFibrillation;

	procedure GetAbnormalNum (Icd : in out ICDType) is
	begin 
		Icd.AbnormalNum := 0;
		for I in Integer range 0..4 loop
			if abs(Icd.Last6Rate(I) - Icd.Last6Rate(I + 1)) >= Icd.FibrillationBound then
				Icd.AbnormalNum := Icd.AbnormalNum + 1;
			end if;
		end loop;
	end GetAbnormalNum;	

	-- indicates that the icd should wait 1s after a 30 j shock was given
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
		--check whether there is 1s after giving a shock
		if not Icd.isWait then
			-- Check whether there is a Fibrillation
			if Icd.isFibrillation then
				Put_Line("May DAy May Day,  Fibrillation is detected!");
				-- since Fibrillation is heavier than Tachycardia then if a Fibrillation is detected, set impulse to 30, and terminate all in process impulse
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
			-- check whether there is a Tachycardia detected or a impulse treatment in process
			if (Icd.isTachycardia or Icd.isInImpulseProcess) then
				-- set the isInImpulseProcess to true indicatong that there is a treatment in process it will be changed to false when  a process is finised (signal == 0)
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
				-- if singal equals to 0 means the treatment is fninished then set the isTachycardia to False set TickToNextImpulse to default 0 reset singal to 10
				if Icd.Signal = 0 then
					Icd.TickToNextImpulse := 0;
					Icd.Signal := 10;
					Icd.isInImpulseProcess := False;
				end if;
			end if;
		end if;

	end CalculateImpluse;
	
	procedure setFibrillationBound (Icd : in out ICDType; ub : in Integer) is
	begin
		if not Icd.IsOn then
			-- make sure the Ub is in the range
			Icd.FibrillationBound := Measures.LimitFUB(ub);
			Put("-- The Fibrillation Bound has been changed to");
			Put(Item => Icd.FibrillationBound, width => 0);
    		New_Line;     
		else
			Put_Line("-- The Fibrillation Bound can only be changed in Off mode");
			Put_Line("-- Please use Switch to change the mode");
			Put("-- The Fibrillation Upper Bound is still ");
			Put(Item => Icd.FibrillationBound, width => 0);
    		New_Line;     

		end if;
	end setFibrillationBound;

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
