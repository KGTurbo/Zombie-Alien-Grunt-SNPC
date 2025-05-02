
if CLIENT then language.Add("npc_zombie_alien_grunt", "Zombie Alien Grunt") end
----

game.AddParticles( "particles/npc_snark.pcf")

--- Spawnmenu

list.Set( "NPC", "npc_zombie_alien_grunt", {
Name = "#npc_zombie_alien_grunt",
Category = "#spawnmenu.category.zombies_aliens",
Class = "npc_zombie_alien_grunt"
} )


----

--- Sounds

local function AddSd(name, tbl, tbl2)
sound.Add({
    name = name,
    level = tbl.l,
    pitch = tbl.p,
    channel = tbl.c,
    volume = tbl.v,
    sound = tbl2
})
end
 -- Thanks, Nova
AddSd("npc_zombie_alien_grunt.Pain", {l=80,p={100,105},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_pain1.wav",
"npc/zombie_alien_grunt/zgrunt_pain2.wav",
"npc/zombie_alien_grunt/zgrunt_pain3.wav",
})

AddSd("npc_zombie_alien_grunt.Die", {l=80,p={95,105},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_die1.wav",
"npc/zombie_alien_grunt/zgrunt_die2.wav",
"npc/zombie_alien_grunt/zgrunt_die3.wav",
})

AddSd("npc_zombie_alien_grunt.Idle", {l=75,p={95,105},v=0.8,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_idle1.wav",
"npc/zombie_alien_grunt/zgrunt_idle2.wav",
"npc/zombie_alien_grunt/zgrunt_idle3.wav",
"npc/zombie_alien_grunt/zgrunt_idle4.wav",
"npc/zombie_alien_grunt/zgrunt_idle5.wav",
})


AddSd("npc_zombie_alien_grunt.Melee", {l=78,p={95,105},v=0.8,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_attack1.wav",
"npc/zombie_alien_grunt/zgrunt_attack2.wav",
"npc/zombie_alien_grunt/zgrunt_attack3.wav",
})

AddSd("npc_zombie_alien_grunt.Melee_Hit", {l=78,p={95,105},v=0.8,c=CHAN_WEAPON}, {
"npc/zombie_alien_grunt/melee_strike1.wav",
"npc/zombie_alien_grunt/melee_strike2.wav",
"npc/zombie_alien_grunt/melee_strike3.wav",
})

AddSd("npc_zombie_alien_grunt.Slap", {l=80,p={95,105},v=0.8,c=CHAN_WEAPON}, {
"npc/zombie_alien_grunt/agrunt_slap01.wav",
"npc/zombie_alien_grunt/agrunt_slap02.wav",
})

AddSd("npc_zombie_alien_grunt.Attack", {l=78,p={95,105},v=0.8,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_attack1.wav",
"npc/zombie_alien_grunt/zgrunt_attack2.wav",
"npc/zombie_alien_grunt/zgrunt_attack3.wav",
})

AddSd("npc_zombie_alien_grunt.Alert", {l=85,p={95,100},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_alert1.wav",
"npc/zombie_alien_grunt/zgrunt_alert2.wav",
"npc/zombie_alien_grunt/zgrunt_alert3.wav",
})

AddSd("npc_zombie_alien_grunt.Charge_Smack", {l=80,p={95,100},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_charge_smack1.wav",
"npc/zombie_alien_grunt/zgrunt_charge_smack2.wav",
})

AddSd("npc_zombie_alien_grunt.Charge_Stop", {l=80,p={95,100},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_charge_stop1.wav",
})

AddSd("npc_zombie_alien_grunt.Charge_Start", {l=85,p={95,100},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_charge_start1.wav",
"npc/zombie_alien_grunt/zgrunt_charge_start2.wav",
})

AddSd("npc_zombie_alien_grunt.Charge_Crash", {l=80,p={95,100},v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/zgrunt_charge_crash1.wav",
})

AddSd("npc_zombie_alien_grunt.Breath", {l=65,p=100,v=0.7,c=CHAN_AUTO}, {
"npc/zombie_alien_grunt/breath_1.wav",
})

