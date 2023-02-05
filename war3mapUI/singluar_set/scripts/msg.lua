_singluarSetMsg = {
    onSetup = function(kit, stage)
        -- DZ 官方标志
        stage.dz = FrameBackdrop(kit .. "->dz", FrameGameUI)
            .adaptive(true)
            .relation(FRAME_ALIGN_RIGHT_BOTTOM, FrameGameUI, FRAME_ALIGN_RIGHT_BOTTOM, -0.008, 0.140)
            .size(0.09, 0.03)
            .texture('bg\\dz')
        -- Echo 屏幕信息
        stage.echo = Frame(kit .. "->echo", japi.DzFrameGetUnitMessage(), nil)
            .absolut(FRAME_ALIGN_LEFT_BOTTOM, 0.134, 0.144)
            .size(0, 0.36)
        -- Chat 居中聊天信息
        stage.chat = Frame(kit .. "->chat", japi.DzFrameGetChatMessage(), nil)
            .absolut(FRAME_ALIGN_BOTTOM, 0.03, 0.20)
            .size(0.22, 0.16)
        -- Alert 警告
        stage.alert = FrameText(kit .. "->alert", FrameGameUI)
            .relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0.025, 0.15)
            .textAlign(TEXT_ALIGN_CENTER)
            .fontSize(13)
    end,
}