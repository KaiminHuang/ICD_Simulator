with Measures; 
with HRM;
with ImpulseGenerator;
with Heart;

--# inherit Measures,
--#         HRM,
--#         ImpulseGenerator,
--#         Heart;
package ICD is
type ICDType is
record
            Rate                : Measures.BPM;     -- Heart rate get from HRM
            Last6thRate         : Measures.BPM;
            Last5thRate         : Measures.BPM;
            Last4thRate         : Measures.BPM;
            Last3rdRate         : Measures.BPM;
            Last2ndRate         : Measures.BPM;
            Last1stRate         : Measures.BPM;

            IsOn                : Boolean;          -- Indeicates whether ICD is on

            TachycardiaBound    : Measures.TUB;     -- Setting the upper bound for a tachycardia
            ImpulseRateBound    : Measures.TUB;     -- Setting the bound for ImpulseRate
            isTachycardia       : Boolean;          -- Indeicates whether there is a tachycardia?
            isInImpulseProcess  : Boolean;          -- Indicate whether it's in the period of giving
                                                    -- impulse
            Impulse             : Measures.Joules;  -- The impulse to be administered in the next tick
            ImpulseRate         : Integer;          -- The rate of impulse
            Offset              : Integer;          -- the offset of impulse
            TickToNextImpulse   : Integer;          -- setting how many ticks before next impulse
            Signal              : Integer;          -- setting how many singals need to be sent

            FibrillationBound   : Measures.FUB;     -- Setting the bound of a  Fibrillation
            isFibrillation      : Boolean;          -- Indeicates whether there is a Fibrillation?
            AbnormalNum         : Integer;          -- Indicates the anbnormal number heart rate in 
                                                    -- last 6 ticks
            waitAfterShock      : Integer;          -- After a shoc; icd should wait a few time 
                                                    -- before next action
            isWait              : Boolean;          -- indicate whether sys is in the wait mode 
                                                    -- after a shock is delivered
                                                    end record;

    -- Create and initialise a ICD.
    procedure Init(icdInstance : out ICDType);
    --# derives icdInstance from ;
    -- # post icdInstance.IsOn = False and
    -- #      icdInstance.isTachycardia = False and
    -- #      icdInstance.isInImpulseProcess = False and 
    -- #      icdInstance.FibrillationBound     = 0 and
    -- #      icdInstance.TachycardiaBound  = 0;


    -- Turn on the sys and get first reading from the HRM
    procedure On(icdInstance: in out ICDType);
    --# derives icdInstance from icdInstance;
    --# pre     icdInstance.Ison = False;
    --# post    icdInstance.IsOn = True;

    -- Get the status of system (on/off)?
    function IsOn(icdInstance : in ICDType) return Boolean;
    --# return icdInstance.IsOn;

    -- Turn off the monitor and generator
    procedure Off(icdInstance: in out ICDType);
    --# derives icdInstance from icdInstance;
    --# pre     icdInstance.Ison = True;
    --# post    icdInstance.IsOn = False;


    -- Get the status of whether there is a tachycardia?
    procedure isTachycardia(icdInstance : in out ICDType);
    --# derives icdInstance from icdInstance;
    --# post    ((icdInstance.Rate >= icdInstance.TachycardiaBound) -> 
    --#             icdInstance.isTachycardia = True)  
    --#          or
    --#         ((icdInstance.Rate < icdInstance.TachycardiaBound) ->
    --#             icdInstance.isTachycardia = False);

    -- Get the status of whether there is a Fibrillation?
    procedure isFibrillation(icdInstance : in out ICDType);
    --# derives icdInstance from icdInstance;
    --# post    ((icdInstance.AbnormalNum > 3) -> 
    --#             ((icdInstance.isTachycardia = False) 
    --#             and 
    --#             (icdInstance.isFibrillation = true)))  
    --#         or
    --#         ((icdInstance.AbnormalNum > 3) ->
    --#             icdInstance.isTachycardia = False);

    -- Set Tachycardia Upper Bound for tachycardia
    procedure setTachycardiaBound (icdInstance : in out ICDType; ub : in Integer);
    --# derives icdInstance from icdInstance, ub;
    --# post    ((icdInstance.IsOn -> icdInstance.TachycardiaBound = ub) 
    --#         or 
    --#         (icdInstance.IsOn -> (Measures.TUB'First <= icdInstance.TachycardiaBound 
    --#             and 
    --#             icdInstance.TachycardiaBound <= Measures.TUB'Last) ))
    --#         or
    --#         (not icdInstance.IsOn -> icdInstance = icdInstance~);

    -- Set Tachycardia Upper Bound for Fibrillation
    procedure setFibrillationBound (icdInstance : in out ICDType; ub : in Integer);
    --# derives icdInstance from icdInstance, ub;
    --# post    ((icdInstance.IsOn -> icdInstance.FibrillationBound = ub) 
    --#         or 
    --#         (icdInstance.IsOn -> (Measures.FUB'First <= icdInstance.FibrillationBound 
    --#             and 
    --#             icdInstance.FibrillationBound <= Measures.FUB'Last) )) 
    --#         or
    --#         (not icdInstance.IsOn -> icdInstance = icdInstance~);


    -- Calculate and set the Impluse
    procedure CalculateAndSetImpluse(icdInstance : in out ICDType);
    --# derives icdInstance from icdInstance;
    --# pre icdInstance.Ison = True;
    --# post    (icdInstance.isFibrillation -> icdInstance.Impulse = 30)
    --#         or
    --#         ((icdInstance.isTachycardia and icdInstance.Signal = 0) -> icdInstance.Impulse = 2)
    --#         or
    --#         ((icdInstance.isTachycardia and icdInstance.Signal > 0) -> icdInstance.Impulse = 0);


    -- update the array make last6Rate(i+1):= last6Rate(i)
    procedure BPMArrayUpdate (icdInstance : in out ICDType);
    --# derives icdInstance from icdInstance;

    -- indicates that the icd should wait 1s after a 30 j shock was given
    procedure isWait(icdInstance : in out ICDType);
    --# derives icdInstance from icdInstance;
    --# post    ((icdInstance.waitAfterShock > 1) -> 
    --#             (icdInstance.isWait = False))  
    --#         or
    --#         ((icdInstance.waitAfterShock = 1) ->
    --#             icdInstance.isWait = true);

    -- get abnormal heart rate number from the last six records
    procedure GetAbnormalNum (icdInstance : in out ICDType);
    --# derives icdInstance from icdInstance;
    --# post  (icdInstance.AbnormalNum >= 0) and (icdInstance.AbnormalNum <=6);
    
    -- Tick the clock, reading heart rate from the Hrm, and decide wheter to call the generator
    procedure Tick (icdInstance : in out ICDType; Hm : in HRM.HRMType; Gen : in out ImpulseGenerator.
        GeneratorType);
    --# derives icdInstance from Hm, icdInstance & Gen from icdInstance, Gen, Hm;

end ICD;

