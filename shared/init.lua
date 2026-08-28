BccUtils = exports['bcc-utils'].initiate()
DBG = BccUtils.Debug:Get('bcc-housing', Config.DevMode)

if DBG and Config.DevMode then
    DBG:Enable()
end

DBG:Info('Housing debug initialized')
