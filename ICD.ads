with Ada.Text_IO; use Ada.Text_IO;
with ImpulseGenerator;
with Measures;
with Heart;
with HRM;

-- this package implements the functionality of 
-- the on mode of the system. That is, it provides 
-- the necessary calculations of the 
-- impulse based on the measured heart rate.
Package ICD is

	-- The record type for a ICD 
	type ICDType is
		record

			Rate 				: Measures.BPM;		-- Heart rate get from HRM
			Last6Rate           : Measures.BPMARRAY;-- Last 6 Heart rate get from HRM

			IsOn 				: Boolean; 			-- Indeicates whether ICD is on

			TachycardiaBound 	: Measures.TUB; 	-- Setting the upper bound for a tachycardia
			isTachycardia 		: Boolean; 			-- Indeicates whether there is a tachycardia?
			isInImpulseProcess	: Boolean; 			-- Indicate whether it's in the period of giving impulse
			Impulse 			: Measures.Joules;  -- The impulse to be administered in the next tick
			ImpulseRate 		: Integer; 			-- The rate of impulse
			Offset 				: Integer; 			-- the offset of impulse
			TickToNextImpulse 	: Integer; 			-- setting how many ticks before next impulse
			Signal 				: Integer; 			-- setting how many singals need to be sent

			FibrillationBound	: Measures.FUB;		-- Setting the bound of a  Fibrillation
			isFibrillation 		: Boolean; 			-- Indeicates whether there is a Fibrillation?
			AbnormalNum 		: Integer;			-- Indicates the anbnormal number heart rate in last 6 ticks
			waitAfterShock      : Integer;			-- After a shoc; icd should wait a few time before next action
			isWait				: Boolean;          -- indicate whether sys is in the wait mode after a shock is delivered

		end record;
		
	-- Create and initialise a ICD.
	procedure Init(Icd :out ICDType);

	-- Turn on the sys and get first reading from the HRM
	procedure On(Icd: out ICDType ; Hm : in out HRM.HRMType; Gen : out ImpulseGenerator.GeneratorType ; Hrt: in out Heart.HeartType);

	-- Turn off the monitor and generator
	procedure Off(Icd: out ICDType; Hm : in out HRM.HRMType; Gen : out ImpulseGenerator.GeneratorType);

	-- Get the status of system (on/off)?
	function IsOn(Icd : in ICDType) return Boolean;

	-- Get the status of whether there is a tachycardia?
	procedure isTachycardia(Icd : in out ICDType);

	-- Get the status of whether there is a Fibrillation?
	procedure isFibrillation(Icd : in out ICDType);

	-- Calculate the Impluse
	procedure CalculateImpluse(Icd : out ICDType);

	-- Set Tachycardia Upper Bound for tachycardia
	procedure setTachycardiaBound (Icd : in out ICDType; ub : in Integer);

	-- Set Tachycardia Upper Bound for Fibrillation
	procedure setFibrillationBound (Icd : in out ICDType; ub : in Integer);
	
	-- Get how many abnormal heart rates in last 5 tick, if more than 3 , it's a Fibrillation
	procedure GetAbnormalNum (Icd : in out ICDType);

	-- update the array make last6Rate(i+1):= last6Rate(i)
	procedure BPMArrayUpdate (Icd : in out ICDType);

	-- Tick the clock, reading heart rate from the Hrm, and decide wheter to call the generator
	procedure Tick(Icd : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.GeneratorType);

end ICD;



