-- 单位技能点及施法状态
_singluarSetCaster = {
    onSetup = function(kit, stage)

        kit = kit .. "->caster"

        stage.caster_barLen = 0.070
        stage.caster_barHeight = 0.012

        --- 技能点
        stage.caster_sp = FrameText(kit .. '->sp', stage.ability)
            .relation(FRAME_ALIGN_LEFT_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, -0.068, 0.109)
            .textAlign(FRAME_ALIGN_LEFT)
            .fontSize(8)

        --- 技能进度
        stage.caster_bar = FrameBar(kit .. '->bar', stage.ability)
            .relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, -0.1175, 0.105)
            .size(stage.caster_barLen, stage.caster_barHeight)
            .textAlign(LAYOUT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            .fontSize(LAYOUT_ALIGN_CENTER, 8)
            .show(false)

    end,
    onRefresh = function(stage)
        local p = PlayerLocal()
        local tmpData = {
            ---@type Unit
            selection = p.selection(),
            show = false
        }
        if (isObject(tmpData.selection, 'Unit') and tmpData.selection.isAlive()) then
            -- 技能点
            tmpData.sp = math.floor(tmpData.selection.abilityPoint())
            -- 施法条
            if (tmpData.selection.isAbilityChantCasting() or tmpData.selection.isAbilityKeepCasting()) then
                local remain = 0
                local set = 0
                local label = ''
                local texture = 'Singluar\\ui\\nil.tga'
                local val = 0
                local txt = 0
                if (tmpData.selection.isAbilityChantCasting()) then
                    remain = math.trunc(tmpData.selection.abilityChantCastingRemain(), 1)
                    set = math.trunc(tmpData.selection.abilityChantCastingSet(), 1)
                    label = '吟唱 '
                    texture = 'tile\\red'
                    val = math.trunc(1 - remain / set, 2)
                    txt = set - remain
                elseif (tmpData.selection.isAbilityKeepCasting()) then
                    remain = math.trunc(tmpData.selection.abilityKeepCastingRemain(), 1)
                    set = math.trunc(tmpData.selection.abilityKeepCastingSet(), 1)
                    label = '持续施法 '
                    texture = 'tile\\sky'
                    val = math.trunc(remain / set, 2)
                    txt = remain
                end
                if (remain > 0 and set > 0) then
                    tmpData.val = val
                    tmpData.texture = texture
                    tmpData.txt = label .. txt .. ' 秒'
                    if (remain > set - 0.3) then
                        tmpData.alpha = 255 * (set - remain) / 0.3
                    elseif (remain < 0.3) then
                        tmpData.alpha = 255 * remain / 0.3
                    else
                        tmpData.alpha = 255
                    end
                    tmpData.show = true
                end
            end
        end
        --- 技能点
        if (tmpData.sp ~= nil) then
            stage.caster_sp.text(colour.hex(colour.gold, tmpData.sp) .. ' 技能点')
        end
        stage.caster_sp.show(tmpData.sp ~= nil and tmpData.sp > 0)
        --- 施法条
        if (tmpData.show == true) then
            stage.caster_bar.texture('value', tmpData.texture)
            stage.caster_bar.value(tmpData.val, stage.caster_barLen, stage.caster_barHeight)
            stage.caster_bar.text(LAYOUT_ALIGN_CENTER, tmpData.txt)
            stage.caster_bar.alpha(tmpData.alpha)
        end
        stage.caster_bar.show(tmpData.show)
    end,
}