local try_require = function(module, msg)
    local success, result = pcall(require, module)
    if success then return result else return error(msg) end
end

local pui = try_require('gamesense/pui', '~ Download pui library: https://gamesense.pub/forums/viewtopic.php?id=41761')
local antiaim_func = try_require("gamesense/antiaim_funcs", "~ Missing antiaim_funcs")

local aa_gp = pui.group('aa', 'anti-aimbot angles')
local fl_gp = pui.group('aa', 'fake lag')
local oth_group = pui.group('aa', 'other')

local ref = {
    enabled = pui.reference('AA', 'Anti-aimbot angles', 'Enabled'),
    pitch = {pui.reference('AA', 'Anti-aimbot angles', 'Pitch')},
    yaw = {pui.reference('AA', 'Anti-aimbot angles', 'Yaw')},
    yawbase = pui.reference('AA', 'Anti-aimbot angles', 'Yaw base'),
    yawjitter = {pui.reference('AA', 'Anti-aimbot angles', 'Yaw jitter')},
    bodyyaw = {pui.reference('AA', 'Anti-aimbot angles', 'Body yaw')},
    fsbodyyaw = pui.reference('AA', 'anti-aimbot angles', 'Freestanding body yaw'),
    edgeyaw = pui.reference('AA', 'Anti-aimbot angles', 'Edge yaw'),
    freestand = {pui.reference('AA', 'Anti-aimbot angles', 'Freestanding')},
    roll = {pui.reference('AA', 'Anti-aimbot angles', 'Roll')},
    fakeenabled = {pui.reference("AA", "Fake lag", "Enabled")},
    amount = {pui.reference("AA", "Fake lag", "Amount")},
    variance = {pui.reference("AA", "Fake lag", "Variance")},
    limit = {pui.reference("AA", "Fake lag", "Limit")},
    other_slowmotion = {pui.reference('AA', 'Other', 'Slow motion')},
    other_legmovement = {pui.reference('AA', 'Other', 'Leg movement')},
    os = {pui.reference('AA', 'Other', 'On shot anti-aim')},
}

local function has_value(tab, val)
    if type(tab) ~= "table" then return tab == val end
    for _, value in pairs(tab) do
        if value == val then return true end
    end
    return false
end

local function lerping(a, b, t)
    return a + (b - a) * math.abs(t)
end

local antiaim_cond = {"Standing", "Running", "Walking", "Aerobic", "Aerobic+", "Crouch", "Crouch+"}

local builder = {}
local builder_values = {T = {}, CT = {}}

local menu = {}

menu.main = fl_gp:combobox("\nadawdwada", {" Anti-Aim", " Features"})

menu.info = {
    lb_main = fl_gp:label("\vendlessgrace.yaw"),
}

menu.antiaim = {
    selection = fl_gp:combobox("\ndwada", {" Builder", " Features", " Other"}),
    lb_side = fl_gp:label(' '),
    side_switch = fl_gp:combobox('\ndwadwad', {'T', 'CT'}),

    label = aa_gp:label("\vAnti-aim \rcondition"),
    condition = aa_gp:combobox('\nAnti-aim conditions', antiaim_cond),

    lb_features = aa_gp:label("Features"),
    features = aa_gp:multiselect('\nFeatures', {'Safe head', 'Warmup AA/No Enemies', 'Avoid Backstab'}),

    label4 = aa_gp:label(" "),
    lb_yaw_direction = aa_gp:label("Yaw directions"),
    yaw_direction = aa_gp:multiselect('\nYaw directions', {'Edge Yaw', 'Freestanding', 'Manuals'}),
    label12 = aa_gp:label(" "),
    edge_yaw = aa_gp:hotkey("Edge Yaw", false),
    freestanding_hotkey = aa_gp:hotkey('Freestanding hotkey', false),
    label5 = aa_gp:label(" "),
    lb_freestanding_disablers = aa_gp:label("Freestanding disablers"),
    freestanding_disablers = aa_gp:multiselect("\nFreestanding disablers", {"Walking", "Crouching", "Aerobic", "Manuals"}),
    lb_manuals_disablers = aa_gp:label("Manuals disablers"),
    manuals_disablers = aa_gp:multiselect("\nManuals disablers", {"Walking", "Crouching", "Aerobic"}),
    manuals_left = aa_gp:hotkey('Manual Left'),
    manuals_right = aa_gp:hotkey('Manual Right'),
    manuals_forward = aa_gp:hotkey('Manual Forward'),
    manuals_reset = aa_gp:hotkey('Manual Reset'),

    lb12 = oth_group:label(' '),
    fake_label = oth_group:label("\vFakeLag options"),
    fakeenabled = oth_group:checkbox("Enabled"),
    fake_amount = oth_group:combobox("Amount", {"Dynamic", "Maximum", "Fluctuate"}),
    fake_variance = oth_group:slider("Variance", 0, 100, 0, true, "%", 1),
    fake_limit = oth_group:slider("Limit", 1, 15, 1, true, " ", 1),
}

