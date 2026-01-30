['sangue'] = {
    label = 'Sangue',
    weight = 0.250,
    stack = true,
    close = true,
    description = 'Sangue fresco',
    consume = 1,
    
    client = {
        image = 'sangue.png',
        
        status = {
            hunger = 30,
            thirst = 20,
        },
        
        anim = {
            dict = 'mp_player_intdrink',
            clip = 'loop_bottle',
            flag = 49,
        },
        
        prop = {
            model = `prop_cs_bottle_01`,
            pos = vec3(0.02, 0.02, -0.02),
            rot = vec3(-15.0, 50.0, 0.0),
        },
        
        usetime = 2500,
        
        notification = 'Ti sei nutrito di sangue fresco!',
        
        --  SOLO VAMPIRI POSSONO USARE
        canUse = function(source, item)
            local playerPed = GetPlayerPed(source)
            local isVampire = false
            
            -- Controlla se il player è vampiro tramite state bag
            local form = LocalPlayer.state.fantasyForm
            if form == 'vampire' then
                isVampire = true
            end
            
            -- Fallback: controlla Entity state
            if not isVampire then
                isVampire = Entity(playerPed).state.isVampire or false
            end
            
            if not isVampire then
                TriggerClientEvent('ox_lib:notify', source, {
                    title = 'BLEAH!',
                    description = 'Non sembra commestibile',
                    type = 'error'
                })
                return false
            end
            
            return true
        end,
        
        -- Effetti speciali per vampiri
        export = 'fantasy_peds.UseBloodItem'
    }
},
