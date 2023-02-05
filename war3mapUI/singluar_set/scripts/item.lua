-- 单位物品
_singluarSetItem = {
    onSetup = function(kit, stage)

        local kit_s = kit .. '->item'

        stage.item_max = 6

        stage.item = FrameBackdrop(kit_s, FrameGameUI)
            .relation(FRAME_ALIGN_LEFT_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0.1358, 0)
            .size(0.059, 0.134)

        stage.item_weight = FrameText(kit_s .. '->weight', stage.item)
            .relation(FRAME_ALIGN_TOP, stage.item, FRAME_ALIGN_TOP, 0, -0.004)
            .textAlign(TEXT_ALIGN_LEFT)
            .fontSize(9)

        stage.item_itWidth = 0.025
        stage.item_itHeight = stage.item_itWidth * 8 / 6
        local itMargin = 0.0022

        stage.item_btn = {}
        stage.item_charges = {}

        local raw = 2
        for i = 1, stage.item_max do
            local xo = 0.003 + (i - 1) % raw * (stage.item_itWidth + itMargin)
            local yo = -0.025 - (math.ceil(i / raw) - 1) * (itMargin + stage.item_itHeight)
            stage.item_btn[i] = FrameButton(kit_s .. '->btn->' .. i, stage.item)
                .relation(FRAME_ALIGN_LEFT_TOP, stage.item, FRAME_ALIGN_LEFT_TOP, xo, yo)
                .size(stage.item_itWidth, stage.item_itHeight)
                .fontSize(7.5)
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
                    local sel = evtData.triggerPlayer.selection()
                    if (false == isObject(sel, "Unit") or sel.isDestroy()) then
                        return nil
                    end
                    evtData.triggerFrame.childHighLight().show(true)
                    local content = _singluarSetTooltipsBuilder.item(sel.itemSlot().storage()[i], evtData.triggerPlayer)
                    if (content ~= nil) then
                        FrameTooltips()
                            .kit(kit)
                            .relation(FRAME_ALIGN_BOTTOM, stage.item, FRAME_ALIGN_TOP, 0, 0.002)
                            .content(content)
                            .show(true)
                            .onMouseLeftClick(
                            function(ed)
                                FrameTooltips().show(false, 0)
                                local selection = ed.triggerPlayer.selection()
                                if (isObject(selection, "Unit")) then
                                    local it = selection.itemSlot().storage()[i]
                                    if (isObject(it, "Item")) then
                                        if (ed.key == "warehouse") then
                                            sync.send("G_GAME_SYNC", { "item_to_warehouse", it.id() })
                                        elseif (ed.key == "drop") then
                                            sync.send("G_GAME_SYNC", { "item_drop", it.id(), selection.x(), selection.y() })
                                        elseif (ed.key == "pawn") then
                                            sync.send("G_GAME_SYNC", { "item_pawn", it.id() })
                                        elseif (ed.key == "separate") then

                                        end
                                    end
                                end
                            end)
                    end
                end)
                .onMouseLeftClick(
                function(evtData)
                    local selection = evtData.triggerPlayer.selection()
                    if (isObject(selection, "Unit")) then
                        Cursor().itemQuote(selection.itemSlot().storage()[i])
                    end
                end)

            -- 物品使用次数
            stage.item_charges[i] = FrameButton(kit_s .. '->charges->' .. i, stage.item_btn[i].childBorder())
                .relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.item_btn[i], FRAME_ALIGN_RIGHT_BOTTOM, -0.0013, 0.0018)
                .texture('bg\\shadowBlock')
                .fontSize(7)

        end

        --- 注册右键策略
        _singluarSetItemOnRight(stage)

    end,
    onRefresh = function(stage)
        local p = PlayerLocal()
        local tmpData = {
            ---@type Unit
            selection = p.selection(),
            show = false,
            btn = {},
            charges = {},
        }
        -- 初始化数据
        for i = 1, stage.item_max do
            tmpData.btn[i] = {}
            tmpData.charges[i] = 0
        end
        if (isObject(tmpData.selection, 'Unit') and tmpData.selection.isAlive()) then
            tmpData.show = true
            --- 负重显示
            if (tmpData.selection.weight() > 0) then
                tmpData.weight = string.format('负重 %0.1f/%0.1fKG', tmpData.selection.weightCur(), tmpData.selection.weight())
            else
                tmpData.weight = '负重无上限'
            end
            --- 物品控制
            local storage = tmpData.selection.itemSlot().storage()
            for i = 1, stage.item_max, 1 do
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
                            tmpData.btn[i].maskValue = stage.item_itHeight * ab.coolDownRemain() / ab.coolDown() / stage.item_itHeight
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
                        if (tmpData.selection.owner() == PlayerLocal() and ab == Cursor().ability()) then
                            tmpData.btn[i].border = 'btn\\border-gold'
                        end
                    end
                end
            end
        end
        stage.item.show(tmpData.show)
        if (tmpData.show) then
            stage.item_weight.text(tmpData.weight)
            for i = 1, stage.item_max do
                stage.item_btn[i].texture(tmpData.btn[i].texture)
                stage.item_btn[i].border(tmpData.btn[i].border)
                stage.item_btn[i].maskValue(tmpData.btn[i].maskValue)
                stage.item_btn[i].text(tmpData.btn[i].text)
                stage.item_btn[i].show(tmpData.btn[i].show)
                if (tmpData.charges[i] > 0) then
                    local tw = math.max(0.006, string.len(tostring(tmpData.charges[i])) * 0.004)
                    stage.item_charges[i]
                         .size(tw, 0.008)
                         .text(tmpData.charges[i])
                         .show(true)
                else
                    stage.item_charges[i].show(false)
                end
            end
        end
    end,
}