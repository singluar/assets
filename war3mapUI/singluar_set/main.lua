--[[
    S控制全套
    Author: hunzsig
]]

local kit = 'singluar_set'

local this = UIKit(kit)

this.onSetup(function()
    local stage = this.stage()
    _singluarSetMsg.onSetup(kit, stage)
    _singluarSetMenu.onSetup(kit, stage)
    _singluarSetController.onSetup(kit, stage)
    _singluarSetBuff.onSetup(kit, stage)
    _singluarSetWarehouse.onSetup(kit, stage)
    _singluarSetItem.onSetup(kit, stage)
    _singluarSetAbility.onSetup(kit, stage)
    _singluarSetCaster.onSetup(kit, stage)

    -- updater
    stage.updateRace = function()
        stage.menu.texture("menu\\" .. PlayerLocal().race())
        stage.ctl.texture("bg\\" .. PlayerLocal().race())
    end
    stage.updateLv = function()
        stage.menu_lv.text("奖励级别：" .. PlayerLocal()["mapLv"]())
    end
    stage.updateWelcome = function()
        stage.menu_welcome.text(colour.hex(colour.gold, Game().name()) .. ', 你好 ' .. colour.hex(colour.gold, PlayerLocal().name()))
    end
    stage.updateFn = function()
        for i, t in ipairs(stage.menu_fns) do
            stage.menu_fn[i].txt.text(t[2])
            if (i == 3 and Game().playingQuantity() == 1) then
                stage.menu_fn[i].txt.text(colour.hex(colour.silver, t[2]))
            end
        end
    end
    stage.updateInfoCenter = function()
        stage.menu_infoCenter.text(string.implode("|n", Game().prop("infoCenter")))
    end
    stage.updateAlert = function()
        stage.alert.text(PlayerLocal().alert() or "")
    end

    --- 默认种族、欢迎语、等级
    for _, p in ipairs(Players(table.section(1, 12))) do
        if (p.isPlaying()) then
            async.call(p, function()
                stage.updateRace()
                stage.updateWelcome()
                stage.updateLv()
            end)
        end
    end

    ---@param evtData noteOnPropGame|noteOnPropPlayer
    event.reaction(EVENT.Prop.Change, "_singluarSet", function(evtData)
        if (isObject(evtData.triggerObject, "Game")) then
            if (evtData.key == "playingQuantity") then
                stage.updateFn()
            elseif (evtData.key == "infoCenter") then
                stage.updateInfoCenter()
            end
        elseif (isObject(evtData.triggerObject, "Player")) then
            async.call(evtData.triggerObject, function()
                if (evtData.key == "race") then
                    stage.updateRace()
                elseif (evtData.key == "name") then
                    stage.updateWelcome()
                elseif (evtData.key == "alert") then
                    stage.updateAlert()
                end
            end)
        end
    end)

end)

this.onRefresh(0.03, function()
    ---@type {tips:table,main:FrameBackdrop,miniMap:Frame,miniMapBtns:Frame[],portrait:Frame,portraitShadow:FrameBackdrop,plate:table<string,FrameBackdropTile>,nilDisplay:FrameText,mp:FrameBar,hp:FrameBar,info:table<string,FrameButton|FrameText>,tile:table<string,FrameBar>}
    local stage = this.stage()
    async.call(PlayerLocal(), function()
        _singluarSetController.onRefresh(stage)
        _singluarSetWarehouse.onRefresh(stage)
        _singluarSetItem.onRefresh(stage)
        _singluarSetAbility.onRefresh(stage)
        _singluarSetBuff.onRefresh(stage)
        _singluarSetCaster.onRefresh(stage)
    end)
end)