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
self:SetBodygroup(1,1)
self:SetNoDraw(false)
self:DrawShadow(true)
self:SetSquad("zombies")
self:SetFOV(90)
self:SetMaxLookDistance(6000)
self:SetSchedule(SCHED_RUN_RANDOM)
self:SetBloodColor(self.MyBloodColor)
self:SetHealth(GetConVar("sk_npc_zombie_alien_grunt_health"):GetInt())
self:SetMaxHealth(self:Health())
self:SetNavType(NAV_GROUND)
self:SetMoveType(MOVETYPE_STEP)
self:SetSolid(SOLID_BBOX)
self:CapabilitiesAdd(CAP_MOVE_GROUND)
self:CapabilitiesAdd(CAP_MOVE_JUMP)
self:SetCollisionGroup(COLLISION_GROUP_NPC)
self:SetHullType( HULL_WIDE_HUMAN )
self:SetHullSizeNormal()
self:ResetSequenceInfo( )
self:SetNPCState(NPC_STATE_IDLE)
self.LastState = NPC_STATE_IDLE
self:DropToFloor()
local min,max = self:GetModelBounds()
self:SetSurroundingBounds( min, max )
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

local SCHED_ZOMGRUNT_CHASE_ENEMY = ai_schedule.New( "SCHED_ZOMGRUNT_CHASE_ENEMY" )
SCHED_ZOMGRUNT_CHASE_ENEMY:EngTask( "TASK_GET_PATH_TO_ENEMY",  0 )
SCHED_ZOMGRUNT_CHASE_ENEMY:EngTask( "TASK_RUN_PATH",  0 )
SCHED_ZOMGRUNT_CHASE_ENEMY:EngTask( "TASK_WAIT_FOR_MOVEMENT",  0 )
 
 local SCHED_ZOMGRUNT_ALERT = ai_schedule.New( "SCHED_ZOMGRUNT_ALERT" )
 SCHED_ZOMGRUNT_ALERT:EngTask( "TASK_STOP_MOVING",  0 )
SCHED_ZOMGRUNT_ALERT:AddTask( "TASK_ZAGRUNT_ANGRY",  0 )

 local SCHED_ZOMGRUNT_BIGFLINCH = ai_schedule.New( "SCHED_ZOMGRUNT_BIGFLINCH" )
 SCHED_ZOMGRUNT_BIGFLINCH:EngTask( "TASK_STOP_MOVING",  0 )
SCHED_ZOMGRUNT_BIGFLINCH:AddTask( "TASK_ZAGRUNT_BIGFLINCH",  0 )

local stoptime = 0

function ENT:TaskStart_TASK_ZAGRUNT_ANGRY()
 self:StopMoving()
 self:ResetIdealActivity(self:GetSequenceActivity(self:LookupSequence("angry02")))
 self:EmitSound("npc_zombie_alien_grunt.Alert")
 stoptime = CurTime() + self:SequenceDuration(self:GetSequence()) - 0.6
 
end

function ENT:Task_TASK_ZAGRUNT_ANGRY()
self:StopMoving()
if IsValid(self:GetEnemy()) then
self:SetIdealYawAndUpdate( (self:GetEnemy():GetPos() - self:GetPos()):Angle().y,20 ) end
if CurTime() > stoptime then self:TaskComplete() end
end

function ENT:TaskStart_TASK_ZAGRUNT_BIGFLINCH()
 self:StopMoving()
 self:ResetIdealActivity(ACT_BIG_FLINCH)
 stoptime = CurTime() + self:SequenceDuration(self:GetSequence()) - 0.6
 
end

function ENT:Task_TASK_ZAGRUNT_BIGFLINCH()
self:StopMoving()
if IsValid(self:GetEnemy()) then
self:SetIdealYawAndUpdate( (self:GetEnemy():GetPos() - self:GetPos()):Angle().y,20 ) end
if CurTime() > stoptime then self:TaskComplete() end
end

 function ENT:TranslateActivity(act)
 if self:GetNPCState() == NPC_STATE_ALERT or self:GetNPCState() == NPC_STATE_COMBAT then
 if act == ACT_RUN then return ACT_RUN_AIM
