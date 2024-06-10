local fx = require("fx/lib/fx")
local mod = require 'core/mods'
local hook = require 'core/hook'
local tab = require 'tabutil'
-- Begin post-init hack block
if hook.script_post_init == nil and mod.hook.patched == nil then
    mod.hook.patched = true
    local old_register = mod.hook.register
    local post_init_hooks = {}
    mod.hook.register = function(h, name, f)
        if h == "script_post_init" then
            post_init_hooks[name] = f
        else
            old_register(h, name, f)
        end
    end
    mod.hook.register('script_pre_init', '!replace init for fake post init', function()
        local old_init = init
        init = function()
            old_init()
            for i, k in ipairs(tab.sort(post_init_hooks)) do
                local cb = post_init_hooks[k]
                print('calling: ', k)
                local ok, error = pcall(cb)
                if not ok then
                    print('hook: ' .. k .. ' failed, error: ' .. error)
                end
            end
        end
    end)
end
-- end post-init hack block


local FxShimmer = fx:new{
    subpath = "/fx_shimmer"
}

function FxShimmer:add_params()
    params:add_group("fx_shimmer", "fx shimmer", 12)
    FxShimmer:add_slot("fx_shimmer_slot", "slot")
    params:add_separator("fx_shimmer_verb_params", "reverb")
    FxShimmer:add_control("fx_shimmer_freq", "freq", "freq", controlspec.new(20, 16000, "exp", 0, 1000), function(param) return util.round(param:get(), 1).."hz" end)
    FxShimmer:add_option("fx_shimmer_type", "type", "type", {"lpf", "hpf"}, 1 , {0, 1})
    FxShimmer:add_control("fx_shimmer_room", "room", "room", controlspec.new(0, 1, "lin", 0.01, 0.8), function(param) return util.round(param:get() * 100, 1).."%" end)
    FxShimmer:add_control("fx_shimmer_damp", "damp", "damp", controlspec.new(0, 1, "lin", 0.01, 0.7), function(param) return util.round(param:get() * 100, 1).."%" end)
    params:add_separator("fx_shimmer_pitch_params", "shimmer")
    FxShimmer:add_control("fx_shimmer_shimmer", "amount", "shimmer", controlspec.new(0.00, 1.00, "lin", 0.01, 0.2), function(param) return util.round(param:get() * 100, 1).."%" end)
    FxShimmer:add_control("fx_shimmer_pitchRatio", "pitch ratio", "pitchRatio", controlspec.new(0, 4.0, "lin", 0, 2.0))
    FxShimmer:add_control("fx_shimmer_pitchDisp", "pitch dispersal", "pitchDisp", controlspec.new(0.00, 1.00, "lin", 0.01, 0.2), function(param) return util.round(param:get() * 100, 1).."%" end)
    FxShimmer:add_control("fx_shimmer_timeDisp", "time dispersal", "timeDisp", controlspec.new(0.00, 0.50, "lin", 0.01, 0.12), function(param) return util.round(param:get(), 0.01).."s" end)
end

mod.hook.register("script_post_init", "fx shimmer mod post init", function()
    FxShimmer:add_params()
end)

mod.hook.register("script_post_cleanup", "shimmer mod post cleanup", function()
end)

return FxShimmer