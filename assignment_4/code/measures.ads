-- This package provides some basic measures and limit functions for
--  the ICD case study.
package Measures is
   
   MIN_JOULES : constant Integer := 0;
   MAX_JOULES : constant Integer := 45;
   
   -- The type for joules (unit of energy used in generator)
   subtype Joules is Integer range MIN_JOULES .. MAX_JOULES;
   
   MIN_BPM : constant Integer := -1;
   MAX_BPM : constant Integer := 300;
   
   -- The type for heart rate: beats per minute
   subtype BPM is Integer range MIN_BPM .. MAX_BPM;
   
   MIN_TUB : constant Integer := 100;
   MAX_TUB : constant Integer := 150;
   -- The type for tachycardia Upper Bound: beats per minute
   subtype TUB is Integer range MIN_TUB .. MAX_TUB;

   MIN_FUB : constant Integer := 3;
   MAX_FUB : constant Integer := 15;
   -- the type for Fibrillation Bound: percentage
   subtype FUB is Integer range MIN_FUB .. MAX_FUB;
   
   -- A function to limit floats
   function Limit(Input : in Integer; Fst : in Integer; Lst : in Integer) 
		 return Integer;
   --# pre Fst <= Lst;
   --# return Output => (Fst <= Output and Output <= Lst);
   
   -- A function to limit BPM measures
   function LimitBPM(Input : in Integer) return BPM;
   --# return Output => (BPM'First <= Output and Output <= BPM'Last);
   
   -- A function to limit Joules measures
   function LimitJoules(Input : in Integer) return Joules;
   --# return Output => (Joules'First <= Output and Output <= Joules'Last);
      
   -- A function to limit tachycardia upeer bound measures
   function LimitTUB(Input : in Integer) return TUB;
   --# return Output => (TUB'First <= Output and Output <= TUB'Last);

      -- A function to limit Fibrillation upeer bound measures
   function LimitFUB(Input : in Integer) return FUB;
   --# return Output => (FUB'First <= Output and Output <= FUB'Last);

end Measures;
