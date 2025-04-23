AddCSLuaFile()


ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.Author = "Limakenori"
ENT.PrintName = "#npc_zombie_alien_grunt"
ENT.Spawnable = false
ENT.Category = "Zombies + Enemy Aliens"

if !SERVER then return end

ENT.MyBloodColor = BLOOD_COLOR_GREEN

function ENT:Use(plyuse)
end

function ENT:Initialize()
self:SetSaveValue("m_iClass",CLASS_ZOMBIE)
self:SetModel(self.MyModel or "models/zombie/zombie_alien_grunt.mdl")
self:SetNoDraw(false)
self:DrawShadow(true)
self:SetSquad("zombies")
self:SetSaveValue("m_flFieldOfView",-120.707)
self:SetMaxLookDistance(6000)
self:SetSchedule(SCHED_RUN_RANDOM)
self:SetBloodColor(self.MyBloodColor)
self:SetHealth(GetConVar("sk_npc_zombie_alien_grunt_health"):GetInt())
self:SetMaxHealth(self:Health())
self:SetNavType(NAV_GROUND)
self:SetMoveType(MOVETYPE_STEP)
self:SetSolid(SOLID_BBOX)
self:CapabilitiesAdd(CAP_MOVE_GROUND)
self:SetCollisionGroup(COLLISION_GROUP_NPC)
self:SetHullType( HULL_WIDE_HUMAN )
self:SetHullSizeNormal()
self:ResetSequenceInfo( )
end

-- AI

ENT.ZBaseFaction = "zombie"
ENT.VJ_NPC_Class = {"CLASS_ZOMBIE"}
function ENT:GetRelationship2( ent )
if ent:IsNPC() then 
if ent:GetSquad() == self:GetSquad() then return D_LI end
if ent:Classify() == CLASS_ALIEN_MILITARY then return D_LI end
if ent:GetClass() == self:GetClass() then return D_LI end
if ent:Classify() == CLASS_BULLSEYE then return D_NU end
if ent.ZBaseFaction == "zombie" then return D_LI end
if ent.ZBaseFaction == "neutral" then return D_NU end
if istable(ent.VJ_NPC_Class) && table.HasValue(ent.VJ_NPC_Class,self.VJ_NPC_Class[1]) then return D_LI end
return D_HT end
if ent == self:GetOwner() then return D_LI end
if ent:IsPlayer() then return D_HT end
return D_NU
end

function ENT:GetRelationship( ent )
local rel = self:GetRelationship2( ent )
if ent:IsNPC() then
ent:AddEntityRelationship(self,rel,0)
end
return rel end

ENT.LosingEnemyTime = nil
ENT.TimeUntilLoseEnemy = 2
ENT.NextBite = CurTime()

function ENT:Touch(ene) 
if !IsValid(ene) then return end
if !IsValid(self:GetEnemy()) then
self:UpdateEnemyMemory(ene,ene:GetPos())
end
end

function ENT:ShouldLoseEnemy(ene)
if !self:Visible(ene)  then return true end
return false end

function ENT:LoseEne(ene)
self.LosingEnemyTime = nil
self:ClearEnemyMemory() 
end

function ENT:DoAttack(ene,pos,pos2)
end

local SCHED_ZOMGRUNT_PATROL = ai_schedule.New( "SCHED_ZOMGRUNT_PATROL" )
SCHED_ZOMGRUNT_PATROL:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  300 )
SCHED_ZOMGRUNT_PATROL:EngTask( "TASK_WALK_PATH", 		   0   )
SCHED_ZOMGRUNT_PATROL:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	   0   )

local SCHED_ZOMGRUNT_PATROL_ALERT = ai_schedule.New( "SCHED_ZOMGRUNT_PATROL_ALERT" )
SCHED_ZOMGRUNT_PATROL_ALERT:EngTask( "TASK_GET_PATH_TO_RANDOM_NODE",  400 )
SCHED_ZOMGRUNT_PATROL_ALERT:EngTask( "TASK_RUN_PATH", 		   0   )
SCHED_ZOMGRUNT_PATROL_ALERT:EngTask( "TASK_WAIT_FOR_MOVEMENT", 	   0   )
 