AddSd("npc_zombie_alien_grunt.Jump", {l=75,p=100,v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/jump_1.wav",
})

AddSd("npc_zombie_alien_grunt.Land", {l=75,p=100,v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/land_1.wav",
})

AddSd("npc_zombie_alien_grunt.LandThud", {l=80,p=100,v=0.5,c=CHAN_BODY}, {
"npc/zombie_alien_grunt/land1.wav",
})

AddSd("npc_zombie_alien_grunt.StepR", {l=60,p={98,102},v=0.5,c=CHAN_BODY}, {
"npc/zombie_alien_grunt/step1.wav",
"npc/zombie_alien_grunt/step2.wav",
})

AddSd("npc_zombie_alien_grunt.StepL", {l=65,p={98,102},v=0.7,c=CHAN_BODY}, {
"npc/zombie_alien_grunt/step3.wav",
"npc/zombie_alien_grunt/step4.wav",
})
---


--- Settings

local AddConvars = {}
	AddConvars["sk_npc_zombie_alien_grunt_health"] = 310
	AddConvars["sv_enable_zombie_grunt_charge"] = 1
	AddConvars["sv_enable_zombie_grunt_ko"] = 1
	AddConvars["sv_enable_zombie_grunt_leap"] = 1
	AddConvars["sv_enable_zombie_grunt_door_breaking"] = 1
	AddConvars["sv_enable_zombie_grunt_prop_breaking"] = 1
	AddConvars["sv_enable_zombie_grunt_dodging"] = 1
	for k, v in pairs(AddConvars) do
		if !ConVarExists( k ) then CreateConVar( k, v, {FCVAR_REPLICATED, FCVAR_ARCHIVE} ) end
	end
	
	if CLIENT then
	language.Add("sk_npc_zombie_alien_grunt_health", "Health")
	language.Add("sv_enable_zombie_grunt_charge", "Enable Charge Attack?")
	language.Add("sv_enable_zombie_grunt_leap", "Enable Leap Attack?")
	language.Add("sv_enable_zombie_grunt_ko", "Enable Knocking Out?")
	language.Add("sv_enable_zombie_grunt_door_breaking", "Enable Breaking Doors?")
	language.Add("sv_enable_zombie_grunt_prop_breaking", "Enable Breaking Props?")
	language.Add("sv_enable_zombie_grunt_dodging", "Enable Dodging?")
	hook.Add("PopulateToolMenu", "Lima_npc_zombie_alien_grunt", function()
			spawnmenu.AddToolMenuOption("Options", "Limakenori", "#npc_zombie_alien_grunt", "#npc_zombie_alien_grunt", "", "", function(Panel)
				if !game.SinglePlayer() then
				if !LocalPlayer():IsAdmin() or !LocalPlayer():IsSuperAdmin() then
					Panel:AddControl( "Label", {Text = "You are not an admin!"})
					Panel:ControlHelp(".")
					return
					end
				end
				Panel:AddControl("Label", {Text = "Settings"})
				Panel:AddControl("Slider",{Label = "#sk_npc_zombie_alien_grunt_health",min = 1,max = 1000,Command = "sk_npc_zombie_alien_grunt_health"})
				Panel:AddControl("Checkbox", {Label = "#sv_enable_zombie_grunt_charge", Command = "sv_enable_zombie_grunt_charge"})
				Panel:AddControl("Checkbox", {Label = "#sv_enable_zombie_grunt_ko", Command = "sv_enable_zombie_grunt_ko"})
				Panel:AddControl("Checkbox", {Label = "#sv_enable_zombie_grunt_leap", Command = "sv_enable_zombie_grunt_leap"})
				Panel:AddControl("Checkbox", {Label = "#sv_enable_zombie_grunt_dodging", Command = "sv_enable_zombie_grunt_dodging"})
				Panel:AddControl("Checkbox", {Label = "#sv_enable_zombie_grunt_door_breaking", Command = "sv_enable_zombie_grunt_door_breaking"})
				Panel:AddControl("Checkbox", {Label = "#sv_enable_zombie_grunt_prop_breaking", Command = "sv_enable_zombie_grunt_prop_breaking"})
			end, {})
		end)
		end