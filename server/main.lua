RegisterServerEvent("bcc-housing:AdminCheck", function()
    local _source, admin = source, false
    local character = VORPcore.getUser(_source).getUsedCharacter
    if character.group == Config.adminGroup then
        TriggerClientEvent("bcc-housing:AdminClientCatch", _source, true)
    end

    if not admin then
        for k, v in pairs(Config.ALlowedJobs) do
            if character.job == v.jobname then
                TriggerClientEvent('bcc-housing:AdminClientCatch', _source, true)
                break
            end
        end
    end
end)

-- Job check to use NPC Real Estate Agent
VORPcore.Callback.Register('bcc-housing:CheckJob', function(source, cb, location)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end

    local character = user.getUsedCharacter
    local jobCfg = Agents[location].shop.jobs
    local hasJob = false

    for _, job in pairs(jobCfg) do
        if (character.job == job.name) and (tonumber(character.jobGrade) >= tonumber(job.grade)) then
            hasJob = true
            break
        end
    end

    cb(hasJob)
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-housing')
