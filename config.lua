Config = {}
Config.Interior = vector3(-814.89, 181.95, 76.85) -- Interior to load where characters are previewed
Config.DefaultSpawn = vector3(-1035.71, -2731.87, 12.86) -- Default spawn coords if you have start apartments disabled
Config.PedCoords = vector4(-813.97, 176.22, 76.74, -7.5) -- Create preview ped at these coordinates
Config.HiddenCoords = vector4(-812.23, 182.54, 76.74, 156.5) -- Hides your actual ped while you are in selection
Config.CamCoords = vector4(-813.46, 178.95, 76.85, 174.5) -- Camera coordinates for character preview screen
Config.EnableDeleteButton = true -- Define if the player can delete the character or not
Config.customNationality = false -- Defines if Nationality input is custom of blocked to the list of Countries
Config.SkipSelection = true -- Skip the spawn selection and spawns the player at the last location

Config.DefaultNumberOfCharacters = 4 -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = { -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", numberOfChars = 2 },
}
Config.pedModels = {
    'mp_m_freemode_01',
    'mp_m_freemode_01',
    'mp_m_freemode_01'
}

Config.Clothes = {
    ped2 = {
        jacket = {old = 38, tex = 0, pal = 0},
        shirt = {old = 15, tex = 0, pal = 0},
        arms = {old = 11, tex = 0, pal = 0},
        pants = {old = 9, tex = 7, pal = 0},
        feet = {old = 7, tex = 0, pal = 0},
        mask = {old = 0, tex = 0, pal = 0},
        vest = {old = 0, tex = 0, pal = 0},
        face = {old = 43, tex = 0, pal = 0},
        hair = {old = 11, tex = 1, pal = 0},
        hat = {prop = -1, tex = 0},
        glass = {prop = 5, tex = 0}
    },
    ped3 = {
        jacket = {old = 98, tex = 1, pal = 0},
        shirt = {old = 15, tex = 0, pal = 0},
        arms = {old = 11, tex = 0, pal = 0},
        pants = {old = 59, tex = 9, pal = 0},
        feet = {old = 25, tex = 0, pal = 0},
        mask = {old = 0, tex = 0, pal = 0},
        vest = {old = 15, tex = 2, pal = 0},
        face = {old = 42, tex = 0, pal = 0},
        hair = {old = 3, tex = 5, pal = 0},
        hat = {prop = -1, tex = 0},
        glass = {prop = 15, tex = 2}
    },
    ped4 = {
        jacket = {old = 111, tex = 0, pal = 0},
        shirt = {old = 15, tex = 0, pal = 0},
        arms = {old = 4, tex = 0, pal = 0},
        pants = {old = 52, tex = 2, pal = 0},
        feet = {old = 21, tex = 0, pal = 0},
        mask = {old = 0, tex = 0, pal = 0},
        vest = {old = 0, tex = 0, pal = 0},
        face = {old = 42, tex = 0, pal = 0},
        hair = {old = 15, tex = 2, pal = 0},
        hat = {prop = -1, tex = 0},
        glass = {prop = 10, tex = 0}
    }
}

Config.pedDefault = "ig_djsolfotios"

Config.Cutscenes = {
    {cutscene = "mph_fin_cel_roo", coords = {x = 704.0, y = -962.88, z = 36.85}},
    {cutscene = "mph_pac_con_ext", coords = {x = 1963.43, y = 5160.29, z = 47.2}},
    {cutscene = "mph_pac_fin_mcs0", coords = {x = 234.02, y = 218.39, z = 106.29}},
    {cutscene = "mph_pac_fin_mcs1", coords = {x = 234.02, y = 218.39, z = 106.29}},
    {cutscene = "mph_pac_hac_mcs1", coords = {x = 56.55, y = 155.6, z = 104.65}},
    {cutscene = "sum23_cm6_ext", coords = {x = -2185.0, y = 3276.25, z = 32.81}},
    {cutscene = "tunf_iaa_mcs1", coords = {x = 2055.2, y = 2960.88, z = -67.31}},
    {cutscene = "tunf_uni_vlt", coords = {x = -3.62, y = -685.35, z = 16.13}},
    {cutscene = "hs3_ext", coords = {x = 750.87, y = 221.78, z = 146.12}}
}

