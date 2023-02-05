_singluarSetController = {
    onSetup = function(kit, stage)

        local kit_s = kit .. '->ctl'

        -- 设置下方黑边
        japi.DzFrameEditBlackBorders(0, 0.125)

        -- 主背景
        stage.ctl = FrameBackdrop(kit_s, FrameGameUI)
            .absolut(FRAME_ALIGN_BOTTOM, 0, 0)
            .size(0.8, 0.1541666667)

        stage.ctl_bigBarWidth = 0.186
        stage.ctl_bigBarHeight = 0.016
        stage.ctl_tileX = 0.130
        stage.ctl_tileWidth = 0.060
        stage.ctl_tileHeight = 0.002
        stage.ctl_tileTypes = {
            { 'punish', 'yellow' },
            { 'exp', 'white' },
            { 'period', 'white' },
        }
        stage.ctl_RxMMP = 0.124
        stage.ctl_RxMMPI = 0.012
        stage.ctl_tips = {}

        -- 小地图
        stage.ctl_miniMap = Frame(kit_s .. '->minimap', japi.DzFrameGetMinimap(), nil)
            .relation(FRAME_ALIGN_LEFT_BOTTOM, stage.ctl, FRAME_ALIGN_LEFT_BOTTOM, 0.005, 0.006)
            .size(stage.ctl_RxMMP * 0.75, stage.ctl_RxMMP)

        --- 小地图按钮
        -----@type table<number,Frame>
        stage.ctl_miniMapBtns = {}
        local offset = {
            { 0.0020, -0.007 },
            { 0.0023, -0.007 - 0.021 },
            { 0.0022, -0.007 - 0.021 - 0.018 },
            { 0.0023, -0.007 - 0.021 - 0.018 - 0.018 },
            { 0.0023, -0.007 - 0.021 - 0.018 - 0.018 - 0.025 },
        }
        for i = 0, 4 do
            stage.ctl_miniMapBtns[i] = Frame(kit_s .. '->minimap->btn->' .. i, japi.DzFrameGetMinimapButton(i), nil)
                .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_miniMap, FRAME_ALIGN_RIGHT_TOP, offset[i + 1][1], offset[i + 1][2])
                .size(0.013, 0.013)
        end

        -- 单位头像
        stage.ctl_portrait = Frame(kit_s .. '->portrait', japi.DzFrameGetPortrait(), nil)
            .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_miniMap, FRAME_ALIGN_RIGHT_TOP, 0.140, -0.004)
            .size(0.090, 0.120)

        -- 单位头像阴影
        stage.ctl_portraitShadow = FrameBackdrop(kit_s .. '->portraitShadow', stage.ctl_portrait)
            .relation(FRAME_ALIGN_BOTTOM, stage.ctl_portrait, FRAME_ALIGN_BOTTOM, 0, 0)
            .size(0.090, 0.120)
            .texture('bg\\shadowUnit')

        -- 面板
        local plateTypes = { 'Nil', 'Unit', 'Item' }
        ---@type table<string,FrameBackdropTile[]>
        stage.ctl_plate = {}
        ---@type table<string,FrameButton>
        stage.ctl_info = {}
        --
        stage.ctl_mouseLeave = function(evtData)
            async.call(evtData.triggerPlayer, function()
                FrameTooltips().show(false, 0)
            end)
        end
        stage.ctl_mouseEnter = function(evtData, field)
            ---@type Player
            local triggerPlayer = evtData.triggerPlayer
            local selection = triggerPlayer.selection()
            if (selection == nil) then
                return
            end
            local primary = selection.primary()
            local tips = {}
            local x = 0
            local y = -0.01
            if (field == 'portrait') then
                x = 0
                y = 0.004
                if (primary ~= nil) then
                    table.insert(tips, colour.hex(colour.gold, '主属性: ' .. primary.label))
                    table.insert(tips, colour.hex(colour.indianred, '力量: ' .. math.floor(selection.str())))
                    table.insert(tips, colour.hex(colour.lawngreen, '敏捷: ' .. math.floor(selection.agi())))
                    table.insert(tips, colour.hex(colour.skyblue, '智力: ' .. math.floor(selection.int())))
                else
                    table.insert(tips, '普通作战单位')
                end
                if (selection.exp() > 0) then
                    table.insert(tips, '经验: ' .. selection.exp())
                    table.insert(tips, '等级: ' .. selection.level() .. '/' .. selection.levelMax())
                else
                    table.insert(tips, '等级: ' .. selection.level())
                end
            elseif (field == 'attack') then
                if (false == selection.isAttackAble()) then
                    table.insert(tips, colour.hex(colour.indianred, '无法攻击'))
                else
                    table.insert(tips, '基础攻击: ' .. math.floor(selection.attack()))
                    table.insert(tips, '攻击浮动: ' .. math.floor(selection.attackRipple()))
                    table.insert(tips, '伤害<加成>: ' .. math.format(selection.damageIncrease(), 2) .. '%')
                    table.insert(tips, '攻击吸血: ' .. math.format(selection.hpSuckAttack(), 2) .. '%')
                    table.insert(tips, '技能吸血: ' .. math.format(selection.hpSuckAbility(), 2) .. '%')
                    table.insert(tips, '攻击吸魔: ' .. math.format(selection.mpSuckAttack(), 2) .. '%')
                    table.insert(tips, '技能吸魔: ' .. math.format(selection.mpSuckAbility(), 2) .. '%')
                end
            elseif (field == 'attackSpeed') then
                table.insert(tips, '攻速<加成>: ' .. math.format(selection.attackSpeed(), 2) .. '%')
                table.insert(tips, '攻击范围: ' .. math.floor(selection.attackRange()))
                table.insert(tips, '命中<加成>: ' .. math.format(selection.aim(), 2) .. '%')
            elseif (field == 'attackRange') then
                if (selection.attackRange() < 250) then
                    table.insert(tips, '武器: 近战')
                else
                    if (selection.isRanged() == false) then
                        table.insert(tips, '武器: 极速')
                    elseif (selection.lightning() ~= nil) then
                        local l = selection.lightning()
                        table.insert(tips, '武器: 闪电')
                        if (l.scatter() > 0 and l.radius() > 0) then
                            table.insert(tips, '散射数量: ' .. math.floor(l.scatter()))
                            table.insert(tips, '散射范围: ' .. math.floor(l.radius()))
                        end
                        if (l.focus() > 0) then
                            table.insert(tips, '聚焦数量: ' .. math.floor(l.focus()))
                        end
                    else
                        local m = selection.missile()
                        if (m.homing()) then
                            table.insert(tips, '武器: 远程')
                        else
                            table.insert(tips, '武器: 远程[自动跟踪]')
                        end
                        table.insert(tips, '发射速度: ' .. math.floor(m.speed()))
                        table.insert(tips, '发射加速度: ' .. math.floor(m.acceleration()))
                        table.insert(tips, '发射高度: ' .. math.floor(m.height()))
                        if (m.scatter() > 0 and m.radius() > 0) then
                            table.insert(tips, '散射数量: ' .. math.floor(m.scatter()))
                            table.insert(tips, '散射范围: ' .. math.floor(m.radius()))
                        end
                        if (m.gatlin() > 0) then
                            table.insert(tips, '多段数量: ' .. math.floor(m.gatlin()))
                        end
                        if (m.reflex() > 0) then
                            table.insert(tips, '反弹数量: ' .. math.floor(m.reflex()))
                        end
                    end
                end
                table.insert(tips, '基准频率: ' .. math.format(selection.attackSpaceBase(), 2) .. ' 秒/击')
            elseif (field == 'knocking') then
                table.insert(tips, '暴击<加成>: ' .. math.format(selection.crit(), 2) .. '%')
                table.insert(tips, '暴击<几率>: ' .. math.format(selection.odds("crit"), 2) .. '%')
                table.insert(tips, '暴击<抗性>: ' .. math.format(selection.resistance('crit'), 2) .. '%')
            elseif (field == 'sight') then
                table.insert(tips, '白天视野: ' .. selection.sight())
                table.insert(tips, '黑夜视野: ' .. selection.nsight())
            elseif (field == 'defend') then
                table.insert(tips, '防御: ' .. selection.defend())
                table.insert(tips, '治疗<加成>: ' .. selection.cure() .. '%')
                table.insert(tips, '减伤<比例>: ' .. selection.hurtReduction() .. '%')
                table.insert(tips, '受伤<加深>: ' .. selection.hurtIncrease() .. '%')
                table.insert(tips, '反伤<几率>: ' .. selection.odds("hurtRebound") .. '%')
                table.insert(tips, '反伤<比例>: ' .. selection.hurtRebound() .. '%')
                table.insert(tips, '僵硬<抗性>: ' .. selection.resistance('punish') .. '%')
                table.insert(tips, '攻击吸血<抗性>: ' .. selection.resistance('hpSuck') .. '%')
                table.insert(tips, '技能吸血<抗性>: ' .. selection.resistance('hpSuckSpell') .. '%')
                table.insert(tips, '攻击吸魔<抗性>: ' .. selection.resistance('mpSuck') .. '%')
                table.insert(tips, '技能吸魔<抗性>: ' .. selection.resistance('mpSuckSpell') .. '%')
            elseif (field == 'move') then
                table.insert(tips, '移动速度: ' .. selection.move())
                table.insert(tips, '移动类型: ' .. selection.moveType().label)
                table.insert(tips, '回避<几率>: ' .. selection.avoid() .. '%')
            end
            if (field == 'portrait') then
                FrameTooltips()
                    .kit(kit)
                    .relation(FRAME_ALIGN_LEFT_BOTTOM, stage.ctl_info[field], FRAME_ALIGN_LEFT_TOP, x, y)
                    .content({ tips = tips })
                    .showGradient(true, { duration = 0.1, y = 0.002 })
            else
                FrameTooltips()
                    .kit(kit)
                    .relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.ctl_info[field], FRAME_ALIGN_LEFT_BOTTOM, x, y)
                    .content({ tips = tips })
                    .showGradient(true, { duration = 0.1, x = -0.001 })
            end
        end
        --
        for _, t in ipairs(plateTypes) do
            local kitP = kit_s .. '->' .. t
            stage.ctl_plate[t] = FrameBackdropTile(kitP, stage.ctl)
                .relation(FRAME_ALIGN_BOTTOM, stage.ctl, FRAME_ALIGN_BOTTOM, 0, 0)
                .size(0.6, 0.18)
                .show(false)

            if (t == 'Nil') then
                stage.ctl_nilDisplay = FrameText(kitP .. '->description', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_CENTER, stage.ctl_plate[t], FRAME_ALIGN_CENTER, -0.18, -0.03)
                    .textAlign(TEXT_ALIGN_CENTER)
                    .fontSize(10)
            elseif (t == 'Unit') then
                stage.ctl_mp = FrameBar(kitP .. '->mp', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_BOTTOM, stage.ctl_plate[t], FRAME_ALIGN_LEFT_BOTTOM, 0.2342, 0.007)
                    .texture('value', 'bar\\blue')
                    .fontSize(LAYOUT_ALIGN_CENTER, 10.5)
                    .fontSize(LAYOUT_ALIGN_RIGHT, 9)
                    .value(0, stage.ctl_bigBarWidth, stage.ctl_bigBarHeight)

                stage.ctl_hp = FrameBar(kitP .. '->hp', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_BOTTOM, stage.ctl_mp, FRAME_ALIGN_TOP, 0, 0.005)
                    .texture('value', 'bar\\green')
                    .fontSize(LAYOUT_ALIGN_CENTER, 10.5)
                    .fontSize(LAYOUT_ALIGN_RIGHT, 9)
                    .value(0, stage.ctl_bigBarWidth, stage.ctl_bigBarHeight)

                -- 大头信息
                stage.ctl_info.portrait = FrameLabel(kitP .. '->info->portrait', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_BOTTOM, stage.ctl_portrait, FRAME_ALIGN_LEFT_BOTTOM, 0.005, 0.006)
                    .size(0.01, 0.012)
                    .textAlign(TEXT_ALIGN_LEFT)
                    .fontSize(10)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'portrait') end)

                -- 7个信息
                local infoMargin = -0.005
                local infoWidthL = 0.058
                local infoWidthR = 0.04
                local infoHeight = 0.014
                local infoAlpha = 220
                local infoFontSize = 10

                -- 攻击
                stage.ctl_info.attack = FrameLabel(kitP .. '->info->attack', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_plate[t], FRAME_ALIGN_LEFT_TOP, 0.028, -0.068)
                    .size(infoWidthL, infoHeight)
                    .alpha(infoAlpha)
                    .textAlign(TEXT_ALIGN_LEFT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'attack') end)

                -- 攻速
                stage.ctl_info.attackSpeed = FrameLabel(kitP .. '->info->attackSpeed', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_info.attack, FRAME_ALIGN_LEFT_BOTTOM, 0, infoMargin)
                    .size(infoWidthL, infoHeight)
                    .alpha(infoAlpha)
                    .icon('icon\\attack_speed')
                    .textAlign(TEXT_ALIGN_LEFT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'attackSpeed') end)

                -- 攻击范围
                stage.ctl_info.attackRange = FrameLabel(kitP .. '->info->attackRange', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_info.attackSpeed, FRAME_ALIGN_LEFT_BOTTOM, 0, infoMargin)
                    .size(infoWidthL, infoHeight)
                    .alpha(infoAlpha)
                    .icon('icon\\attack_range')
                    .textAlign(TEXT_ALIGN_LEFT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'attackRange') end)

                -- 暴击
                stage.ctl_info.knocking = FrameLabel(kitP .. '->info->knocking', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_info.attackRange, FRAME_ALIGN_LEFT_BOTTOM, 0, infoMargin)
                    .size(infoWidthL, infoHeight)
                    .alpha(infoAlpha)
                    .icon('icon\\knocking')
                    .textAlign(TEXT_ALIGN_LEFT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'knocking') end)

                -- 视野
                stage.ctl_info.sight = FrameLabel(kitP .. '->info->sight', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_LEFT_TOP, stage.ctl_plate[t], FRAME_ALIGN_LEFT_TOP, 0.097, -0.087)
                    .size(infoWidthR, infoHeight)
                    .side(LAYOUT_ALIGN_RIGHT)
                    .alpha(infoAlpha)
                    .icon('icon\\sight')
                    .textAlign(TEXT_ALIGN_RIGHT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'sight') end)

                -- 防御
                stage.ctl_info.defend = FrameLabel(kitP .. '->info->defend', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_RIGHT_TOP, stage.ctl_info.sight, FRAME_ALIGN_RIGHT_BOTTOM, 0, infoMargin)
                    .size(infoWidthR, infoHeight)
                    .side(LAYOUT_ALIGN_RIGHT)
                    .alpha(infoAlpha)
                    .icon('icon\\defend')
                    .textAlign(TEXT_ALIGN_RIGHT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'defend') end)

                -- 移动
                stage.ctl_info.move = FrameLabel(kitP .. '->info->move', stage.ctl_plate[t])
                    .relation(FRAME_ALIGN_RIGHT_TOP, stage.ctl_info.defend, FRAME_ALIGN_RIGHT_BOTTOM, 0, infoMargin)
                    .size(infoWidthR, infoHeight)
                    .side(LAYOUT_ALIGN_RIGHT)
                    .alpha(infoAlpha)
                    .icon('icon\\move')
                    .textAlign(TEXT_ALIGN_RIGHT)
                    .fontSize(infoFontSize)
                    .onMouseLeave(stage.ctl_mouseLeave)
                    .onMouseEnter(function(evtData) stage.ctl_mouseEnter(evtData, 'move') end)

                -- 小值条条
                stage.ctl_tile = {}
                for _, tb in ipairs(stage.ctl_tileTypes) do
                    stage.ctl_tile[tb[1]] = FrameBar(kitP .. '->tile->' .. tb[1], stage.ctl_plate[t])
                        .texture('value', 'tile\\' .. tb[2])
                        .value(0, stage.ctl_tileWidth, stage.ctl_tileHeight)
                    if (tb[1] == "period") then
                        stage.ctl_tile[tb[1]]
                             .relation(FRAME_ALIGN_LEFT_BOTTOM, stage.ctl_info.portrait, FRAME_ALIGN_LEFT_TOP, 0.001, 0.001)
                             .fontSize(LAYOUT_ALIGN_LEFT_TOP, 7.5)
                    else
                        stage.ctl_tile[tb[1]]
                             .relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.ctl_plate[t], FRAME_ALIGN_LEFT_BOTTOM, 0, 0)
                             .fontSize(LAYOUT_ALIGN_RIGHT_TOP, 7.5)
                    end
                end
            elseif (t == 'Item') then

            end
        end
    end,
    onRefresh = function(stage)
        local p = PlayerLocal()
        local tempAsync = p.prop("ss_ctl_tempAsync")
        if (tempAsync == nil) then
            tempAsync = {}
            p.prop("ss_ctl_tempAsync", tempAsync)
        end
        local d = {
            class = 'Nil',
            selection = p.selection(),
            race = p.race(),
        }
        if (isObject(d.selection, "Unit")) then
            d.class = "Unit"
        elseif (isObject(d.selection, "Item")) then
            d.class = "Item"
        end
        if (d.class == "Nil") then
            d.nilDisplay = string.implode("|n", table.merge({ Game().name() }, Game().prop("infoIntro")))
        elseif (d.class == "Unit") then
            if (d.selection.isDead()) then
                p.prop("selection", NIL)
                return
            end
            local primary = d.selection.primary()
            d.nilDisplay = ""
            d.knocking = math.format(d.selection.crit(), 2) .. '%'
            d.sight = math.floor(d.selection.sight())
            d.defend = math.floor(d.selection.defend())
            d.move = math.floor(d.selection.move())
            if (time.isNight()) then
                d.sight = math.floor(d.selection.nsight())
            else
                d.sight = math.floor(d.selection.sight())
            end
            d.portraitTexture = 'icon\\common'
            if (d.selection.isMelee()) then
                d.attackTexture = 'icon\\attack_melee'
                if (primary ~= nil) then
                    d.portraitTexture = 'icon\\' .. primary.value .. '_melee'
                end
            elseif (d.selection.isRanged()) then
                if (d.selection.lightning() ~= nil) then
                    d.attackTexture = 'icon\\attack_lighting'
                else
                    d.attackTexture = 'icon\\attack_ranged'
                end
                if (primary ~= nil) then
                    d.portraitTexture = 'icon\\' .. primary.value .. '_ranged'
                end
            end
            if (d.selection.properName() ~= nil and d.selection.properName() ~= '') then
                d.properName = d.selection.name() .. '·' .. d.selection.properName()
            else
                d.properName = d.selection.name()
            end
            if (d.selection.isAttackAble()) then
                d.attackAlpha = 255
                if (d.selection.attackRipple() == 0) then
                    d.attack = math.floor(d.selection.attack())
                else
                    d.attack = math.floor(d.selection.attack()) .. '~' .. math.floor(d.selection.attack() + d.selection.attackRipple())
                end
                d.attackSpeed = math.format(d.selection.attackSpace(), 2) .. ' 秒/击'
                d.attackRange = math.floor(d.selection.attackRange())
            else
                d.attackAlpha = 150
                d.attack = ' - '
                d.attackSpeed = ' - '
                d.attackRange = ' - '
            end
            if (d.selection.isInvulnerable()) then
                d.defendTexture = 'icon\\defend_gold'
                d.defend = colour.hex(colour.gold, '无敌')
            else
                d.defendTexture = 'icon\\defend'
                if (d.selection.defend() <= 9999) then
                    d.defend = math.floor(d.selection.defend())
                else
                    d.defend = math.numberFormat(d.selection.defend(), 2)
                end
            end

            local hpCur = math.floor(d.selection.hpCur())
            local hp = math.floor(d.selection.hp() or 0)
            local hpRegen = math.trunc(d.selection.hpRegen(), 2)
            if (hpRegen == 0 or hp == 0 or hpCur >= hp) then
                d.hpRegen = ''
            elseif (hpRegen > 0) then
                d.hpRegen = colour.hex(colour.lawngreen, '+' .. hpRegen)
            elseif (hpRegen < 0) then
                d.hpRegen = colour.hex(colour.indianred, hpRegen)
            end
            d.hpPercent = math.trunc(hpCur / hp, 3)
            d.hpTxt = hpCur .. ' / ' .. hp
            if (hpCur < hp * 0.35) then
                d.hpTexture = 'bar\\red'
            elseif (hpCur < hp * 0.65) then
                d.hpTexture = 'bar\\orange'
            else
                d.hpTexture = 'bar\\green'
            end

            tempAsync.hpAlpha = tempAsync.hpAlpha or 255
            tempAsync.hpAlphaing = tempAsync.hpAlphaing or false
            if (d.hpPercent < 0.3) then
                if (tempAsync.hpAlphaing == false and tempAsync.hpAlpha >= 255) then
                    tempAsync.hpAlphaing = true
                end
                if (tempAsync.hpAlphaing == true and tempAsync.hpAlpha <= 155) then
                    tempAsync.hpAlphaing = false
                end
                if (tempAsync.hpAlphaing) then
                    tempAsync.hpAlpha = tempAsync.hpAlpha - 10
                else
                    tempAsync.hpAlpha = tempAsync.hpAlpha + 10
                end
            else
                tempAsync.hpAlpha = 255
                tempAsync.hpAlphaing = false
            end

            d.hpAlpha = tempAsync.hpAlpha

            local mpCur = math.floor(d.selection.mpCur())
            local mp = math.floor(d.selection.mp() or 0)
            local mpRegen = math.trunc(d.selection.mpRegen(), 2)
            if (mpRegen == 0 or mp == 0 or mpCur >= mp) then
                d.mpRegen = ''
            elseif (mpRegen > 0) then
                d.mpRegen = colour.hex(colour.skyblue, '+' .. mpRegen)
            elseif (mpRegen < 0) then
                d.mpRegen = colour.hex(colour.indianred, mpRegen)
            end
            if (mp == 0) then
                d.mpPercent = 1
                d.mpTxt = colour.hex(colour.darkgray, mpCur .. ' / ' .. mp)
                d.mpTexture = 'bar\\blueGrey'
            else
                d.mpPercent = math.trunc(mpCur / mp, 3)
                d.mpTxt = mpCur .. ' / ' .. mp
                d.mpTexture = 'bar\\blue'
            end

            local tileValueCount = 0
            local period = d.selection.period()
            if (period > 0) then
                tileValueCount = tileValueCount + 1
                local cur = d.selection.periodRemain() or 0
                d.periodPercent = math.trunc(cur / period, 3)
                d.periodTxt = '存在 ' .. math.format(cur, 1) .. ' 秒'
            end
            local level = d.selection.level()
            if (level > 0) then
                tileValueCount = tileValueCount + 1
                local cur = d.selection.exp() or 0
                local prev = d.selection.expNeed(level) or 0
                local need = d.selection.expNeed() or 0
                d.expPercent = math.trunc((cur - prev) / (need - prev), 3)
                d.expTxt = math.integerFormat(cur) .. '/' .. math.integerFormat(need) .. '  ' .. level .. ' 级'
            end
            local punish = d.selection.punish() or 0
            if (punish > 0) then
                tileValueCount = tileValueCount + 1
                local cur = d.selection.punishCur() or 0
                local max = d.selection.punish() or 0
                d.punishPercent = math.trunc(cur / max, 3)
                if (d.selection.isPunishing()) then
                    d.punishTxt = colour.hex(colour.indianred, math.integerFormat(cur) .. '/' .. math.integerFormat(max) .. '  僵住')
                else
                    d.punishTxt = colour.hex('DDC10C', math.integerFormat(cur) .. '/' .. math.integerFormat(max) .. '  硬直')
                end
            end
        elseif (d.class == "Item") then
            if (d.selection.instance() == false) then
                p.prop("selection", NIL)
                return
            end
            d.nilDisplay = ""
        end

        if (d.class == "Nil") then
            stage.ctl_nilDisplay.text(d.nilDisplay)
            stage.ctl_plate.Unit.show(false)
            stage.ctl_plate.Item.show(false)
            stage.ctl_plate.Nil.show(true)
        elseif (d.class == "Unit") then
            stage.ctl_hp
                 .texture('value', d.hpTexture)
                 .value(d.hpPercent, stage.ctl_bigBarWidth, stage.ctl_bigBarHeight)
                 .text(LAYOUT_ALIGN_CENTER, d.hpTxt)
                 .text(LAYOUT_ALIGN_RIGHT, d.hpRegen)
                 .alpha(d.hpAlpha)
            stage.ctl_mp
                 .texture('value', d.mpTexture)
                 .value(d.mpPercent, stage.ctl_bigBarWidth, stage.ctl_bigBarHeight)
                 .text(LAYOUT_ALIGN_CENTER, d.mpTxt)
                 .text(LAYOUT_ALIGN_RIGHT, d.mpRegen)
            stage.ctl_info.portrait
                 .icon(d.portraitTexture)
                 .text(d.properName)
            stage.ctl_info.attack
                 .icon(d.attackTexture)
                 .text(d.attack)
                 .alpha(d.attackAlpha)
            stage.ctl_info.attackSpeed
                 .text(d.attackSpeed)
                 .alpha(d.attackAlpha)
            stage.ctl_info.attackRange
                 .text(d.attackRange)
                 .alpha(d.attackAlpha)
            stage.ctl_info.knocking.text(d.knocking)
            stage.ctl_info.sight.text(d.sight)
            stage.ctl_info.defend
                 .icon(d.defendTexture)
                 .text(d.defend)
            stage.ctl_info.move.text(d.move)
            --
            local tileIdx = 0
            for _, tb in ipairs(stage.ctl_tileTypes) do
                if (d[tb[1] .. 'Percent'] and d[tb[1] .. 'Txt']) then
                    if (tb[1] == "period") then
                        stage.ctl_tile[tb[1]].text(LAYOUT_ALIGN_LEFT_TOP, d[tb[1] .. 'Txt'])
                    else
                        stage.ctl_tile[tb[1]]
                             .relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.ctl_plate.Unit, FRAME_ALIGN_LEFT_BOTTOM, stage.ctl_tileX, 0.006 + tileIdx * 0.017)
                             .text(LAYOUT_ALIGN_RIGHT_TOP, d[tb[1] .. 'Txt'])
                    end
                    stage.ctl_tile[tb[1]].value(d[tb[1] .. 'Percent'], stage.ctl_tileWidth, stage.ctl_tileHeight).show(true)
                    tileIdx = tileIdx + 1
                else
                    stage.ctl_tile[tb[1]].show(false)
                end
            end
            stage.ctl_plate.Nil.show(false)
            stage.ctl_plate.Item.show(false)
            stage.ctl_plate.Unit.show(true)
        elseif (d.class == "Item") then
            stage.ctl_plate.Nil.show(false)
            stage.ctl_plate.Unit.show(false)
            stage.ctl_plate.Item.show(true)
        end

    end,
}