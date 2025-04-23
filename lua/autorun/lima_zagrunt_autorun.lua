--- Names

if CLIENT then
language.Add("npc_zombie_alien_grunt", "Zombie Alien Grunt")
end

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

AddSd("npc_zombie_alien_grunt.Breath", {l=65,p=100,v=0.7,c=CHAN_AUTO}, {
"npc/zombie_alien_grunt/breath_1.wav",
})

AddSd("npc_zombie_alien_grunt.Jump", {l=75,p=100,v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/jump.wav",
})

AddSd("npc_zombie_alien_grunt.Land", {l=75,p=100,v=0.9,c=CHAN_VOICE}, {
"npc/zombie_alien_grunt/land.wav",
})

AddSd("npc_zombie_alien_grunt.LandThud", {l=85,p=100,v=0.9,c=CHAN_BODY}, {
"npc/zombie_alien_grunt/step_6_new.wav",
"npc/zombie_alien_grunt/step_7_new.wav",
"npc/zombie_alien_grunt/step_8_new.wav",
})

AddSd("npc_zombie_alien_grunt.StepR", {l=65,p={98,102},v=0.7,c=CHAN_BODY}, {
"npc/zombie_alien_grunt/step_1.wav",
"npc/zombie_alien_grunt/step_2.wav",
"npc/zombie_alien_grunt/step_3.wav",
"npc/zombie_alien_grunt/step_6_new.wav",
"npc/zombie_alien_grunt/step_7_new.wav",
})

AddSd("npc_zombie_alien_grunt.StepL", {l=65,p={98,102},v=0.7,c=CHAN_BODY}, {
"npc/zombie_alien_grunt/step_4.wav",
"npc/zombie_alien_grunt/step_5.wav",
"npc/zombie_alien_grunt/step_3.wav",
"npc/zombie_alien_grunt/step_8_new.wav",
"npc/zombie_alien_grunt/step_9_new.wav",
"npc/zombie_alien_grunt/step_10_new.wav",
})
---


--- Settings

local AddConvars = {}
	AddConvars["sk_npc_zombie_alien_grunt_health"] = 310
	for k, v in pairs(AddConvars) do
		if !ConVarExists( k ) then CreateConVar( k, v, {FCVAR_REPLICATED, FCVAR_ARCHIVE} ) end
	end