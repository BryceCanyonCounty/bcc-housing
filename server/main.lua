BccUtils.RPC:Register('bcc-housing:CheckIfAdmin', function(params, cb, src)
    local user = VORPcore.getUser(src)
    if not user then return cb(false) end

    local character = user.getUsedCharacter
    if character and character.group == Config.adminGroup then
        return cb(true)
    end

    for _, jobCfg in ipairs(Config.ALlowedJobs) do
        if character and character.job == jobCfg.jobname then
            return cb(true)
        end
    end

    cb(false)
end)

BccUtils.RPC:Register('bcc-housing:CheckJob', function(params, cb, src)
    local location = params and params.location
    local user = VORPcore.getUser(src)
    if not user or not location then return cb(false) end

    local character = user.getUsedCharacter
    local agent = Agents[location]
    local jobCfg = agent and agent.shop and agent.shop.jobs
    if type(jobCfg) ~= 'table' then return cb(false) end

    local hasJob = false
    for _, job in pairs(jobCfg) do
        if character
        and character.job == job.name
        and tonumber(character.jobGrade) >= tonumber(job.grade) then
            hasJob = true
            break
        end
    end

    cb(hasJob)
end)

-- Check for version updates
BccUtils.Versioner.checkFile(GetCurrentResourceName(), "https://github.com/BryceCanyonCounty/bcc-housing")