for i = 1, #antiaim_cond do
    builder_values.T[i] = {}
    builder_values.CT[i] = {}

    builder[i] = {
        lb1 = aa_gp:label(" "),
        enabled = aa_gp:checkbox("\nadwad"),
        state = aa_gp:label("\v" .. antiaim_cond[i]),
        label1 = aa_gp:label(" "),
        label2 = aa_gp:label("\rYaw \vSettings"),
        main = aa_gp:combobox("\ndwadwa", {"Yaw", "Defensive"}),
        lb_pizdec = fl_gp:label(" "),
        lb_brute = fl_gp:label("Antibrute Mode"),
        brute_mode = fl_gp:combobox("\nawdad", {"Disabled", "Adaptive", "Decrease", "Increase"}),
        delay_force = fl_gp:checkbox('Force Delay'),
        duration_brute = fl_gp:slider('Duration', 0, 100, 0, true, 's', 0.1, {[0] = 'inf'}),
        label3 = aa_gp:label(" "),
        offset_lb = aa_gp:label(' '),
        offset = aa_gp:slider("\nOffset Amount", -180, 180, 0, true, "°", 1),
        offset_lb1 = aa_gp:label(' '),
        ofs_lb_1 = aa_gp:label('Left Yaw'),
        ofs_tp_1 = aa_gp:combobox('\nawdwa', {'Default', 'Way'}),
        ofs_ways_delay_1 = aa_gp:slider("\nDelay", 2, 16, 2, true, "t", 1, {[2] = " "}),
        ofs_way_1 = aa_gp:slider("\nadwadwa", 2, 5, 2, true, "w", 1),
        ofs_ways_1 = {
            [1] = aa_gp:slider('\nFirst offset \n', -90, 90, 0, true, '°'),
            [2] = aa_gp:slider('\nSecond offset \n', -90, 90, 0, true, '°'),
            [3] = aa_gp:slider('\nThird offset \n', -90, 90, 0, true, '°'),
            [4] = aa_gp:slider('\nFourth offset \n', -90, 90, 0, true, '°'),
            [5] = aa_gp:slider('\nFifth offset \n', -90, 90, 0, true, '°'),
        },
        ofs_1 = aa_gp:slider("\nOffset Amount 1", -90, 90, 0, true, "°", 1),
        ofs_lb_2 = aa_gp:label('Right Yaw'),
        ofs_tp_2 = aa_gp:combobox('\nawdwa', {'Default', 'Way'}),
        ofs_ways_delay_2 = aa_gp:slider("\nDelay", 2, 16, 2, true, "t", 1, {[2] = " "}),
        ofs_way_2 = aa_gp:slider("\nadwadwa", 2, 5, 2, true, "w", 1),
        ofs_ways_2 = {
            [1] = aa_gp:slider('\nFirst offset \n', -90, 90, 0, true, '°'),
            [2] = aa_gp:slider('\nSecond offset \n', -90, 90, 0, true, '°'),
            [3] = aa_gp:slider('\nThird offset \n', -90, 90, 0, true, '°'),
            [4] = aa_gp:slider('\nFourth offset \n', -90, 90, 0, true, '°'),
            [5] = aa_gp:slider('\nFifth offset \n', -90, 90, 0, true, '°'),
        },
        ofs_2 = aa_gp:slider("\nOffset Amount 2", -90, 90, 0, true, "°", 1),
        label4 = aa_gp:label(" "),
        label5 = aa_gp:label("\rYaw \vFeatures"),
        yaw_mode = aa_gp:multiselect("\nawdwad", {"Jitter", "Spin", "Random"}),
        spna_switch = aa_gp:checkbox("\ndwadwadwa"),
        spna = aa_gp:slider("\nadwada", 0, 100, 0, true, "°", 1),
        spna_speed = aa_gp:slider("\ndwdaw", 10, 50, 10, true, " ", 0.1),
        spna2 = aa_gp:slider("\nadwada", 0, 100, 0, true, "°", 1),
        spna_speed2 = aa_gp:slider("\ndwdaw", 10, 50, 10, true, " ", 0.1),
        rana_switch = aa_gp:checkbox("\nadwadwaadw"),
        rana = aa_gp:slider("\nadwada", 0, 100, 0, true, "%", 1),
        rana2 = aa_gp:slider("\nadwada", 0, 100, 0, true, "%", 1),
        label7 = aa_gp:label(" "),
        label6 = aa_gp:label("\rJitter \vMode"),
        yaw_jitter = aa_gp:combobox("\nYaw jitter", {"Off", "Center", "Offset", "Skitter", "X-Way", "Random"}),
        xway_slider = aa_gp:slider("\nadwadwa", 3, 10, 3, true, "w", 1),
        xway_jitter = aa_gp:slider("\ndwadwad", -90, 90, 0, true, '°', 1),
        yawjitter = aa_gp:slider("\ndwadwad", -90, 90, 0, true, '°', 1),
        label8 = aa_gp:label(" "),
        label9 = aa_gp:label("\vBody Yaw"),
        bodyyaw = aa_gp:combobox("\nBody yaw", {"Off", "Static", "Jitter", "Opposite"}),
        bd_type = aa_gp:combobox('\ndwadwa', {'Gamesense', 'Advanced'}),
        body_type = aa_gp:combobox("\nType", {"Default", "Spin", "Fluctuate", "Random", "Dynamic"}),
        body_static = aa_gp:slider('\nadwad', -180, 180, 0, true, "°", 1),
        body_left = aa_gp:slider("Left", -180, 180, 0, true, "°", 1),
        body_right = aa_gp:slider("Right", -180, 180, 0, true, "°", 1),
        label11 = oth_group:label('\vOther Settings'),
        delay_method = oth_group:combobox("Delay Method", {"Default", "Ways"}),
        delay_switch = oth_group:multiselect('\nawdad', {'Disable on Fakelags', 'Fluctuate', 'Hold ticks'}),
        delay = oth_group:slider("Delay", 1, 16, 1, true, "t", 1, {[1] = " "}),
        random_delay = oth_group:slider("Random Delay", 0, 22, 0, true, "t", 1, {[0] = " "}),
        delay_fluc = oth_group:slider('Fluctuate', 1, 12, 1, true, '', 1, {[1] = ' '}),
        hold_ticks = oth_group:slider("Hold ticks", 0, 14, 0, true, 't', 1, {[0] = ' '}),
        ways = oth_group:slider("Ways", 3, 10, 3, true, "w", 1),
        way_del = {
            [1] = oth_group:slider('\nFirst offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [2] = oth_group:slider('\nSecond offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [3] = oth_group:slider('\nThird offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [4] = oth_group:slider('\nFourth offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [5] = oth_group:slider('\nFifth offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [6] = oth_group:slider('\nFirst offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [7] = oth_group:slider('\nSecond offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [8] = oth_group:slider('\nThird offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [9] = oth_group:slider('\nFourth offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
            [10] = oth_group:slider('\nFifth offset \n', 1, 16, 1, true, "t", 1, {[1] = " "}),
        },
        force_lc = aa_gp:checkbox('\aB6B665FFForce LC'),
        def_en = aa_gp:checkbox("Defensive"),
        pitch_type = aa_gp:combobox('Pitch', {'Off', 'Static', 'Jitter', 'Spin', 'Spin[MOD]', 'Random', 'Random Ticks'}),
        pitch_static = aa_gp:slider('Angle', -89, 89, 0, true, '°', 1),
        pitch_mode1 = aa_gp:slider('Angle 1', -89, 89, 0, true, '°', 1),
        pitch_mode2 = aa_gp:slider('Angle 2', -89, 89, 0, true, '°', 1),
        pitch_speed = aa_gp:slider('Angle Speed', -50, 50, 20, true, ' ', 0.1),
        pitch_jitter_speed = aa_gp:slider("Speed Ticks", 2, 14, 2, true, 't', 1, {[2] = ' '}),
        pitch_slow_def = aa_gp:slider('Speed', 0, 10, 0, true, ' ', 0.1),
        yaw_def = aa_gp:combobox('Yaw', {'Off', 'Static', 'Static[FS]', 'Jitter', 'Jitter[L/R]', 'Spin', 'Random', '3-way', '5-way'}),
        yaw_amount = aa_gp:slider("Yaw amount", 0, 360, 0, true, '°', 1),
        yaw_left = aa_gp:slider('Yaw left', -180, 180, 0, true, '°', 1),
        yaw_right = aa_gp:slider('Yaw right', -180, 180, 0, true, '°', 1),
        def_jitter_speed = aa_gp:slider('Speed Ticks', 2, 14, 2, true, 't', 1, {[2] = ' '}),
        def_spin_speed = aa_gp:slider("Yaw Speed", -50, 50, 20, true, ' ', 0.1),
        adaptive_desync = aa_gp:multiselect("Yaw options", {'Adaptive Desync', 'Delay Off'}),
    }
end

local current_side = "T"
local id = 1

local aa_side = {}

function aa_side.deep_copy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[aa_side.deep_copy(k)] = aa_side.deep_copy(v) end
    return res
end

function aa_side.save_to_custom(target_side)
    if not builder_values[target_side] then
        builder_values[target_side] = {}
    end

    for i = 1, #antiaim_cond do
        builder_values[target_side][i] = builder_values[target_side][i] or {}
        local v = builder_values[target_side][i]
        local b = builder[i]

        v.enabled = b.enabled:get()
        v.main = b.main:get()
        v.brute_mode = b.brute_mode:get()
        v.delay_force = b.delay_force:get()
        v.duration_brute = b.duration_brute:get()
        v.ofs_tp_1 = b.ofs_tp_1:get()
        v.offset = b.offset:get()
        v.ofs_ways_delay_1 = b.ofs_ways_delay_1:get()
        v.ofs_way_1 = b.ofs_way_1:get()
        v.ofs_1 = b.ofs_1:get()
        v.ofs_tp_2 = b.ofs_tp_2:get()
        v.ofs_ways_delay_2 = b.ofs_ways_delay_2:get()
        v.ofs_way_2 = b.ofs_way_2:get()
        v.ofs_2 = b.ofs_2:get()

        v.yaw_mode = b.yaw_mode:get()
        v.spna_switch = b.spna_switch:get()
        v.spna = b.spna:get()
        v.spna_speed = b.spna_speed:get()
        v.spna2 = b.spna2:get()
        v.spna_speed2 = b.spna_speed2:get()
        v.rana_switch = b.rana_switch:get()
        v.rana = b.rana:get()
        v.rana2 = b.rana2:get()

        v.yaw_jitter = b.yaw_jitter:get()
        v.xway_slider = b.xway_slider:get()
        v.xway_jitter = b.xway_jitter:get()
        v.yawjitter = b.yawjitter:get()
        v.bd_type = b.bd_type:get()
        v.bodyyaw = b.bodyyaw:get()
        v.body_type = b.body_type:get()
        v.body_static = b.body_static:get()
        v.body_left = b.body_left:get()
        v.body_right = b.body_right:get()

        v.delay_method = b.delay_method:get()
        v.delay_switch = b.delay_switch:get()
        v.delay = b.delay:get()
        v.random_delay = b.random_delay:get()
        v.delay_fluc = b.delay_fluc:get()
        v.hold_ticks = b.hold_ticks:get()
        v.ways = b.ways:get()
        v.force_lc = b.force_lc:get()
        v.def_en = b.def_en:get()
        v.pitch_type = b.pitch_type:get()
        v.pitch_static = b.pitch_static:get()
        v.pitch_mode1 = b.pitch_mode1:get()
        v.pitch_mode2 = b.pitch_mode2:get()
        v.pitch_speed = b.pitch_speed:get()
        v.pitch_jitter_speed = b.pitch_jitter_speed:get()
        v.pitch_slow_def = b.pitch_slow_def:get()
        v.yaw_def = b.yaw_def:get()
        v.yaw_amount = b.yaw_amount:get()
        v.yaw_left = b.yaw_left:get()
        v.yaw_right = b.yaw_right:get()
        v.def_jitter_speed = b.def_jitter_speed:get()
        v.def_spin_speed = b.def_spin_speed:get()
        v.adaptive_desync = b.adaptive_desync:get()

        v.ofs_ways_1 = v.ofs_ways_1 or {}
        for j = 1, 5 do v.ofs_ways_1[j] = b.ofs_ways_1[j]:get() end

        v.ofs_ways_2 = v.ofs_ways_2 or {}
        for j = 1, 5 do v.ofs_ways_2[j] = b.ofs_ways_2[j]:get() end

        v.way_del = v.way_del or {}
        for j = 1, 10 do v.way_del[j] = b.way_del[j]:get() end
    end
end

function aa_side.load_from_custom(target_side)
    if not builder_values[target_side] then return end

    for i = 1, #antiaim_cond do
        local v = builder_values[target_side][i]
        local b = builder[i]
        if v then
            b.main:set(v.main or "Yaw")
            b.enabled:set(v.enabled or false)
            b.brute_mode:set(v.brute_mode or "Disabled")
            b.delay_force:set(v.delay_force or false)
            b.duration_brute:set(v.duration_brute or 0)
            b.ofs_tp_1:set(v.ofs_tp_1 or "Default")
            b.offset:set(v.offset or 0)
            b.ofs_ways_delay_1:set(v.ofs_ways_delay_1 or 2)
            b.ofs_way_1:set(v.ofs_way_1 or 2)
            b.ofs_1:set(v.ofs_1 or 0)
            b.ofs_tp_2:set(v.ofs_tp_2 or "Default")
            b.ofs_ways_delay_2:set(v.ofs_ways_delay_2 or 2)
            b.ofs_way_2:set(v.ofs_way_2 or 2)
            b.ofs_2:set(v.ofs_2 or 0)

            b.yaw_mode:set(v.yaw_mode or {})
            b.spna_switch:set(v.spna_switch or false)
            b.spna:set(v.spna or 0)
            b.spna_speed:set(v.spna_speed or 10)
            b.spna2:set(v.spna2 or 0)
            b.spna_speed2:set(v.spna_speed2 or 10)
            b.rana_switch:set(v.rana_switch or false)
            b.rana:set(v.rana or 0)
            b.rana2:set(v.rana2 or 0)

            b.yaw_jitter:set(v.yaw_jitter or "Off")
            b.xway_slider:set(v.xway_slider or 3)
            b.xway_jitter:set(v.xway_jitter or 0)
            b.yawjitter:set(v.yawjitter or 0)
            b.bodyyaw:set(v.bodyyaw or "Off")
            b.bd_type:set(v.bd_type or "Gamesense")
            b.body_type:set(v.body_type or "Default")
            b.body_static:set(v.body_static or 0)
            b.body_left:set(v.body_left or 0)
            b.body_right:set(v.body_right or 0)

            b.delay_method:set(v.delay_method or "Default")
            b.delay_switch:set(v.delay_switch or {})
            b.delay:set(v.delay or 1)
            b.random_delay:set(v.random_delay or 0)
            b.delay_fluc:set(v.delay_fluc or 1)
            b.hold_ticks:set(v.hold_ticks or 0)
            b.ways:set(v.ways or 3)
            b.force_lc:set(v.force_lc or false)
            b.def_en:set(v.def_en or false)
            b.pitch_type:set(v.pitch_type or "Off")
            b.pitch_static:set(v.pitch_static or 0)
            b.pitch_mode1:set(v.pitch_mode1 or 0)
            b.pitch_mode2:set(v.pitch_mode2 or 0)
            b.pitch_speed:set(v.pitch_speed or 20)
            b.pitch_jitter_speed:set(v.pitch_jitter_speed or 2)
            b.pitch_slow_def:set(v.pitch_slow_def or 0)
            b.yaw_def:set(v.yaw_def or "Off")
            b.yaw_amount:set(v.yaw_amount or 0)
            b.yaw_left:set(v.yaw_left or 0)
            b.yaw_right:set(v.yaw_right or 0)
            b.def_jitter_speed:set(v.def_jitter_speed or 2)
            b.def_spin_speed:set(v.def_spin_speed or 20)
            b.adaptive_desync:set(v.adaptive_desync or {})

            if v.ofs_ways_1 then
                for j = 1, 5 do b.ofs_ways_1[j]:set(v.ofs_ways_1[j] or 0) end
            end
            if v.ofs_ways_2 then
                for j = 1, 5 do b.ofs_ways_2[j]:set(v.ofs_ways_2[j] or 0) end
            end
            if v.way_del then
                for j = 1, 10 do b.way_del[j]:set(v.way_del[j] or 1) end
            end
        end
    end
end

local antiaim = {}

local xway_ticks = 0
local xway_index = 1

function antiaim.xway(cmd)
    local b = builder[id]
    if not b then return 0 end
    local ways_count = b.xway_slider:get()
    local jitter = b.xway_jitter:get()
    xway_ticks = xway_ticks + 1
    if xway_ticks >= 2 then
        xway_ticks = 0
        xway_index = xway_index + 1
        if xway_index > ways_count then xway_index = 1 end
    end
    local step = (jitter * 2) / math.max(ways_count - 1, 1)
    return -jitter + step * (xway_index - 1)
end

function antiaim.xway_lr()
    local b = builder[id]
    if not b then return 0, 0 end
    local tp1 = b.ofs_tp_1:get()
    local tp2 = b.ofs_tp_2:get()
    local left, right

    if tp1 == "Default" then
        left = b.ofs_1:get()
    else
        local way_count = b.ofs_way_1:get()
        local delay = b.ofs_ways_delay_1:get()
        local tick_index = math.floor(globals.tickcount() / delay) % way_count + 1
        left = b.ofs_ways_1[tick_index]:get()
    end

    if tp2 == "Default" then
        right = b.ofs_2:get()
    else
        local way_count = b.ofs_way_2:get()
        local delay = b.ofs_ways_delay_2:get()
        local tick_index = math.floor(globals.tickcount() / delay) % way_count + 1
        right = b.ofs_ways_2[tick_index]:get()
    end

    return left, right
end

function antiaim.spin_pitch(min_v, max_v, speed, mode)
    local t = globals.curtime() * (speed / 10)
    if mode == 1 then
        return min_v + (max_v - min_v) * (0.5 + 0.5 * math.sin(t))
    end
    return lerping(min_v, max_v, math.abs(math.sin(t)))
end

function antiaim.get_pitch_value(min_v, max_v, speed)
    local t = globals.curtime() * speed / 10
    return min_v + (max_v - min_v) * (t % 1)
end

function antiaim.generate_slow_random(min_v, max_v, speed)
    local t = globals.curtime() * speed
    local noise = math.sin(t * 1.7) * 0.5 + math.cos(t * 2.3) * 0.3 + math.sin(t * 3.1) * 0.2
    return min_v + (max_v - min_v) * (0.5 + 0.5 * noise)
end

local dele2 = false
local tick_counter = 0

local function get_current_condition(lp, cmd)
    if not lp or lp == 0 then return 1 end
    local flags = entity.get_prop(lp, 'm_fFlags')
    local on_ground = bit.band(flags, 1) == 1
    local ducking = bit.band(flags, 2) == 2
    local vecvelocity = {entity.get_prop(lp, 'm_vecVelocity')}
    local speed = math.sqrt(vecvelocity[1] ^ 2 + vecvelocity[2] ^ 2)

    if not on_ground and ducking then return 7 end
    if not on_ground then return (speed > 100) and 5 or 4 end
    if ducking then return 6 end
    if speed > 100 then return 2 end
    if speed > 2 then return 3 end
    return 1
end

local function run_antiaim(cmd)
    local lp = entity.get_local_player()
    if not lp or lp == 0 then return end
    if not ref.enabled:get() then return end

    local condition_idx = get_current_condition(lp, cmd)
    id = condition_idx

    local b = builder[id]
    if not b then return end

    local cfg = builder_values[current_side][id]
    if not cfg then return end
    if not cfg.enabled then return end

    tick_counter = tick_counter + 1
    local delay_ticks = cfg.delay or 1
    if tick_counter >= delay_ticks then
        tick_counter = 0
        dele2 = not dele2
    end

    local to_jitter = dele2

    local yaw_direction = 0
    local yaw_dir_val = menu.antiaim.yaw_direction:get()
    if has_value(yaw_dir_val, "Edge Yaw") then yaw_direction = 1 end
    if has_value(yaw_dir_val, "Freestanding") then yaw_direction = 2 end

    ref.fsbodyyaw:override(false)
    if yaw_direction ~= 0 then
        ref.yawbase:override("Local view")
    else
        ref.yawbase:override("At targets")
    end
    ref.yaw[1]:override("180")

    local left_yaw, right_yaw = antiaim.xway_lr()

    local offset_v = {l = left_yaw, r = right_yaw}
    local ranv = {rn = cfg.rana or 0, rn2 = cfg.rana2 or 0}
    local spinv = {
        sp = cfg.spna or 0,
        sp2 = cfg.spna2 or 0,
        speed = cfg.spna_speed or 0,
        speed2 = cfg.spna_speed2 or 0
    }

    local amount_add = 0
    local rana_add = 0
    local spining = 0
    local offset = cfg.offset or 0

    amount_add = offset + (to_jitter and offset_v.l or offset_v.r)

    if has_value(cfg.yaw_mode, 'Random') then
        if cfg.rana_switch then
            rana_add = math.random(to_jitter and -ranv.rn or ranv.rn2) * 0.5
        else
            rana_add = math.random(to_jitter and -ranv.rn or ranv.rn) * 0.5
        end
    end

    if has_value(cfg.yaw_mode, 'Spin') then
        if cfg.spna_switch then
            spining = to_jitter and lerping(-spinv.sp, 0, globals.curtime() * spinv.speed / 10 % 2 - 1) * 0.5
                        or lerping(spinv.sp2, 0, globals.curtime() * spinv.speed2 / 10 % 2 - 1) * 0.5
        else
            spining = to_jitter and lerping(-spinv.sp, 0, globals.curtime() * spinv.speed / 10 % 2 - 1) * 0.5
                        or lerping(spinv.sp, 0, globals.curtime() * spinv.speed / 10 % 2 - 1) * 0.5
        end
    end

    local yawjitter = cfg.yawjitter or 0
    local body_type = cfg.body_type
    local body_value = 0

    local vecvelocity = {entity.get_prop(lp, 'm_vecVelocity')}
    local speed = math.sqrt(vecvelocity[1] ^ 2 + vecvelocity[2] ^ 2)

    local bd_left, bd_right
    if cfg.bd_type == 'Gamesense' then
        bd_left = -(cfg.body_static or 0)
        bd_right = cfg.body_static or 0
    else
        bd_left = cfg.body_left or 0
        bd_right = cfg.body_right or 0
    end

    if body_type == "Default" then
        body_value = to_jitter and bd_left or bd_right
    elseif body_type == "Spin" then
        body_value = to_jitter and math.abs(math.sin(globals.curtime() * 5)) * bd_left or math.abs(math.sin(globals.curtime() * 5)) * bd_right
    elseif body_type == "Fluctuate" then
        local fluc = 0.5 + 0.5 * math.sin(cmd.command_number * 0.1)
        body_value = to_jitter and bd_left * fluc or bd_right * fluc
    elseif body_type == "Random" then
        body_value = to_jitter and math.random(bd_left, 0) or math.random(0, bd_right)
    elseif body_type == "Dynamic" then
        local factor = math.min(speed / 300, 1)
        body_value = to_jitter and bd_left * (1 - factor) or bd_right * (1 - factor)
    end

    if cfg.bodyyaw == "Jitter" then
        ref.bodyyaw[1]:override("Static")
        ref.bodyyaw[2]:override(body_value)
    else
        ref.bodyyaw[1]:override(cfg.bodyyaw)
        ref.bodyyaw[2]:override(body_value)
    end

    local b_yaw = 0

    if not (cfg.bodyyaw == "Static" or cfg.bodyyaw == "Off") then
        ref.yawjitter[1]:override('Off')
        if cfg.yaw_jitter == "Center" then
            amount_add = offset + (to_jitter and offset_v.l + yawjitter or offset_v.r - yawjitter)
        elseif cfg.yaw_jitter == "Offset" then
            amount_add = offset + (to_jitter and offset_v.l or offset_v.r - yawjitter)
        elseif cfg.yaw_jitter == "Random" then
            local safe_l = math.max(math.abs(offset_v.l + yawjitter), 1)
            local safe_r = math.max(math.abs(offset_v.r - yawjitter), 1)
            amount_add = offset + (to_jitter and math.random(-safe_l, safe_l) or math.random(-safe_r, safe_r)) + rana_add
        elseif cfg.yaw_jitter == "Skitter" then
            local skitter_wave = math.sin(cmd.command_number * 0.5)
            local jitter_offset = skitter_wave * yawjitter
            if to_jitter then
                amount_add = offset + offset_v.l + jitter_offset
            else
                amount_add = offset + offset_v.r + jitter_offset
            end
        elseif cfg.yaw_jitter == "X-Way" then
            if to_jitter then
                amount_add = offset_v.l + antiaim.xway(cmd) + offset
            else
                amount_add = offset_v.r - antiaim.xway(cmd) + offset
            end
        end
    else
        if cfg.yaw_jitter == "X-Way" then
            ref.yawjitter[1]:override("Center")
            ref.yawjitter[2]:override(antiaim.xway(cmd))
        else
            ref.yawjitter[1]:override(cfg.yaw_jitter or "Off")
            ref.yawjitter[2]:override(cfg.yawjitter or 0)
        end
    end

    amount_add = amount_add or 0
    local yaw_amount = amount_add + rana_add + spining + b_yaw

    local pitch = 0

    local defensive = (cfg.main == "Defensive")
    if defensive and yaw_direction == 0 then
        if cfg.def_en then
            ref.pitch[1]:override("Custom")
            if cfg.pitch_type == "Static" then
                pitch = cfg.pitch_static
            elseif cfg.pitch_type == "Jitter" then
                pitch = dele2 and cfg.pitch_mode1 or cfg.pitch_mode2
            elseif cfg.pitch_type == "Random" then
                pitch = client.random_int(cfg.pitch_mode1, cfg.pitch_mode2)
            elseif cfg.pitch_type == "Spin" then
                pitch = antiaim.spin_pitch(cfg.pitch_mode1, cfg.pitch_mode2, cfg.pitch_speed, 1)
            elseif cfg.pitch_type == "Spin[MOD]" then
                pitch = antiaim.get_pitch_value(cfg.pitch_mode1, cfg.pitch_mode2, cfg.pitch_speed)
            elseif cfg.pitch_type == "Random Ticks" then
                if globals.tickcount() % 3 == 0 then
                    pitch = 89
                elseif globals.tickcount() % 3 == 1 then
                    pitch = -89
                else
                    pitch = 0
                end
            end
            ref.pitch[2]:override(pitch)

            if cfg.yaw_def == "Static" then
                ref.yaw[2]:override(cfg.yaw_amount)
            elseif cfg.yaw_def == "Jitter" then
                ref.yaw[2]:override(dele2 and cfg.yaw_left or cfg.yaw_right)
            elseif cfg.yaw_def == "Jitter[L/R]" then
                ref.yaw[2]:override(dele2 and -cfg.yaw_amount or cfg.yaw_amount)
            elseif cfg.yaw_def == "Spin" then
                ref.yaw[2]:override(lerping(-cfg.yaw_amount, cfg.yaw_amount, globals.curtime() * cfg.def_spin_speed / 10 % 2 - 1))
            elseif cfg.yaw_def == "Random" then
                ref.yaw[2]:override(math.random(-cfg.yaw_amount, cfg.yaw_amount))
            elseif cfg.yaw_def == "3-way" then
                local ways3 = {-cfg.yaw_amount, 0, cfg.yaw_amount}
                ref.yaw[2]:override(ways3[(globals.tickcount() % 3) + 1])
            elseif cfg.yaw_def == "5-way" then
                local ways5 = {-cfg.yaw_amount, -cfg.yaw_amount / 2, 0, cfg.yaw_amount / 2, cfg.yaw_amount}
                ref.yaw[2]:override(ways5[(globals.tickcount() % 5) + 1])
            elseif cfg.yaw_def == "Static[FS]" then
                ref.yaw[2]:override(cfg.yaw_amount)
            else
                ref.yaw[2]:override(0)
            end

            if has_value(cfg.adaptive_desync, 'Adaptive Desync') then
                ref.bodyyaw[1]:override("Static")
                ref.bodyyaw[2]:override(to_jitter and -60 or 60)
            end
        end
    else
        ref.yaw[2]:override(yaw_amount)
    end
end

local function setup_visibility()
    local visible = ref.enabled:get()
    local tab = menu.antiaim.selection:get()
    local tab3 = " Builder"
    local tab4 = " Features"
    local tab5 = " Other"

    for i = 1, #antiaim_cond do
        local cond = {menu.antiaim.condition, antiaim_cond[i]}
        local state = {builder[i].enabled, true}
        local yaw = {builder[i].main, "Yaw"}
        local vis = visible

        builder[i].lb1:depend(tab, tab3, cond)
        builder[i].enabled:depend(tab, tab3, cond)
        builder[i].state:depend(tab, tab3, cond)
        builder[i].label1:depend(tab, tab3, cond, state)
        builder[i].label2:depend(tab, tab3, cond, state)
        builder[i].main:depend(tab, tab3, cond, state)

        builder[i].lb_pizdec:depend(tab, tab3, cond, state)
        builder[i].lb_brute:depend(tab, tab3, cond, state)
        builder[i].brute_mode:depend(tab, tab3, cond, state)
        builder[i].delay_force:depend(tab, tab3, cond, state, {builder[i].brute_mode, "Adaptive", "Decrease", "Increase"})
        builder[i].duration_brute:depend(tab, tab3, cond, state, {builder[i].brute_mode, "Adaptive", "Decrease", "Increase"})

        builder[i].label3:depend(tab, tab3, cond, state, yaw)
        builder[i].offset_lb:depend(tab, tab3, cond, state, yaw)
        builder[i].offset:depend(tab, tab3, cond, state, yaw)
        builder[i].offset_lb1:depend(tab, tab3, cond, state, yaw)
        builder[i].ofs_lb_1:depend(tab, tab3, cond, state, yaw)
        builder[i].ofs_tp_1:depend(tab, tab3, cond, state, yaw)
        builder[i].ofs_ways_delay_1:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_1, "Way"})
        builder[i].ofs_way_1:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_1, "Way"})
        for j = 1, 5 do
            builder[i].ofs_ways_1[j]:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_1, "Way"})
        end
        builder[i].ofs_1:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_1, "Default"})

        builder[i].ofs_lb_2:depend(tab, tab3, cond, state, yaw)
        builder[i].ofs_tp_2:depend(tab, tab3, cond, state, yaw)
        builder[i].ofs_ways_delay_2:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_2, "Way"})
        builder[i].ofs_way_2:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_2, "Way"})
        for j = 1, 5 do
            builder[i].ofs_ways_2[j]:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_2, "Way"})
        end
        builder[i].ofs_2:depend(tab, tab3, cond, state, yaw, {builder[i].ofs_tp_2, "Default"})

        builder[i].label4:depend(tab, tab3, cond, state, yaw)
        builder[i].label5:depend(tab, tab3, cond, state, yaw)
        builder[i].yaw_mode:depend(visible, state, cond, yaw, vis)
        builder[i].spna_switch:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Spin"}, vis)
        builder[i].spna:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Spin"}, vis)
        builder[i].spna2:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Spin"}, vis, {builder[i].spna_switch, true})
        builder[i].spna_speed:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Spin"}, vis)
        builder[i].spna_speed2:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Spin"}, vis, {builder[i].spna_switch, true})
        builder[i].rana_switch:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Random"}, vis)
        builder[i].rana:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Random"}, vis)
        builder[i].rana2:depend(visible, state, cond, yaw, {builder[i].yaw_mode, "Random"}, vis, {builder[i].rana_switch, true})

        builder[i].label7:depend(tab, tab3, cond, state, yaw)
        builder[i].label6:depend(tab, tab3, cond, state, yaw)
        builder[i].yaw_jitter:depend(tab, tab3, cond, state, yaw)
        builder[i].xway_slider:depend(tab, tab3, cond, state, yaw, {builder[i].yaw_jitter, "X-Way"})
        builder[i].xway_jitter:depend(tab, tab3, cond, state, yaw, {builder[i].yaw_jitter, "X-Way"})
        builder[i].yawjitter:depend(tab, tab3, cond, state, yaw, {builder[i].yaw_jitter, "Center", "Offset", "Skitter", "Random"})

        builder[i].label8:depend(tab, tab3, cond, state, yaw)
        builder[i].label9:depend(tab, tab3, cond, state, yaw)
        builder[i].bodyyaw:depend(tab, tab3, cond, state, yaw)
        builder[i].bd_type:depend(tab, tab3, cond, state, yaw, {builder[i].bodyyaw, "Static", "Jitter", "Opposite"})
        builder[i].body_type:depend(tab, tab3, cond, state, yaw, {builder[i].bodyyaw, "Static", "Jitter", "Opposite"})
        builder[i].body_static:depend(tab, tab3, cond, state, yaw, {builder[i].bodyyaw, "Static", "Jitter", "Opposite"}, {builder[i].bd_type, "Gamesense"})
        builder[i].body_left:depend(tab, tab3, cond, state, yaw, {builder[i].bodyyaw, "Static", "Jitter", "Opposite"}, {builder[i].bd_type, "Advanced"})
        builder[i].body_right:depend(tab, tab3, cond, state, yaw, {builder[i].bodyyaw, "Static", "Jitter", "Opposite"}, {builder[i].bd_type, "Advanced"})

        builder[i].label11:depend(tab, tab3, cond, state)
        builder[i].delay_method:depend(tab, tab3, cond, state)
        builder[i].delay_switch:depend(tab, tab3, cond, state)
        builder[i].delay:depend(tab, tab3, cond, state, {builder[i].delay_method, "Default"})
        builder[i].random_delay:depend(tab, tab3, cond, state, {builder[i].delay_method, "Default"})
        builder[i].delay_fluc:depend(tab, tab3, cond, state, {builder[i].delay_switch, "Fluctuate"})
        builder[i].hold_ticks:depend(tab, tab3, cond, state, {builder[i].delay_switch, "Hold ticks"})
        builder[i].ways:depend(tab, tab3, cond, state, {builder[i].delay_method, "Ways"})
        for j = 1, 10 do
            builder[i].way_del[j]:depend(tab, tab3, cond, state, {builder[i].delay_method, "Ways"})
        end

        builder[i].force_lc:depend(tab, tab3, cond, state)

        local def = {builder[i].main, "Defensive"}
        builder[i].def_en:depend(tab, tab3, cond, state, def)
        builder[i].pitch_type:depend(tab, tab3, cond, state, def, {builder[i].def_en, true})
        builder[i].pitch_static:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].pitch_type, "Static"})
        builder[i].pitch_mode1:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].pitch_type, 'Jitter', 'Spin', 'Spin[MOD]', 'Random'})
        builder[i].pitch_mode2:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].pitch_type, 'Jitter', 'Spin', 'Spin[MOD]', 'Random'})
        builder[i].pitch_speed:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].pitch_type, 'Spin', 'Spin[MOD]'})
        builder[i].pitch_jitter_speed:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].pitch_type, 'Jitter'})
        builder[i].pitch_slow_def:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].pitch_type, 'Random'})
        builder[i].yaw_def:depend(tab, tab3, cond, state, def, {builder[i].def_en, true})
        builder[i].yaw_amount:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].yaw_def, "Static", "Static[FS]", "Spin", "Random", "3-way", "5-way"})
        builder[i].yaw_left:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].yaw_def, "Jitter", "Jitter[L/R]"})
        builder[i].yaw_right:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].yaw_def, "Jitter", "Jitter[L/R]"})
        builder[i].def_jitter_speed:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].yaw_def, "Jitter", "Jitter[L/R]"})
        builder[i].def_spin_speed:depend(tab, tab3, cond, state, def, {builder[i].def_en, true}, {builder[i].yaw_def, "Spin"})
        builder[i].adaptive_desync:depend(tab, tab3, cond, state, def, {builder[i].def_en, true})
    end

    menu.antiaim.lb_features:depend(tab, tab4)
    menu.antiaim.features:depend(tab, tab4)
    menu.antiaim.label4:depend(tab, tab4)
    menu.antiaim.lb_yaw_direction:depend(tab, tab4)
    menu.antiaim.yaw_direction:depend(tab, tab4)
    menu.antiaim.label12:depend(tab, tab4, {menu.antiaim.yaw_direction, "Edge Yaw", "Freestanding"})
    menu.antiaim.edge_yaw:depend(tab, tab4, {menu.antiaim.yaw_direction, "Edge Yaw"})
    menu.antiaim.label5:depend(tab, tab4, {menu.antiaim.yaw_direction, "Freestanding"})
    menu.antiaim.freestanding_hotkey:depend(tab, tab4, {menu.antiaim.yaw_direction, "Freestanding"})
    menu.antiaim.lb_freestanding_disablers:depend(tab, tab4, {menu.antiaim.yaw_direction, "Freestanding"})
    menu.antiaim.freestanding_disablers:depend(tab, tab4, {menu.antiaim.yaw_direction, "Freestanding"})
    menu.antiaim.lb_manuals_disablers:depend(tab, tab4, {menu.antiaim.yaw_direction, "Manuals"})
    menu.antiaim.manuals_disablers:depend(tab, tab4, {menu.antiaim.yaw_direction, "Manuals"})
    menu.antiaim.manuals_left:depend(tab, tab4, {menu.antiaim.yaw_direction, "Manuals"})
    menu.antiaim.manuals_right:depend(tab, tab4, {menu.antiaim.yaw_direction, "Manuals"})
    menu.antiaim.manuals_forward:depend(tab, tab4, {menu.antiaim.yaw_direction, "Manuals"})
    menu.antiaim.manuals_reset:depend(tab, tab4, {menu.antiaim.yaw_direction, "Manuals"})

    menu.antiaim.lb12:depend(tab, tab5)
    menu.antiaim.fake_label:depend(tab, tab5)
    menu.antiaim.fakeenabled:depend(tab, tab5)
    menu.antiaim.fake_amount:depend(tab, tab5, {menu.antiaim.fakeenabled, true})
    menu.antiaim.fake_variance:depend(tab, tab5, {menu.antiaim.fakeenabled, true})
    menu.antiaim.fake_limit:depend(tab, tab5, {menu.antiaim.fakeenabled, true})

    ref.yaw[1]:set_visible(visible)
    ref.yaw[2]:set_visible(visible)
    ref.yawjitter[1]:set_visible(visible)
    ref.yawjitter[2]:set_visible(visible)
    ref.bodyyaw[1]:set_visible(visible)
    ref.bodyyaw[2]:set_visible(visible)
    ref.edgeyaw:set_visible(visible)
    ref.fsbodyyaw:set_visible(visible)
end

client.set_event_callback('setup_command', run_antiaim)
client.set_event_callback('paint', setup_visibility)

menu.antiaim.side_switch:set_callback(function()
    local side = menu.antiaim.side_switch:get()
    aa_side.save_to_custom(current_side)
    current_side = side
    aa_side.load_from_custom(side)
end)
