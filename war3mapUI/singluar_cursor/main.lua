--[[
    玩家指针
    Author: hunzsig
]]

local kit = 'singluar_cursor'

local this = UIKit(kit)

this.onSetup(function()
    this.stage().cursor = Cursor()
        .uiKit(kit)
    --.sizeRate(20)
    --.textureCircle({ allow = "circle\\common" })
    --.textureSquare({ alpha = 130, allow = "square\\white", ban = "square\\red" })

end)

this.onStart(function()
    this.stage().cursor.banBorders({
        FrameBackdrop('singluar_set->ctl'),
        FrameBackdrop('singluar_set->menu'),
    })
end)