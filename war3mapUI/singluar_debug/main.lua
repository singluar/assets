--[[
    Singluar debug提示
    Author: hunzsig
]]

if (DEBUGGING) then

    collectgarbage("collect")
    local ram = collectgarbage("count")

    local kit = 'singluar_debug'

    local this = UIKit(kit)

    this.onSetup(function()
        local stage = this.stage()
        stage.main = FrameText(kit, FrameGameUI)
            .relation(FRAME_ALIGN_LEFT_BOTTOM, FrameGameUI, FRAME_ALIGN_LEFT_BOTTOM, 0.001, 0.142)
            .textAlign(TEXT_ALIGN_LEFT)
            .fontSize(8)

        stage.ram = FrameText(kit .. "->ram", FrameGameUI)
            .adaptive(true)
            .relation(FRAME_ALIGN_TOP, FrameGameUI, FRAME_ALIGN_TOP, -0.18, -0.024)
            .textAlign(TEXT_ALIGN_LEFT)
            .fontSize(8)

        stage.mark = FrameBackdrop(kit .. "->mark", FrameGameUI)
            .relation(FRAME_ALIGN_CENTER, FrameGameUI, FRAME_ALIGN_CENTER, 0, 0)
            .size(2, 2)
            .alpha(100)
            .texture(TEAM_COLOR_BLP_BLACK)
            .show(false)

        ---@type FrameBackdropTile[]
        stage.line = {}
        local graduation = 0.05
        local texture = TEAM_COLOR_BLP_YELLOW
        local txtColor = "ffe600"
        for i = 1, math.floor(0.6 / graduation - 0.5), 1 do
            local tile = FrameBackdropTile(kit .. "->horizontal->" .. i, FrameGameUI)
                .relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0, graduation * i)
                .size(2, 0.001)
                .texture(texture)
                .show(false)
            FrameText(kit .. "->horizontal->txt->" .. i, tile)
                .relation(FRAME_ALIGN_LEFT, tile, FRAME_ALIGN_LEFT, 0.002, 0.01)
                .textAlign(TEXT_ALIGN_LEFT)
                .fontSize(12)
                .text(colour.hex(txtColor, graduation * i))
            table.insert(stage.line, tile)
        end
        for i = 1, math.floor(0.8 / graduation - 0.5), 1 do
            local tile = FrameBackdropTile(kit .. "->vertical->" .. i, FrameGameUI)
                .relation(FRAME_ALIGN_LEFT, FrameGameUI, FRAME_ALIGN_LEFT, graduation * i, 0)
                .size(0.001, 2)
                .texture(texture)
                .show(false)
            FrameText(kit .. "->vertical->txt->" .. i, tile)
                .relation(FRAME_ALIGN_BOTTOM, tile, FRAME_ALIGN_BOTTOM, 0.01, 0.01)
                .textAlign(TEXT_ALIGN_LEFT)
                .fontSize(12)
                .text(colour.hex(txtColor, graduation * i))
            table.insert(stage.line, tile)
        end

        local types = { "all", "max" }
        local typesLabel = {
            all = "总共",
            max = "最大值",
            ["+tmr"] = "计时器",
            ["+ply"] = "玩家",
            ["+frc"] = "玩家势力",
            ["+flt"] = "过滤器",
            ["+w3u"] = "单位",
            ["+w3d"] = "可破坏物",
            ["+grp"] = "单位组",
            ["+rct"] = "区域",
            ["+snd"] = "声音",
            ["+que"] = "任务",
            ["+trg"] = "触发器",
            ["+tac"] = "触发器动作",
            ["+EIP"] = "对点特效",
            ["+EIm"] = "附着特效",
            ["+loc"] = "点",
            ["pcvt"] = "玩家聊天事件",
            ["pevt"] = "玩家事件",
            ["uevt"] = "单位事件",
            ["tcnd"] = "触发器条件",
            ["wdvt"] = "可破坏物事件",
            ["+cst"] = "镜头",
            ["+dlg"] = "对话框",
            ["+dlb"] = "对话框按钮",
            ["devt"] = "对话框事件",
        }
        stage.costAvg = stage.costAvg or {}
        stage.mem = function()
            local cost = (collectgarbage("count") - ram) / (1024 << 1)
            if (stage.costMax == nil or stage.costMax < cost) then
                stage.costMax = cost
            end
            local avg = 0
            if (#stage.costAvg < 100) then
                table.insert(stage.costAvg, cost)
                avg = table.average(stage.costAvg)
            else
                avg = table.average(stage.costAvg)
                stage.costAvg = { avg }
            end
            return {
                "FPS : " .. math.format(japi.FPS(), 1),
                colour.hex(colour.skyblue, "平均 : " .. math.format(avg, 3) .. ' MB'),
                colour.hex(colour.indianred, "最大 : " .. math.format(stage.costMax, 3) .. ' MB'),
                colour.hex(colour.gold, "当前 : " .. math.format(cost, 3) .. ' MB'),
            }
        end
        stage.debug = function()
            local count = { all = 0, max = J.handleMax() }
            for i = 1, count.max do
                local h = 0x100000 + i
                local info = J.handleDef(h)
                if (info and info.type) then
                    if (not table.includes(types, info.type)) then
                        table.insert(types, info.type)
                    end
                    if (count[info.type] == nil) then
                        count[info.type] = 0
                    end
                    count.all = count.all + 1
                    count[info.type] = count[info.type] + 1
                end
            end
            local txts = { "  [J句柄]" }
            for _, t in ipairs(types) do
                table.insert(txts, "  " .. (typesLabel[t] or t) .. " : " .. (count[t] or 0))
            end
            local i = 0
            for _ in pairs(bop.i2o) do
                i = i + 1
            end
            table.insert(txts, "|n  [S内核]")
            table.insert(txts, "  对象 : " .. i)
            if (group._d.Unit) then table.insert(txts, "  单位 : " .. group._d.Unit.count()) end
            if (group._d.Item) then table.insert(txts, "  物品 : " .. group._d.Item.count()) end
            table.insert(txts, "  漂浮模型 : " .. _ttg_limiter)
            i = 0
            for _, k in pairs(time.kernel) do
                for _, _ in pairs(k) do
                    i = i + 1
                end
            end
            table.insert(txts, "  计时器 : " .. i)
            return txts
        end

    end)

    this.onRefresh(0.3, function()
        ---@type {main:FrameText,debug:fun():table<number,number>}
        local stage = this.stage()
        local msg = stage.debug()
        local mem = stage.mem()
        local p = PlayerLocal()
        async.call(p, function()
            if (p.isPlaying() and p.isComputer() == false) then
                stage.main.text(string.implode('|n', msg))
                stage.ram.text(string.implode('   ', mem))
                local show = japi.DzIsKeyDown(KEYBOARD.Control)
                stage.mark.show(show)
                for _, l in ipairs(stage.line) do
                    l.show(show)
                end
            end
        end)
    end)
end