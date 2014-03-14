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
			Rate 		: Measures.BPM;    -- Heart rate get from HRM
			UpperBound 	: Integer; -- Setting the upper bound for a tachycardia
			IsOn 		: Boolean; -- Indeicates whether ICD is on
			isTachycardia : Boolean; -- Indeicates whether there is a tachycardia?
			Impulse : Measures.Joules;  -- The impulse to be administered in the next tick
		end record;
		
	-- Create and initialise a ICD.
	procedure Init(Icd :out ICDType);

	-- Turn on the ICD and get first reading from the HRM
	procedure On(Icd: out ICDType ; Hm : in HRM.HRMType);

	-- Turn off the ICD
	procedure Off(Icd : out ICDType);

	-- Get the status of Icd (on/off)?
	function IsOn(Icd : in ICDType) return Boolean;

	-- Access the heart rate
	procedure GetRate (Icd : in ICDType ; Rate : out Measures.BPM); -- is this necessary??

	-- Get the status of whether there is a tachycardia?
	function isTachycardia(Icd : in ICDType) return Boolean;

	-- Calculate the Impluse
	procedure CalculateImpluse(Icd : out ICDType);

	-- Tick the clock, reading heart rate from the Hrm, and decide wheter to call the generator
	procedure Tick(Icd : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.GeneratorType);
end ICD;