elseif act == ACT_WALK then return ACT_WALK_AIM
elseif act == ACT_IDLE then return ACT_IDLE_ANGRY
 end end
 end
 
 function ENT:CurrentlyBusy()
 return false end
 
 ENT.NextPatrol = CurTime()
function ENT:SelectSchedule()
 
 if !IsValid(self:GetEnemy()) then
 if CurTime() + self.NextPatrol then
 
 if self:GetNPCState() == NPC_STATE_ALERT then
self:SetSchedule(SCHED_PATROL_RUN)
self.NextPatrol = CurTime() + math.random(1,3)
 else
 self.NextPatrol = CurTime() + math.random(2,6)

self:SetSchedule(SCHED_PATROL_WALK)
end

else

self:SetSchedule(SCHED_IDLE_STAND)
end

 else
 self:StartSchedule(SCHED_ZOMGRUNT_CHASE_ENEMY)
 end
 
end


function ENT:OnChangeState(newstate) 
if newstate == NPC_STATE_COMBAT then
end
end

function ENT:OnCondition( condd )
local ene = self:GetEnemy()
if self:CurrentlyBusy() != true &&  condd == COND.NEW_ENEMY then 
self:StartSchedule(SCHED_ZOMGRUNT_ALERT)
 end
end
function ENT:Think() 
if self:GetNPCState() != self.LastState then
self:OnChangeState(self:GetNPCState())
self.LastState = self:GetNPCState()
self.NextPatrol = CurTime()
end
if self:HasCondition(COND.PROVOKED) then self:Remove() end
end

function ENT:IsJumpLegal(startPos, apex, endPos)
	local dist_apex = startPos:Distance(apex)
	local dist_end = startPos:Distance(endPos)
	local MAX_JUMP_RISE = 550
	local MAX_JUMP_DISTANCE = 650
	local MAX_JUMP_DROP = 800
	if (dist_apex > MAX_JUMP_RISE) or (dist_end > MAX_JUMP_DISTANCE) or ((startPos - endPos).z < -MAX_JUMP_DROP) then return false end
	return true
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

function ENT:HasDMGT(dmgtype, type)
for i=1, #type do
if bit.band(dmgtype,type[i]) == type[i] then
return true end
end
return false end
	
function ENT:DoDeath(dmg, hitgr)
local iskeepcorp = GetConVar("ai_serverragdolls"):GetBool()
local rag = ents.Create("prop_ragdoll")
rag:SetModel(self:GetModel())
rag:SetPos(self:GetPos())
rag:SetAngles(self:GetAngles())
rag:Spawn()
rag:SetBodygroup(1,1)
self:EmitSound("npc_zombie_alien_grunt.Die")
if !iskeepcorp then
rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
end
if self:IsOnFire() or (bit.band(dmg:GetDamageType(),DMG_BLAST) == DMG_BLAST) or (bit.band(dmg:GetDamageType(),DMG_BURN) == DMG_BURN) then
rag:Ignite(math.random(6,8))
end

	for i=0, rag:GetPhysicsObjectCount() - 1 do
		local physObj = rag:GetPhysicsObjectNum(i)
		local pos, ang = self:GetBonePosition(self:TranslatePhysBoneToBone(i))
		    physObj:SetPos( pos )
	        physObj:SetAngles( ang )
			local force = dmg:GetDamageForce()*0.01
			if force:Length() < 300 then
			force = dmg:GetDamageForce()*0.02
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

else

local deathtype = 0
if hitgr == HITGROUP_HEAD then

if dmg:GetDamage() > 15 then
deathtype = 1
	
end

elseif hitgr != HITGROUP_HEAD && !self:HasDMGT(dmg:GetDamageType(),{DMG_BLAST,DMG_RADIATION,DMG_NEVERGIB,DMG_ALWAYSGIB,DMG_BURN,DMG_CLUB,DMG_SLASH,DMG_POISON}) && !self:IsOnFire() then
deathtype = 2

elseif self:HasDMGT(dmg:GetDamageType(),{DMG_BLAST}) then deathtype = 1
end

if deathtype == 1 then

