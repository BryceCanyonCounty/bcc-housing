-- Check if player is admin to use 'AdminManagementMenuCommand'
VORPcore.Callback.Register('bcc-housing:CheckIfAdmin', function(source, cb)
    local src = source
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end

    local character = user.getUsedCharacter
    if character.group == Config.adminGroup then
        return cb(true)
    end

    for _, jobCfg in ipairs(Config.ALlowedJobs) do
        if character.job == jobCfg.jobname then
            return cb(true)
        end
    end

    cb(false)
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
