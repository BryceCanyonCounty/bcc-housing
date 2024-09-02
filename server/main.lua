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

BccUtils.Versioner.checkRelease(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-housing')
