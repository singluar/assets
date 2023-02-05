-- 套件提示管理
_singluarSetTooltipsBuilder = {

    ---@type fun(ab:Ability|AbilityTpl,lvOffset:number):table|nil
    ability = function(ab, lvOffset)
        if (instanceof(ab, "AbilityTpl") == false) then
            return nil
        end
        local icons = {
            { 'coolDown', '15DF89', '秒' },
            { 'hpCost', 'DE5D43', '血' },
            { 'mpCost', '83B3E4', '蓝' },
            { "worth" },
        }
        lvOffset = lvOffset or 0
        local lv = lvOffset + ab.level()
        if (lv > ab.levelMax()) then
            return nil
        end
        local tips
        if (lvOffset > 0) then
            tips = Game().combineDescription(ab, { level = lv }, "abilityBase", "<D>", "attributes", "abilityLvPoint")
        else
            tips = Game().combineDescription(ab, nil, "abilityBase", "<D>", "attributes")
        end
        local content = {
            tips = tips,
            icons = {},
            bars = {},
        }
        for _, c in ipairs(icons) do
            local method = c[1]
            if (method == "worth") then
                local wv = ab.worthCost(lv)
                if (wv ~= nil) then
                    local wk = {
                        { "lumber", "C49D5A", "木" },
                        { "gold", "ECD104", "金" },
                        { "silver", "E3E3E3", "银" },
                        { "copper", "EC6700", "铜" }
                    }
                    for _, w in ipairs(wk) do
                        local key = w[1]
                        local color = w[2]
                        local uit = w[3]
                        local val = math.round(wv[key] or 0)
                        if (val > 0) then
                            if (uit ~= nil) then
                                val = val .. " " .. uit
                            end
                            table.insert(content.icons, {
                                texture = "icon\\" .. key,
                                text = colour.hex(color, val),
                            })
                        end
                    end
                end
            else
                local color = c[2]
                local uit = c[3]
                local val = 0
                if (method == "coolDown") then
                    val = ab.coolDown(lv)
                elseif (method == "hpCost") then
                    val = ab.hpCost(lv)
                elseif (method == "mpCost") then
                    val = ab.mpCost(lv)
                end
                if (val > 0) then
                    if (uit ~= nil) then
                        val = val .. ' ' .. uit
                    end
                    table.insert(content.icons, {
                        texture = "icon\\" .. method,
                        text = colour.hex(color, val),
                    })
                end
            end
        end
        if (isObject(ab, "Ability")) then
            if (lv == ab.level() and lv < ab.levelMax()) then
                if (ab.exp() > 0) then
                    local cur = ab.exp() or 0
                    local prev = ab.expNeed(lv) or 0
                    local need = ab.expNeed() or 0
                    local percent = math.trunc((cur - prev) / (need - prev), 3)
                    if (percent ~= nil) then
                        table.insert(content.bars, {
                            texture = "tile\\yellow",
                            text = colour.hex("E2C306", "经验：" .. math.floor(cur - prev) .. '/' .. math.ceil(need - prev)),
                            ratio = percent,
                            width = 0.10,
                            height = 0.001,
                        })
                    end
                end
            end
        end
        return content
    end,

    ---@type fun(it:Item|ItemTpl,whichPlayer:Player):table|nil
    item = function(it, whichPlayer)
        if (instanceof(it, "ItemTpl") == false) then
            return nil
        end
        local icons = {
            { 'lumber', 'C49D5A', '木' },
            { 'gold', 'ECD104', '金' },
            { 'silver', 'E3E3E3', '银' },
            { 'copper', 'EC6700', '铜' }
        }
        local content = {
            tips = Game().combineDescription(it, nil, "itemBase", "<D>", "attributes"),
            icons = {},
            bars = {},
            list = {},
        }
        if (isObject(it.bindUnit(), "Unit") and it.bindUnit().owner() == whichPlayer) then
            if (isObject(whichPlayer, "Player")) then
                local wor = it.worth()
                local cale = Game().worthCale(wor, "*", whichPlayer.sell() * 0.01)
                for _, c in ipairs(icons) do
                    local key = c[1]
                    local color = c[2]
                    local uit = c[3]
                    local val = math.floor(cale[key] or 0)
                    if (val > 0) then
                        if (uit ~= nil) then
                            val = val .. ' ' .. uit
                        end
                        table.insert(content.icons, {
                            texture = "icon\\" .. key,
                            text = colour.hex(color, val),
                        })
                    end
                end
            end
            if (isObject(it, "Item")) then
                local lv = it.level()
                if (lv < it.levelMax()) then
                    if (it.exp() > 0) then
                        local cur = it.exp() or 0
                        local prev = it.expNeed(lv) or 0
                        local need = it.expNeed() or 0
                        local percent = math.trunc((cur - prev) / (need - prev), 3)
                        if (percent ~= nil) then
                            table.insert(content.bars, {
                                texture = "tile\\white",
                                text = "经验：" .. math.floor(cur - prev) .. '/' .. math.ceil(need - prev),
                                ratio = percent,
                                width = 0.10,
                                height = 0.001,
                            })
                        end
                    end
                end
                if (whichPlayer.warehouseSlot().empty() > 0) then
                    table.insert(content.list, { key = "warehouse", text = colour.hex(colour.skyblue, "放入仓库"), highlight = true, textAlign = TEXT_ALIGN_LEFT })
                else
                    table.insert(content.list, { text = colour.hex(colour.darkgray, "仓库已满"), highlight = false, textAlign = TEXT_ALIGN_LEFT })
                end
                if (it.dropable()) then
                    table.insert(content.list, { key = "drop", text = colour.hex(colour.indianred, "丢弃"), highlight = true, textAlign = TEXT_ALIGN_CENTER })
                else
                    table.insert(content.tips, colour.hex(colour.darkgray, "|n不可丢弃"))
                end
                if (it.pawnable()) then
                    table.insert(content.list, { key = "pawn", text = colour.hex(colour.gold, "出售"), highlight = true, textAlign = TEXT_ALIGN_CENTER })
                else
                    table.insert(content.tips, colour.hex(colour.darkgray, "|n不可出售"))
                end
                if (1 == 0) then
                    table.insert(content.list, { key = "separate", text = colour.hex(colour.purpleLight, "拆分"), highlight = true, textAlign = TEXT_ALIGN_CENTER })
                end
            end
        end
        return content
    end,

    ---@type fun(it:Item|ItemTpl,whichPlayer:Player):table|nil
    warehouse = function(it, whichPlayer)
        if (instanceof(it, "ItemTpl") == false) then
            return nil
        end
        local icons = {
            { 'lumber', 'C49D5A', '木' },
            { 'gold', 'ECD104', '金' },
            { 'silver', 'E3E3E3', '银' },
            { 'copper', 'EC6700', '铜' }
        }
        local content = {
            tips = Game().combineDescription(it, nil, "itemBase", "<D>", "attributes"),
            icons = {},
            bars = {},
            list = {},
        }
        if (isObject(whichPlayer, "Player")) then
            local wor = it.worth()
            local cale = Game().worthCale(wor, "*", whichPlayer.sell() * 0.01)
            for _, c in ipairs(icons) do
                local key = c[1]
                local color = c[2]
                local uit = c[3]
                local val = math.floor(cale[key] or 0)
                if (val > 0) then
                    if (uit ~= nil) then
                        val = val .. ' ' .. uit
                    end
                    table.insert(content.icons, {
                        texture = "icon\\" .. key,
                        text = colour.hex(color, val),
                    })
                end
            end
        end
        if (isObject(it, "Item")) then
            local lv = it.level()
            if (lv < it.levelMax()) then
                if (it.exp() > 0) then
                    local cur = it.exp() or 0
                    local prev = it.expNeed(lv) or 0
                    local need = it.expNeed() or 0
                    local percent = math.trunc((cur - prev) / (need - prev), 3)
                    if (percent ~= nil) then
                        table.insert(content.bars, {
                            texture = "tile\\white",
                            text = "经验：" .. math.floor(cur - prev) .. '/' .. math.ceil(need - prev),
                            ratio = percent,
                            width = 0.10,
                            height = 0.001,
                        })
                    end
                end
            end
            local selection = whichPlayer.selection()
            if (isObject(selection, "Unit") and selection.owner() == whichPlayer) then
                if (selection.itemSlot().empty() > 0) then
                    table.insert(content.list, { key = "item", text = colour.hex(colour.skyblue, "放入背包"), highlight = true, textAlign = TEXT_ALIGN_LEFT })
                else
                    table.insert(content.list, { text = colour.hex(colour.darkgray, "背包已满"), highlight = false, textAlign = TEXT_ALIGN_LEFT })
                end
                if (it.dropable()) then
                    table.insert(content.list, { key = "drop", text = colour.hex(colour.indianred, "丢弃"), highlight = true, textAlign = TEXT_ALIGN_CENTER })
                else
                    table.insert(content.tips, colour.hex(colour.darkgray, "|n不可丢弃"))
                end
            end
            if (it.pawnable()) then
                table.insert(content.list, { key = "pawn", text = colour.hex(colour.gold, "出售"), highlight = true, textAlign = TEXT_ALIGN_CENTER })
            else
                table.insert(content.tips, colour.hex(colour.darkgray, "|n不可出售"))
            end
            if (1 == 0) then
                table.insert(content.list, { key = "separate", text = colour.hex(colour.purpleLight, "拆分"), highlight = true, textAlign = TEXT_ALIGN_CENTER })
            end
        end
        return content
    end
}