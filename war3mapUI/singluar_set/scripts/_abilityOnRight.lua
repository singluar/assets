-- 右键 - 技能 - 事件管理
_singluarSetAbilityOnRight = function(stage)
    local frameMax = stage.ability_max
    ---@type FrameBackdrop[]
    local frameBedding = stage.ability_bedding
    ---@type FrameButton[]
    local frameButton = stage.ability_btn

    --- 跟踪回调
    local onFollowChange = function(followData, i)
        local fi = followData.i
        local fo = followData.followObj
        if (isObject(fo, "Ability")) then
            sync.send("SINGLUAR_SET_ABILITY_SYNC", { "ability_push", fo.id(), i, fi })
            audio(Vcm("war3_click1"))
        end
    end

    sync.receive("SINGLUAR_SET_ABILITY_SYNC", function(syncData)
        local syncPlayer = syncData.syncPlayer
        local command = syncData.transferData[1]
        if (command == "ability_push") then
            local abId = syncData.transferData[2]
            local i = tonumber(syncData.transferData[3])
            local fi = tonumber(syncData.transferData[4])
            ---@type Ability
            local ab = i2o(abId)
            if (isObject(ab, "Ability")) then
                syncPlayer.selection().abilitySlot().push(ab, i)
            end
            japi.DzFrameSetAlpha(frameButton[fi].handle(), frameButton[fi].alpha())
        end
    end)

    mouse.onRightClick("singluarSet_onAbilityMouseRightClick", function(evtData)
        local triggerPlayer = evtData.triggerPlayer
        local following = Cursor().following()
        local followObj = Cursor().followObj()
        if (following == true and isObject(followObj, "Ability") == false) then
            return
        end
        local selection = triggerPlayer.selection()
        if (selection ~= nil) then
            local judge = isObject(selection, 'Unit') and selection.isAlive() and selection.owner() == triggerPlayer
            if (judge) then
                local j = 0
                for i = 1, frameMax do
                    local ab = selection.abilitySlot().storage()[i]
                    local bed = frameBedding[i]
                    local anchor = bed.anchor()
                    if (anchor ~= nil) then
                        local x = anchor[1]
                        local y = anchor[2]
                        local w = anchor[3]
                        local h = anchor[4]
                        local xMin = x - w / 2
                        local xMax = x + w / 2
                        local yMin = y - h / 2
                        local yMax = y + h / 2
                        local rx = japi.MouseRX()
                        local ry = japi.MouseRY()
                        if (rx < xMax and rx > xMin and ry < yMax and ry > yMin) then
                            if (following == true) then
                                if (table.equal(followObj, ab) == false) then
                                    Cursor().followStop(function(followData)
                                        onFollowChange(followData, i)
                                    end)
                                else
                                    Cursor().followStop(function(followData)
                                        japi.DzFrameSetAlpha(followData.frame.handle(), followData.frame.alpha())
                                    end)
                                end
                            elseif (isObject(ab, "Ability")) then
                                FrameTooltips().show(false, 0)
                                audio(Vcm("war3_click1"))
                                japi.DzFrameSetAlpha(frameButton[i].handle(), 0)
                                Cursor().followCall(ab, { frame = frameButton[i], i = i }, function(stopData)
                                    japi.DzFrameSetAlpha(stopData.frame.handle(), stopData.frame.alpha())
                                end)
                            end
                            break
                        end
                    end
                    j = i + 1
                end
                if (j > frameMax and following == true) then
                    Cursor().followStop(function(followData)
                        japi.DzFrameSetAlpha(followData.frame.handle(), followData.frame.alpha())
                    end)
                end
            end
        end
    end)
end