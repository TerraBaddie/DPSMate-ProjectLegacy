-- DPSMate STORAGE_SPLIT3 - historical damage-taken ownership.
-- Runtime compatibility remains DPSMateHistory["DMGTaken"] / ["EDTaken"].

if type(DPSMateHistoryTaken) ~= "table" then DPSMateHistoryTaken = {} end
if type(DPSMateHistoryTaken["DMGTaken"]) ~= "table" then DPSMateHistoryTaken["DMGTaken"] = {} end
if type(DPSMateHistoryTaken["EDTaken"]) ~= "table" then DPSMateHistoryTaken["EDTaken"] = {} end
