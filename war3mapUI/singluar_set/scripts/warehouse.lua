-- 玩家仓库
_singluarSetWarehouse = {
    onSetup = function(kit, stage)

        local kit_s = kit .. '->warehouse'

        stage.warehouse_max = Game().warehouseSlot()

        stage.warehouse_resIcon = {}
        stage.warehouse_resInfo = {}
        stage.warehouse_resAllow = {}
        stage.warehouse_resOcc = {
            gold = { texture = 'icon\\gold', color = 'FED112', occ = 3, },
            silver = { texture = 'icon\\silver', color = 'BEC8EB', occ = 2 },
            copper = { texture = 'icon\\copper', color = 'D7AE8E', occ = 2 },
        }
        stage.warehouse_resOccSum = 0
        local res = Game().worth()
        res.forEach(function(key, value)
            if (stage.warehouse_resOcc[key]) then
                stage.warehouse_resOcc[key].name = value.name
                stage.warehouse_resOccSum = stage.warehouse_resOccSum + stage.warehouse_resOcc[key].occ
                table.insert(stage.warehouse_resAllow, key)
            else
                stage.warehouse_resOcc[key] = { name = value.name }
            end
        end)

        stage.warehouse = FrameBackdrop(kit_s, FrameGameUI)
            .relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0.274, 0)
            .size(0.152, 0.134)

        stage.warehouse_cell = FrameText(kit_s .. '->stgTxt', stage.warehouse)
            .relation(FRAME_ALIGN_CENTER, stage.warehouse, FRAME_ALIGN_TOP, 0, -0.008)
            .textAlign(TEXT_ALIGN_LEFT)
            .fontSize(10)

        local x = 0.005
        local xs = 0.146 / stage.warehouse_resOccSum
        for i, k in ipairs(stage.warehouse_resAllow) do
            local n = stage.warehouse_resOcc[k].name
            local opt = stage.warehouse_resOcc[k]
            if (i > 1) then
                x = x + stage.warehouse_resOcc[stage.warehouse_resAllow[i - 1]].occ * xs
            end
            stage.warehouse_resIcon[i] = FrameButton(kit_s .. '->res->' .. k, stage.warehouse)
                .relation(FRAME_ALIGN_LEFT_TOP, stage.warehouse, FRAME_ALIGN_LEFT_TOP, x, -0.022)
                .size(0.008, 0.010667)
                .texture(opt.texture)
                .onMouseLeave(function(_) FrameTooltips().show(false, 0) end)
                .onMouseEnter(
                function(evtData)
                    --- 资源显示
                    ---@type Player
                    local p = evtData.triggerPlayer
                    local r = p.worth()
                    local tips = {
                        '资源名称: ' .. n,
                        '资源总量: ' .. math.floor(r[k] or 0),
                        '资源获得率: ' .. math.format(p.worthRatio(), 2) .. '%',
                    }
                    local cov = Game().worthConvert(k)
                    if (cov ~= nil) then
                        table.insert(tips, '经济体系: ' .. '1' .. stage.warehouse_resOcc[cov[1]].name .. ' = ' .. cov[2] .. n)
                    end
                    FrameTooltips()
                        .kit(kit)
                        .relation(FRAME_ALIGN_BOTTOM, stage.warehouse_resIcon[i], FRAME_ALIGN_TOP, 0, 0.002)
                        .content({ tips = tips })
                        .show(true)
                end)
            stage.warehouse_resInfo[i] = FrameText(kit_s .. '->resTxt->' .. k, stage.warehouse_resIcon[i])
                .relation(FRAME_ALIGN_LEFT, stage.warehouse_resIcon[i], FRAME_ALIGN_RIGHT, 0.001, 0)
                .textAlign(TEXT_ALIGN_LEFT)
                .fontSize(9)
        end

        stage.warehouse_itWidth = 0.0218
        stage.warehouse_itHeight = stage.warehouse_itWidth * 8 / 6
        local itMargin = 0.00202

        stage.warehouse_btn = {}
        stage.warehouse_charges = {}

        local raw = 6
        for i = 1, stage.warehouse_max do
            local xo = 0.006 + (i - 1) % raw * (stage.warehouse_itWidth + itMargin)
            local yo = -0.038 - (math.ceil(i / raw) - 1) * (itMargin + stage.warehouse_itHeight)
            stage.warehouse_btn[i] = FrameButton(kit_s .. '->btn->' .. i, stage.warehouse)
                .relation(FRAME_ALIGN_LEFT_TOP, stage.warehouse, FRAME_ALIGN_LEFT_TOP, xo, yo)
                .size(stage.warehouse_itWidth, stage.warehouse_itHeight)
                .fontSize(7)
                .mask('btn\\mask')
                .show(false)
                .onMouseLeave(
                function(evtData)
                    evtData.triggerFrame.childHighLight().show(false)
                    FrameTooltips().show(false, 0.5)
                end)
                .onMouseEnter(
                function(evtData)
                    if (Cursor().following()) then
                        return
                    end
                    evtData.triggerFrame.childHighLight().show(true)
                    local content = _singluarSetTooltipsBuilder.warehouse(evtData.triggerPlayer.warehouseSlot().storage()[i], evtData.triggerPlayer)
                    if (content ~= nil) then
                        FrameTooltips()
                            .kit(kit)
                            .relation(FRAME_ALIGN_BOTTOM, stage.warehouse, FRAME_ALIGN_TOP, 0, 0.002)
                            .content(content)
                            .show(true)
                            .onMouseLeftClick(
                            function(ed)
                                FrameTooltips().show(false, 0)
                                local it = ed.triggerPlayer.warehouseSlot().storage()[i]
                                if (isObject(it, "Item")) then
                                    if (ed.key == "item") then
                                        local selection = ed.triggerPlayer.selection()
                                        if (isObject(selection, "Unit")) then
                                            sync.send("G_GAME_SYNC", { "warehouse_to_item", it.id() })
                                        end
                                    elseif (ed.key == "drop") then
                                        local selection = ed.triggerPlayer.selection()
                                        if (isObject(selection, "Unit")) then
                                            sync.send("G_GAME_SYNC", { "item_drop", it.id(), selection.x(), selection.y() })
                                        end
                                    elseif (ed.key == "pawn") then
                                        sync.send("G_GAME_SYNC", { "item_pawn", it.id() })
                                    elseif (ed.key == "separate") then

                                    end
                                end
                            end)
                    end
                end)

            -- 物品使用次数
            stage.warehouse_charges[i] = FrameButton(kit_s .. '->charges->' .. i, stage.warehouse_btn[i].childBorder())
                .relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.warehouse_btn[i], FRAME_ALIGN_RIGHT_BOTTOM, -0.0011, 0.00146)
                .texture('bg\\shadowBlock')
                .fontSize(6.5)

        end
    end,
    ---@param whichPlayer Player
    onRefresh = function(stage)
        local p = PlayerLocal()
        local tmpData = {
            ---@type Unit
            selection = p.selection(),
            cell = nil,
            resInfo = {},
            btn = {},
            charges = {},
        }
        -- 初始化数据
        for i = 1, stage.warehouse_max do
            tmpData.btn[i] = {}
            tmpData.charges[i] = 0
        end
        --- 仓存显示
        local qty = #(p.warehouseSlot())
        if (qty >= stage.warehouse_max) then
            tmpData.cell = p.name() .. ' 的仓库  ' .. colour.hex(colour.indianred, qty .. '/' .. stage.warehouse_max)
        else
            tmpData.cell = p.name() .. ' 的仓库  ' .. qty .. '/' .. stage.warehouse_max
        end
        --- 资源显示
        local r = p.worth()
        for i, k in ipairs(stage.warehouse_resAllow) do
            tmpData.resInfo[i] = colour.hex(stage.warehouse_resOcc[k].color, math.floor(r[k] or 0))
        end
        --- 仓库物品控制
        local storage = p.warehouseSlot().storage()
        for i = 1, stage.warehouse_max do
            ---@type Item
            local it = storage[i]
            if (false == isObject(it, 'Item')) then
                tmpData.btn[i].show = false
            else
                tmpData.btn[i].show = true
                tmpData.btn[i].texture = it.icon()
                tmpData.btn[i].text = ''
                tmpData.btn[i].border = 'btn\\border-white'
                tmpData.btn[i].maskValue = 0
                tmpData.charges[i] = math.floor(it.charges())
                local ab = it.ability()
                if (isObject(ab, "Ability")) then
                    if (ab.coolDown() > 0 and ab.coolDownRemain() > 0) then
                        tmpData.btn[i].maskValue = stage.warehouse_itHeight * ab.coolDownRemain() / ab.coolDown() / stage.warehouse_itHeight
                        tmpData.btn[i].text = math.format(ab.coolDownRemain(), 1)
                    elseif (ab.isProhibiting() == true) then
                        local reason = ab.prohibitReason()
                        tmpData.btn[i].maskValue = 1
                        if (reason == nil) then
                            tmpData.btn[i].text = ''
                        else
                            tmpData.btn[i].border = 'Singluar\\ui\\nil.tga'
                            tmpData.btn[i].text = reason
                        end
                    end
                end
            end
        end
        stage.warehouse_cell.text(tmpData.cell)
        for i, _ in ipairs(stage.warehouse_resAllow) do
            stage.warehouse_resInfo[i].text(tmpData.resInfo[i])
        end
        for i = 1, stage.warehouse_max do
            if (false == isObject(tmpData.selection, "Unit") or tmpData.selection.owner() ~= p) then
                stage.warehouse_btn[i].alpha(50)
            else
                stage.warehouse_btn[i].alpha(255)
            end
            stage.warehouse_btn[i].texture(tmpData.btn[i].texture)
            stage.warehouse_btn[i].border(tmpData.btn[i].border)
            stage.warehouse_btn[i].maskValue(tmpData.btn[i].maskValue)
            stage.warehouse_btn[i].text(tmpData.btn[i].text)
            stage.warehouse_btn[i].show(tmpData.btn[i].show)
            if (tmpData.charges[i] > 0) then
                local tw = math.max(0.005, string.len(tostring(tmpData.charges[i])) * 0.0036)
                stage.warehouse_charges[i]
                     .size(tw, 0.008)
                     .text(tmpData.charges[i])
                     .show(true)
            else
                stage.warehouse_charges[i].show(false)
            end
        end
    end,
}