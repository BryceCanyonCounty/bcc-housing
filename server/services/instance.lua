local playerBuckets = {}

local function setPlayerBucket(src, bucketId)
    bucketId = math.floor(tonumber(bucketId) or 0)
    if bucketId < 0 then bucketId = 0 end

    SetPlayerRoutingBucket(src, bucketId)

    if bucketId == 0 then
        playerBuckets[src] = nil
    else
        playerBuckets[src] = bucketId
    end

    return bucketId
end

BccUtils.RPC:Register('bcc-housing:SetInstance', function(params, cb, src)
    print('Registered bcc-housing:SetInstance RPC')
    if not src then
        if cb then cb(false, { error = 'invalid_source' }) end
        return
    end

    local bucketId
    if params and params.auto then
        local offset = math.floor(tonumber(params.offset) or 0)
        bucketId = src + offset
    else
        bucketId = tonumber(params and params.bucketId)
    end

    bucketId = setPlayerBucket(src, bucketId)

    if cb then cb(true, { bucketId = bucketId }) end
end)

BccUtils.RPC:Register('bcc-housing:LeaveInstance', function(_, cb, src)
    if not src then
        if cb then cb(false, { error = 'invalid_source' }) end
        return
    end

    setPlayerBucket(src, 0)
    if cb then cb(true) end
end)

BccUtils.RPC:Register('bcc-housing:GetInstance', function(_, cb, src)
    local bucketId = playerBuckets[src] or 0
    if cb then cb(true, { bucketId = bucketId }) end
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerBuckets[src] = nil
    SetPlayerRoutingBucket(src, 0)
end)
