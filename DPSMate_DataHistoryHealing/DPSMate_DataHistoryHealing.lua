-- DPSMate STORAGE_SPLIT3 - historical healing ownership.
-- Runtime DPSMateHistory category names are intentionally unchanged.

if type(DPSMateHistoryHealing) ~= "table" then DPSMateHistoryHealing = {} end
if type(DPSMateHistoryHealing["THealing"]) ~= "table" then DPSMateHistoryHealing["THealing"] = {} end
if type(DPSMateHistoryHealing["EHealing"]) ~= "table" then DPSMateHistoryHealing["EHealing"] = {} end
if type(DPSMateHistoryHealing["OHealing"]) ~= "table" then DPSMateHistoryHealing["OHealing"] = {} end
if type(DPSMateHistoryHealing["EHealingTaken"]) ~= "table" then DPSMateHistoryHealing["EHealingTaken"] = {} end
if type(DPSMateHistoryHealing["THealingTaken"]) ~= "table" then DPSMateHistoryHealing["THealingTaken"] = {} end
if type(DPSMateHistoryHealing["OHealingTaken"]) ~= "table" then DPSMateHistoryHealing["OHealingTaken"] = {} end
if type(DPSMateHistoryHealing["Absorbs"]) ~= "table" then DPSMateHistoryHealing["Absorbs"] = {} end