local SCHED_ZOMGRUNT_CHASE_ENEMY = ai_schedule.New( "SCHED_ZOMGRUNT_CHASE_ENEMY" )
SCHED_ZOMGRUNT_CHASE_ENEMY:EngTask( "TASK_GET_PATH_TO_ENEMY",  0 )
SCHED_ZOMGRUNT_CHASE_ENEMY:EngTask( "TASK_RUN_PATH",  0 )
SCHED_ZOMGRUNT_CHASE_ENEMY:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
 
 function ENT:TranslateActivity(act)
 end
 
function ENT:SelectSchedule()
 
 if !IsValid(self:GetEnemy()) then
 if self:GetNPCState() == NPC_STATE_ALERT then
self:StartSchedule(SCHED_ZOMGRUNT_PATROL_ALERT)
 else
self:StartSchedule(SCHED_ZOMGRUNT_PATROL)
end
 else
 self:StartSchedule(SCHED_ZOMGRUNT_CHASE_ENEMY)
 end
 
end


function ENT:Think() 

end

--- Damage / Death
function ENT:DeathExplode()
	local dmginfo = DamageInfo()
    dmginfo:SetInflictor(self)
    dmginfo:SetAttacker((IsValid(self:GetOwner()) && self:GetOwner()) or self)
    dmginfo:SetDamage(10)
	dmginfo:SetDamagePosition(self:GetPos())
    dmginfo:SetDamageType(DMG_BLAST)
    dmginfo:SetDamageForce(self:GetVelocity()*0.6)
	util.BlastDamageInfo(dmginfo, self:GetPos(), 60)
	ParticleEffect("npc_snark_explode", self:GetPos() + self:GetUp()*3, Angle(0,0,0), nil)
	self:EmitSound(self.BlastSounds or "NPC_Snark.Explode")
	end
	
function ENT:DoDeath(dmg)
local iskeepcorp = GetConVar("ai_serverragdolls"):GetBool()
local rag = ents.Create("prop_ragdoll")
rag:SetModel(self:GetModel())
rag:SetPos(self:GetPos())
rag:SetAngles(self:GetAngles())
rag:Spawn()
if !iskeepcorp then
rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end
if self:IsOnFire() or (bit.band(dmg:GetDamageType(),DMG_BLAST) == DMG_BLAST) or (bit.band(dmg:GetDamageType(),DMG_BURN) == DMG_BURN) then
rag:Ignite(math.random(6,8))
end
local dmgpos = dmg:GetDamagePosition()
	for i=0, rag:GetPhysicsObjectCount() - 1 do
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = self:GetBonePosition(self:TranslatePhysBoneToBone(i))
		    physObj:SetPos( pos )
	        physObj:SetAngles( ang )
			local force = dmg:GetDamageForce()*0.05
			if force:Length() < 300 then
			force = dmg:GetDamageForce()*0.1
			end
            physObj:SetVelocity(force)
	end
hook.Run("CreateEntityRagdoll", self, rag)
if bit.band(dmg:GetDamageType(),DMG_DISSOLVE) == DMG_DISSOLVE then
local dis = ents.Create("env_entity_dissolver")
dis:SetKeyValue("dissolvetype", 0)
rag:SetName( "mindtroller_disdoll_" .. rag:EntIndex() )
dis:SetKeyValue("target", rag:GetName())
dis:Fire("Dissolve", rag:GetName())
dis:Spawn()
rag:DeleteOnRemove(dis)
end
undo.ReplaceEntity( rag, self )
cleanup.ReplaceEntity( rag, self )
end

function ENT:DoDeath( dmg )
    if self.Dead then return end
    self.Dead = true	 
self:DoDeath(dmg)
	hook.Run("OnNPCKilled", self, dmg:GetAttacker(),dmg:GetInflictor())
    self:Remove()
end

function ENT:OnTakeDamage( dmg )

if IsValid(dmg:GetAttacker()) && dmg:GetAttacker().IsSnark && dmg:GetAttacker() != self then return end
self:SetHealth(self:Health() - dmg:GetDamage())
if self:Health() <= 0 then
self:DoDeath( dmg )
end

end

function ENT:OnRemove()
end