local crabdoll = ents.Create("prop_ragdoll")
crabdoll:SetModel("models/agruntcrabclassic.mdl")
crabdoll:SetPos(self:GetAttachment(self:LookupAttachment("mouth")).Pos)
crabdoll:SetAngles(self:GetAngles())
crabdoll:Spawn()
if rag:IsOnFire() then  crabdoll:Ignite(math.random(6,8)) end
crabdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
for i=0, crabdoll:GetPhysicsObjectCount() - 1 do
		local physObj = crabdoll:GetPhysicsObjectNum(i)
			local force = dmg:GetDamageForce()*0.045
			if force:Length() < 300 then
			force = dmg:GetDamageForce()*0.08
			end
            physObj:AddVelocity(force)
			physObj:AddAngleVelocity(Vector(math.random(-50,50),math.random(-50,50),math.random(-50,50)))
	end
	
 rag:SetBodygroup(1,0)
 
elseif deathtype == 2 then
 rag:SetBodygroup(1,0)
 local crab = ents.Create("npc_headcrab")
 crab:SetPos(self:GetAttachment(self:LookupAttachment("mouth")).Pos)
 crab:SetModel("models/agruntcrabclassic.mdl")
 crab:SetAngles(self:GetAngles())
 crab:Spawn()
 crab:SetModel("models/agruntcrabclassic.mdl")
 crab:Activate()
 crab:SetHealth(crab:Health()*1.2)
 crab:SetMaxHealth(crab:Health())
 crab:SetGroundEntity( NULL )
 crab:AddSpawnFlags( SF_NPC_FALL_TO_GROUND )
 crab:SetSquad(self:GetSquad())
 local mins, maxs = crab:GetModelBounds()
 mins = Vector(mins.x,mins.y,0)
 crab:SetCollisionBounds(mins,maxs)
end

end

undo.ReplaceEntity( rag, self )
cleanup.ReplaceEntity( rag, self )
end

function ENT:Die( dmg, hitgr )
    if self.Dead then return end
    self.Dead = true	 
self:DoDeath(dmg, hitgr)
	hook.Run("OnNPCKilled", self, dmg:GetAttacker(),dmg:GetInflictor())
    self:Remove()
end

ENT.NextPainSound = CurTime()

function ENT:PlayAct( act )
timer.Remove("Zomgrunt_Anim_Timer"..self:EntIndex())
self:StopMoving()
self:TaskComplete()
self:ResetSequenceInfo()
self:SetActivity(ACT_IDLE)
self:SetSchedule(SCHED_ALERT_FACE)
self:SetCondition(COND.NPC_FREEZE)
self:SetSchedule(SCHED_NPC_FREEZE)
self:SetIdealActivity(act)
local num = 0
timer.Create("Zomgrunt_Anim_Timer"..self:EntIndex(), 0.1, self:SequenceDuration(self:GetSequence())*10, function()
num = num + 1
if IsValid(self) then self:AutoMovement(0)
if num >= (self:SequenceDuration(self:GetSequence())*10 - 1) then
self:SetCondition(COND.NPC_UNFREEZE)
self:SelectSchedule()
end
end end)

end

function ENT:OnTakeDamage( dmg )
local hitgr = self:GetInternalVariable("m_LastHitGroup")

if hitgr then dmg:ScaleDamage(1.2) end

if IsValid(dmg:GetAttacker()) && dmg:GetAttacker().IsSnark && dmg:GetAttacker() != self then return end
self:SetHealth(self:Health() - dmg:GetDamage())

if self:Health() <= 0 then
self:Die( dmg, hitgr )

elseif dmg:GetDamage() > 1 then

if CurTime() > self.NextPainSound then

if dmg:GetDamage() > 2 && !self:CurrentlyBusy() then
self:StopMoving()
self:PlayAct(ACT_BIG_FLINCH)
else
if hitgr == HITGROUP_HEAD then
self:AddGesture(ACT_GESTURE_FLINCH_HEAD)
elseif hitgr == HITGROUP_RIGHTARM then
self:AddGesture(ACT_GESTURE_FLINCH_RIGHTARM)
elseif hitgr == HITGROUP_LEFTARM then
self:AddGesture(ACT_GESTURE_FLINCH_LEFTARM)
elseif hitgr == HITGROUP_CHEST then
self:AddGesture(ACT_GESTURE_FLINCH_CHEST)
else
self:AddGesture(ACT_GESTURE_FLINCH_STOMACH)
end end

self.NextPainSound = CurTime() + math.Rand(1.5,2)
end

end

end

function ENT:OnRemove()
end
