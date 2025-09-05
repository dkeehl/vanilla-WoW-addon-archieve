local OFFSET_X = 0      -- 箭头X轴坐标位置
local OFFSET_Y = 5      -- 箭头y轴坐标位置
local TEXTURE_SIZE = 50 -- 箭头大小

local MediaPath = "Interface\\AddOns\\TSTargetMark\\TGA\\"
TargetArrow = MediaPath .. "Arrow" ----箭头图片材质,Arrow1-20自选

local function IsNamePlateFrame(frame)
    if frame:GetObjectType() ~= "Button" then
        return false
    end
    local overlayRegion = frame:GetRegions()
    if not overlayRegion or overlayRegion:GetObjectType() ~= "Texture" or overlayRegion:GetTexture() ~=
        "Interface\\Tooltips\\Nameplate-Border" then
        return false
    end
    return true
end

function ArrowShow(namePlate)
    namePlate.Arrow:ClearAllPoints()
    namePlate.Arrow:SetPoint("BOTTOM", namePlate, "TOP", OFFSET_X, OFFSET_Y)
    namePlate.Arrow:Show()
end

function ArrowHide(namePlate)
    namePlate.Arrow:Hide()
end

local parentcount = 0
local prevcount = 0
local cache = {}

function Arrow_OnUpdate(elapsed)
    if (ShaguPlates and ShaguPlates.nameplates) or (pfUI and pfUI.nameplates) then
        local index = 1
        while _G['pfNamePlate' .. index] do
            local pfNamePlate = _G['pfNamePlate' .. index]
            if pfNamePlate.Arrow == nil then
                pfNamePlate.Arrow = pfNamePlate.health:CreateTexture(nil, "OVERLAY")
                pfNamePlate.Arrow:SetTexture(TargetArrow)
                pfNamePlate.Arrow:SetWidth(TEXTURE_SIZE)
                pfNamePlate.Arrow:SetHeight(TEXTURE_SIZE + 10)
                pfNamePlate.Arrow:Hide()
            end
            if pfNamePlate.istarget then
                ArrowShow(pfNamePlate)
            else
                ArrowHide(pfNamePlate)
            end
            index = index + 1
        end
    else
        parentcount = WorldFrame:GetNumChildren()
        if prevcount < parentcount then
            local frames = { WorldFrame:GetChildren() }
            for _, namePlate in ipairs(frames) do
                if IsNamePlateFrame(namePlate) and not cache[namePlate] then
                    cache[namePlate] = namePlate
                end
            end
            prevcount = parentcount
        end

        for namePlate in cache do
            local HealthBar = namePlate:GetChildren()
            if namePlate.Arrow == nil then
                namePlate.Arrow = namePlate:CreateTexture(nil, "OVERLAY")
                namePlate.Arrow:SetTexture(TargetArrow)
                namePlate.Arrow:SetWidth(TEXTURE_SIZE)
                namePlate.Arrow:SetHeight(TEXTURE_SIZE + 10)
                namePlate.Arrow:Hide()
            end
            if UnitExists("target") and HealthBar:GetAlpha() == 1 then
                ArrowShow(namePlate)
            else
                ArrowHide(namePlate)
            end
        end
    end
end

function Arrow_Update(elapsed)
    Arrow_OnUpdate(elapsed)
end

TSTargetMark = CreateFrame("Frame")
TSTargetMark:RegisterEvent("PLAYER_LOGIN")
TSTargetMark:RegisterEvent("PLAYER_TARGET_CHANGED")
TSTargetMark:SetScript("OnUpdate", Arrow_Update)
