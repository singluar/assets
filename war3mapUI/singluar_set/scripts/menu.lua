--  F?按钮帮助提示
_singluarSetMenu = {
    onSetup = function(kit, stage)

        kit = kit .. '->menu'

        stage.menu = FrameBackdrop(kit, FrameGameUI)
            .adaptive(true)
            .absolut(FRAME_ALIGN_TOP, 0, 0)
            .size(0.65, 0.0375)
        stage.menu_fns = {
            { 'F9', 'F9 帮助' },
            { 'F10', 'F10 菜单' },
            { 'F11', 'F11 队伍' },
            { 'F12', 'F12 消息' },
        }
        stage.menu_welcome = FrameText(kit .. '->mn', stage.menu)
            .relation(FRAME_ALIGN_LEFT_TOP, stage.menu, FRAME_ALIGN_TOP, 0.052, -0.0032)
            .textAlign(TEXT_ALIGN_LEFT)
            .fontSize(10)
        stage.menu_lv = FrameText(kit .. '->msv', stage.menu)
            .relation(FRAME_ALIGN_LEFT_TOP, stage.menu, FRAME_ALIGN_RIGHT_TOP, -0.058, -0.0032)
            .textAlign(TEXT_ALIGN_LEFT)
            .fontSize(10)
        stage.menu_infoCenter = FrameText(kit .. '->infoCenter', stage.menu)
            .relation(FRAME_ALIGN_TOP, stage.menu, FRAME_ALIGN_TOP, 0, -0.007)
            .textAlign(TEXT_ALIGN_CENTER)
            .fontSize(9)
            .text("")
        stage.menu_fn = {}
        for i, t in ipairs(stage.menu_fns) do
            stage.menu_fn[i] = {}
            stage.menu_fn[i].btn = Frame(kit .. '->' .. i, japi.DzFrameGetUpperButtonBarButton(i - 1), stage.menu)
                .relation(FRAME_ALIGN_LEFT_TOP, stage.menu, FRAME_ALIGN_LEFT_TOP, (i - 1) * 0.071, 0.002)
                .size(0.064, 0.02)
            japi.DzFrameSetAlpha(stage.menu_fn[i].btn.handle(), 0)
            stage.menu_fn[i].txt = FrameText(kit .. '->txt->' .. i, stage.menu)
                .relation(FRAME_ALIGN_CENTER, stage.menu_fn[i].btn, FRAME_ALIGN_CENTER, 0, 0)
                .textAlign(TEXT_ALIGN_CENTER)
                .fontSize(8)
            if (i == 3 and Game().playingQuantity() == 1) then
                stage.menu_fn[i].txt.text(colour.hex(colour.silver, t[2]))
            else
                stage.menu_fn[i].txt.text(t[2])
            end
        end
    end,
}