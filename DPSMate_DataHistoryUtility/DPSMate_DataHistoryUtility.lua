-- DPSMate STORAGE_SPLIT3 - historical utility/resource ownership.
-- ResourceGained is represented by the existing Mana/Energy/Rage history keys.

if type(DPSMateHistoryUtility) ~= "table" then DPSMateHistoryUtility = {} end
if type(DPSMateHistoryUtility["Deaths"]) ~= "table" then DPSMateHistoryUtility["Deaths"] = {} end
if type(DPSMateHistoryUtility["Interrupts"]) ~= "table" then DPSMateHistoryUtility["Interrupts"] = {} end
if type(DPSMateHistoryUtility["Dispels"]) ~= "table" then DPSMateHistoryUtility["Dispels"] = {} end
if type(DPSMateHistoryUtility["Auras"]) ~= "table" then DPSMateHistoryUtility["Auras"] = {} end
if type(DPSMateHistoryUtility["ManaGained"]) ~= "table" then DPSMateHistoryUtility["ManaGained"] = {} end
if type(DPSMateHistoryUtility["EnergyGained"]) ~= "table" then DPSMateHistoryUtility["EnergyGained"] = {} end
if type(DPSMateHistoryUtility["RageGained"]) ~= "table" then DPSMateHistoryUtility["RageGained"] = {} end
if type(DPSMateHistoryUtility["Threat"]) ~= "table" then DPSMateHistoryUtility["Threat"] = {} end
if type(DPSMateHistoryUtility["Fails"]) ~= "table" then DPSMateHistoryUtility["Fails"] = {} end
if type(DPSMateHistoryUtility["CCBreaker"]) ~= "table" then DPSMateHistoryUtility["CCBreaker"] = {} end
