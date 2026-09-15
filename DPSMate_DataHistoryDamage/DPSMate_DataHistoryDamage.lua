-- DPSMate STORAGE_SPLIT3 - historical damage ownership.
-- Runtime compatibility remains DPSMateHistory["DMGDone"] / ["EDDone"].

if type(DPSMateHistoryDamage) ~= "table" then DPSMateHistoryDamage = {} end
if type(DPSMateHistoryDamage["DMGDone"]) ~= "table" then DPSMateHistoryDamage["DMGDone"] = {} end
if type(DPSMateHistoryDamage["EDDone"]) ~= "table" then DPSMateHistoryDamage["EDDone"] = {} end
