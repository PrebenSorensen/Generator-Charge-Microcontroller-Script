-- Initialize variables
local on_signal = false
local battery_level = 0
local clutch_engagement = 0
local tick_counter = 0
local update_interval_ticks = 5 * 60 -- Convert 5 seconds to ticks (assuming 60 ticks per second)
local engagement_step = 0.1
local increasing = false
local decreasing = false

function onTick()
    -- Read inputs
    on_signal = input.getBool(1)
    battery_level = input.getNumber(1)
    
    -- If the on signal is off, disengage clutch
    if not on_signal then
        clutch_engagement = 0
        increasing = false
        decreasing = false
    else
        -- Immediate adjustment when conditions are met
        if battery_level < 0.9 and not increasing and clutch_engagement < 1 then
            increasing = true
            decreasing = false
            clutch_engagement = clutch_engagement + engagement_step
            if clutch_engagement > 1 then
                clutch_engagement = 1
                increasing = false
            end
            tick_counter = 0
        elseif battery_level >= 1 and not decreasing and clutch_engagement > 0 then
            decreasing = true
            increasing = false
            clutch_engagement = clutch_engagement - engagement_step
            if clutch_engagement < 0 then
                clutch_engagement = 0
                decreasing = false
            end
            tick_counter = 0
        end
        
        -- Check if enough time has passed to adjust the clutch engagement further
        if tick_counter >= update_interval_ticks then
            if increasing and clutch_engagement < 1 then
                clutch_engagement = clutch_engagement + engagement_step
                if clutch_engagement > 1 then
                    clutch_engagement = 1
                    increasing = false
                end
            elseif decreasing and clutch_engagement > 0 then
                clutch_engagement = clutch_engagement - engagement_step
                if clutch_engagement < 0 then
                    clutch_engagement = 0
                    decreasing = false
                end
            end
            -- Reset the tick counter after adjustment
            tick_counter = 0
        end
    end
    
    -- Increment tick counter
    tick_counter = tick_counter + 1
    
    -- Write output
    output.setNumber(2, clutch_engagement)
end
