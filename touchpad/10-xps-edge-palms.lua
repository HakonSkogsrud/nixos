-- Ignore contacts beginning in 15 mm side borders and 8 mm top/bottom borders on this XPS touchpad.
-- Keep normal centre-started gestures and firmware palm classifications.
libinput:register({1})
libinput:connect('new-evdev-device', function(device)
    local info = device:info()
    if info.vid ~= 0x2c2f or info.pid ~= 0x002b or
       not device:udev_properties().ID_INPUT_TOUCHPAD then return end
    local axes = device:absinfos()
    local x, y = axes[evdev.ABS_MT_POSITION_X], axes[evdev.ABS_MT_POSITION_Y]
    if not x or not y or x.resolution <= 0 or y.resolution <= 0 then return end
    local side_border = 15 -- millimetres
    local vertical_border = 8 -- millimetres
    local slots, current = {}, 0
    device:connect('device-removed', function() slots = {} end)
    device:connect('evdev-frame', function(_, frame)
        for _, event in ipairs(frame) do
            local u, v = event.usage, event.value
            if u == evdev.ABS_MT_SLOT then current = v end
            local s = slots[current]
            if not s then s = {}; slots[current] = s end
            if u == evdev.ABS_MT_TRACKING_ID then
                s.active = v >= 0
                s.new = s.active
                s.rejected = false
                s.tool = 0
            elseif u == evdev.ABS_MT_POSITION_X then s.x = v
            elseif u == evdev.ABS_MT_POSITION_Y then s.y = v
            elseif u == evdev.ABS_MT_TOOL_TYPE then s.tool = v end
        end
        for slot, s in pairs(slots) do
            if s.active and s.new and s.x and s.y then
                s.rejected = s.x < x.minimum + side_border * x.resolution or
                    s.x > x.maximum - side_border * x.resolution or
                    s.y < y.minimum + vertical_border * y.resolution or
                    s.y > y.maximum - vertical_border * y.resolution
                s.new = false
            end
            if s.active then
                table.insert(frame, {usage=evdev.ABS_MT_SLOT, value=slot})
                table.insert(frame, {usage=evdev.ABS_MT_TOOL_TYPE,
                    value=s.rejected and 2 or (s.tool or 0)})
            end
        end
        -- Preserve the kernel's selected slot for subsequent partial frames.
        table.insert(frame, {usage=evdev.ABS_MT_SLOT, value=current})
        return frame
    end)
end)
