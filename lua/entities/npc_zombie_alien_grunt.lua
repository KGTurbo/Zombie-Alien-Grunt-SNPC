AddCSLuaFile()


ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.Author = "Limakenori"
ENT.PrintName = "#npc_zombie_alien_grunt"
ENT.Spawnable = false
ENT.Category = "Zombies + Enemy Aliens"

if !SERVER then return end

ENT.MyBloodColor = BLOOD_COLOR_GREEN
ENT.m_fMaxYawSpeed = 15
function ENT:Use(plyuse)
end

function ENT:Initialize()
self:SetSaveValue("m_iClass",CLASS_ZOMBIE)
self:SetModel(self.MyModel or "models/zombie/zombie_alien_grunt.mdl")
self:SetBodygroup(1,1)
self:SetNoDraw(false)
self:DrawShadow(true)
self:SetSquad("zombies")
self:SetFOV(110)
self:SetMaxLookDistance(9000)
self:SetSchedule(SCHED_RUN_RANDOM)
self:SetBloodColor(self.MyBloodColor)
self:SetHealth(GetConVar("sk_npc_zombie_alien_grunt_health"):GetInt())
self:SetMaxHealth(self:Health())
self:SetNavType(NAV_GROUND)
self:SetMoveType(MOVETYPE_STEP)
self:SetSolid(SOLID_BBOX)
self:CapabilitiesAdd(CAP_MOVE_GROUND)
self:CapabilitiesAdd(CAP_MOVE_JUMP)
self:CapabilitiesAdd(CAP_TURN_HEAD)
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
if ent == self then return D_LI end
if ent:GetSquad() == self:GetSquad() then return D_LI end
if ent:Classify() == CLASS_ZOMBIE then return D_LI end
if ent:Classify() == CLASS_HEADCRAB then return D_LI end
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
 
 local SCHED_ZOMGRUNT_ALERT = ai_schedule.New( "SCHED_ZOMGRUNT_ALERT" )
 SCHED_ZOMGRUNT_ALERT:EngTask( "TASK_STOP_MOVING",  0 )
SCHED_ZOMGRUNT_ALERT:AddTask( "TASK_ZAGRUNT_ANGRY",  0 )

 local SCHED_ZOMGRUNT_BIGFLINCH = ai_schedule.New( "SCHED_ZOMGRUNT_BIGFLINCH" )
 SCHED_ZOMGRUNT_BIGFLINCH:EngTask( "TASK_STOP_MOVING",  0 )
SCHED_ZOMGRUNT_BIGFLINCH:AddTask( "TASK_ZAGRUNT_BIGFLINCH",  0 )

 local SCHED_ZOMGRUNT_CHARGE = ai_schedule.New("ZOMGRUNT_ChargeSchedule")
SCHED_ZOMGRUNT_CHARGE:AddTask("TASK_ZOMGRUNT_CHARGE", 0)

ENT.stoptime = 0

function ENT:TaskStart_TASK_ZAGRUNT_ANGRY()
 self:MoveStop()
 self:ResetIdealActivity(self:GetSequenceActivity(self:LookupSequence("angry02")))
 self:SetIdealActivity(self:GetSequenceActivity(self:LookupSequence("angry02")))
 self:SetActivity(self:GetSequenceActivity(self:LookupSequence("angry02")))
 self:EmitSound("npc_zombie_alien_grunt.Alert")
 self.stoptime = CurTime() + self:SequenceDuration(self:GetSequence()) - 0.55 -- prop_d door_rot
 self.m_flChargeTime = CurTime() + 4
end

function ENT:Task_TASK_ZAGRUNT_ANGRY()
self:MoveStop()
if IsValid(self:GetEnemy()) then
self:SetIdealYawAndUpdate( (self:GetEnemy():GetPos() - self:GetPos()):Angle().y,20 ) end
if CurTime() > self.stoptime then self:SetActivity(ACT_IDLE) self:TaskComplete() end
end

function ENT:HandleAnimEvent( event, eventTime, cycle, type, options ) 
if event > 560 && event < 570 then
self:DoMelee(nil,event)
end

end

function ENT:OnChangeActivity(act)
end

 function ENT:TranslateActivity(act)
 if self:GetNPCState() == NPC_STATE_ALERT or self:GetNPCState() == NPC_STATE_COMBAT then
 if act == ACT_RUN then return ACT_RUN_AIM
elseif act == ACT_WALK then return ACT_WALK_AIM
elseif act == ACT_IDLE then return ACT_IDLE_ANGRY
 end end
 end
 
 function ENT:CurrentlyBusy()
 return self.IsCurrentlyBusy end
 ENT.NextRunRandom = 0
  function ENT:OthersAttacking(ene) 
  
  return false end
  
 ENT.NextPatrol = CurTime()
 

function ENT:SelectSchedule()
 local ene = self:GetEnemy()
 if !IsValid(ene) then
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
 
 if !self.IsCurrentlyBusy && self:CanDoAttack() then
self:MoveStop()
self:StopMoving()
self:StartSchedule(SCHED_ZOMGRUNT_CHARGE)
self.ChargeState = 1
return end

 if ene:WorldSpaceCenter():Distance(self:WorldSpaceCenter()) < 85 then
 self:SetSchedule(SCHED_COMBAT_FACE)
 else
 
  self:SetSchedule(SCHED_CHASE_ENEMY)
  
  
 end
 end
 
end


function ENT:OnChangeState(newstate) 
if newstate == NPC_STATE_COMBAT then
end
end

ENT.NextMeleeT = 0
ENT.NextAlertT = CurTime()

function ENT:OnCondition( condd )
local ene = self:GetEnemy()
if self:CurrentlyBusy() != true &&  condd == COND.NEW_ENEMY && CurTime() > self.NextAlertT then 
self.NextAlertT = CurTime() + math.random(4,10)
self:StartSchedule(SCHED_ZOMGRUNT_ALERT)
 end
end

function ENT:GetSoundInterests()
return	SOUND_WORLD	+ SOUND_COMBAT + SOUND_BULLET_IMPACT + SOUND_CARCASS + SOUND_MEAT	+ SOUND_GARBAGE	+ SOUND_PLAYER_VEHICLE + SOUND_PLAYER
end

function ENT:OverrideMove(inte) 
if self.IsCurrentlyBusy then return true end
end

ENT.NextDodgeT = 0

function ENT:DecideDodge()
local dodge = {}
local vecMins = self:OBBMins() 
local vecMaxs = self:OBBMaxs()
vecMins.z = vecMins.x
vecMaxs.z = vecMaxs.x
local trr = util.TraceHull( {
		start = self:WorldSpaceCenter(),
		endpos = self:WorldSpaceCenter() + self:GetRight()*100,
		maxs = vecMaxs,
		mins = vecMins,
		filter = self
	} ) 
local trl = util.TraceHull( {
		start = self:WorldSpaceCenter(),
		endpos = self:WorldSpaceCenter() - self:GetRight()*100,
		maxs = vecMaxs,
		mins = vecMins,
		filter = self
	} )

if !trr.Hit then
local tr2 = util.TraceLine( {
		start = trr.HitPos,
		endpos = trr.HitPos + Vector(0,0,-100),
		filter = self
	} ) 
	if tr2.Hit then 
	table.insert(dodge,"right")
	end
end	

if !trl.Hit then
local tr2 = util.TraceLine( {
		start = trl.HitPos,
		endpos = trl.HitPos + Vector(0,0,-100),
		filter = self
	} ) 
	if tr2.Hit then 
	table.insert(dodge,"left")
	end
end	

if #dodge > 0 then 
dodge = table.Random(dodge)
else 
dodge = false
end
	
return dodge end

function ENT:IsEneAttacking(ene) 
if ene:GetAmmoCount(ene:GetActiveWeapon():GetPrimaryAmmoType()) > 0 && ((ene:GetActiveWeapon():Clip1() > 0) or (ene:GetActiveWeapon():Clip1() == ene:GetActiveWeapon():GetMaxClip1()) ) && ene:KeyDown(IN_ATTACK) then return true end
if ene:GetAmmoCount(ene:GetActiveWeapon():GetSecondaryAmmoType()) > 0 && ene:KeyDown(IN_ATTACK2) then return true end 
return false end

function ENT:Think() 


--self.m_flChargeTime = 0

if self.IsCurrentlyBusy then
self:AutoMovement(self:GetAnimTimeInterval())
self:StopMoving()


end

if self:GetNPCState() != self.LastState then
self:OnChangeState(self:GetNPCState())
self.LastState = self:GetNPCState()
self.NextPatrol = CurTime()
end

local ene = self:GetEnemy()

if IsValid(ene) && self:Visible(ene) && !self:CurrentlyBusy() && self.ChargeState == 0 then
self:SetIdealYawAndUpdate((ene:GetPos() - self:GetPos()):Angle().y,15)
if GetConVar("sv_enable_zombie_grunt_dodging"):GetBool() == true && self:HasCondition(COND.HAVE_ENEMY_LOS) && IsValid(ene:GetActiveWeapon()) && ene:GetActiveWeapon():GetHoldType() != "melee" && ene:GetActiveWeapon():GetHoldType() != "grenade" 
&& ene:GetActiveWeapon():GetHoldType() != "normal" && ene:GetActiveWeapon():GetHoldType() != "knife" && ene:GetActiveWeapon():GetHoldType() != "camera" &&
 self:IsEneAttacking(ene) && CurTime() > self.NextDodgeT && self:GetPos():Distance(ene:GetPos()) > 400 && ene:IsPlayer() then
self.NextDodgeT = CurTime() + 1
local dodge = self:DecideDodge()
 if dodge then 
 self:PlayAct(self:GetSequenceActivity(self:LookupSequence("dodge_"..dodge)),nil,0.9)
 self.NextDodgeT = CurTime() + math.random(2,3)
 end
end
end

-- Melee

if IsValid(ene) && self.ChargeState == 0 && !self:CurrentlyBusy() && self:Visible(ene) && ene:WorldSpaceCenter():Distance(self:WorldSpaceCenter()) < 85 && CurTime() > self.NextMeleeT then

 if IsValid(ene:GetNW2Entity("ZagruntKnockout")) then
self.NextMeleeT = CurTime() + 4.2
self:MoveStop()
self:PlayAct(ACT_SPECIAL_ATTACK2,ene,3)
 else
self.NextMeleeT = CurTime() + 0.9
if self:IsMoving() then
self:AddGesture(ACT_GESTURE_MELEE_ATTACK1)
else
self:PlayAct(ACT_MELEE_ATTACK1,ene,1.2)
end

 end
 
end

-- Leap

if IsValid(ene) && self:CanDoLeap(ene) && !self:CurrentlyBusy() && self:Visible(ene) && ene:WorldSpaceCenter():Distance(self:WorldSpaceCenter()) < 200 && ene:WorldSpaceCenter():Distance(self:WorldSpaceCenter()) > 90 && (self:GetPos().z - ene:GetPos().z) > -30 && (self:GetPos().z - ene:GetPos().z) < 30 && CurTime() > self.NextLeapT then

self.NextLeapT = CurTime() + math.random(3,7)
self:PlayAct(ACT_MELEE_ATTACK2,ene)
--self:AddGesture(self:GetSequenceActivity(self:LookupSequence("Mgrunt_Charge_Hit")))
 
end

-- Obstruction behaviour
if GetConVar("sv_enable_zombie_grunt_prop_breaking"):GetBool() == true then
local vecMins = self:OBBMins() 
local vecMaxs = self:OBBMaxs()
local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos() + self:GetForward()*80,
		maxs = vecMaxs,
		mins = vecMins,
		filter = self
	} )
local v = tr.Entity
if  CurTime() > self.NextDoorBurst && IsValid(v) && v:GetClass() == "prop_physics" && IsValid(v:GetPhysicsObject())  && v:GetPhysicsObject():GetMass() > 10 && v:GetPhysicsObject():GetMass() < 200   then
self.BeatProp = v
self:AddGesture(ACT_GESTURE_MELEE_ATTACK1)
self.NextDoorBurst = CurTime() + 1
end end

if GetConVar("sv_enable_zombie_grunt_door_breaking"):GetBool() == true then
if !self:CurrentlyBusy() && isvector(self:GetGoalPos()) && CurTime() > self.NextDoorBurst then
local Tr = util.TraceLine({
				start = self:WorldSpaceCenter(),
				endpos = (self:GetGoalPos() - self:WorldSpaceCenter()):GetNormalized()*100,
				filter = self
			})	 
			local v = Tr.Entity
if IsValid(v) && ((Tr.HitPos:Distance(self:GetPos()) < 120 && v:GetClass() == "prop_door_rotating")) then
self.BeatProp = v
			self:PlayAct(ACT_MELEE_ATTACK2,v)
			self.NextDoorBurst = CurTime() + 2.5

			end
 end end
 
end

ENT.NextDoorBurst = CurTime()
ENT.NextLeapT = 0
function ENT:IsJumpLegal(startPos, apex, endPos) -- CanCharge
	local dist_apex = startPos:Distance(apex)
	local dist_end = startPos:Distance(endPos)
	local MAX_JUMP_RISE = 550
	local MAX_JUMP_DISTANCE = 650
	local MAX_JUMP_DROP = 800
	if (dist_apex > MAX_JUMP_RISE) or (dist_end > MAX_JUMP_DISTANCE) or ((startPos - endPos).z < -MAX_JUMP_DROP) then return false end
	return true
end

--- Attacks

ENT.ChargeState = 0
ENT.docheck = false
function ENT:TaskStart_TASK_ZOMGRUNT_CHARGE(task) self:StopMoving() local l = self:AddGesture( self:GetSequenceActivity( self:LookupSequence("mgrunt_charge_anticipation") ))
			self:SetLayerLooping( l, true )
self:EmitSound("npc_zombie_alien_grunt.Charge_Start")
self:SetIdealActivity( self:GetSequenceActivity(self:LookupSequence("mgrunt_charge_start")) )
self:ResetIdealActivity( self:GetSequenceActivity(self:LookupSequence("mgrunt_charge_start")) )
self:StopMoving()
 self.stoptime = CurTime() + 1.8
self.docheck = true
end

ENT.NextCheckDot = CurTime()

function ENT:Task_TASK_ZOMGRUNT_CHARGE(task)
if CurTime() <=  self.stoptime then
self:StopMoving()
self.ChargeState = 1
self.docheck = true
else
if self.docheck && !self:ShouldCharge(nil,nil,nil,true) then self:TaskFail("Cancel") self:StopCharge(true) return end
self.docheck = false
self:ImpactShock(self:GetPos() + self:GetForward()*20,90,5)
if !IsValid(self:GetEnemy()) then self:TaskFail("NoEnemy") end
if !self:CurrentlyBusy() then
self:SetIdealActivity( self:GetSequenceActivity(self:LookupSequence("mgrunt_charge_run")) )
local idealYaw =  self:ChargeSteer()
self:SetIdealYawAndUpdate( idealYaw )
end
local move = self:AutoMovement(self:GetAnimTimeInterval())
if !move then self:TaskFail("Agrunt Can't Move!") end
self:ChargeLookAhead()
end end

function ENT:TaskStart_TASK_ZOMGRUNT_CHARGE_STOP(task)

end

ENT.NextCheckDot = CurTime()

function ENT:StopCharge(cancelled)
self.ChargeState = 0
self:TaskComplete()
self:EmitSound("npc_zombie_alien_grunt.Charge_Stop")
self.NextMeleeT = CurTime() + 1
self.NextLeapT = CurTime() + 2
local anim = "mgrunt_charge_stop"
if cancelled then anim = "mgrunt_charge_cancel" end
self.ForceAvoidDanger = true 
self.m_flChargeTime = CurTime() + self:SequenceDuration(self:LookupSequence(anim)) + math.random(6,8)

timer.Simple(0.1,function() if IsValid(self) then self:PlayAct( self:GetSequenceActivity(self:LookupSequence(anim)) ,nil,1) end end)
end


function ENT:OnTaskFailed(a,b)
if b == "Agrunt Can't Move!" then self:StopCharge() end
if b == "NoEnemy" then self:StopCharge() end
end



function ENT:ShouldCharge( startPos, endPos, useTime, checkcancel )
local ene = self:GetEnemy()
if !IsValid(ene) then return false end
if IsValid(ene:GetNW2Entity("ZagruntKnockout") ) then return false end
startPos = startPos or self:GetPos()
endPos = endPos or ene:GetPos()
if  ( startPos.z - endPos.z ) > 80  then return false end
if  ( startPos.z - endPos.z ) < -80  then return false end
local dist = ene:GetPos():Distance(self:GetPos())
if dist < 256 or dist > 900 then return false end

local tr = util.TraceHull({
				start = self:WorldSpaceCenter(),
				endpos =  ene:WorldSpaceCenter(),
				filter = {self,ene},
				mins = self:OBBMins(),
				maxs = self:OBBMaxs(),
			})
			if tr.HitWorld then return false end
			local trent = tr.Entity
			if IsValid(trent) then
			if self:Disposition(trent) == D_LI then return false end
			if IsValid(trent:GetPhysicsObject()) && (trent:GetPhysicsObject():GetMass() > 70 or !trent:GetPhysicsObject():IsMotionEnabled()) then return false end
			end
if self:GetKnownEnemyCount() > 3 then -- don't charge at clustered enemies 
local flOurDistToEnemySqr = ( self:GetPos() - ene:GetPos() ):LengthSqr()
local nNumInterferingEnemies = 0
if istable(self:GetKnownEnemies()) then
for i=1, self:GetKnownEnemyCount() do
if IsValid(self:GetKnownEnemies()[i]) && self:GetKnownEnemies()[i] != ene && self:GetKnownEnemies()[i]:Health() > 1 
 && ((self:GetKnownEnemies()[i]:IsNPC() && self:GetKnownEnemies()[i]:Classify() != CLASS_BULLSEYE) or (!self:GetKnownEnemies()[i]:IsNPC())) then
 local flEnemyToEnemySqr = ( self:GetKnownEnemies()[i]:GetPos() - ene:GetPos() ):LengthSqr()
 if ( flEnemyToEnemySqr < flOurDistToEnemySqr ) then 
 nNumInterferingEnemies = nNumInterferingEnemies + 1 
end end end end
if nNumInterferingEnemies >= 3 then return false end
if isstring(self:GetSquad()) && ai.GetSquadMemberCount(self:GetSquad()) > 0 then -- don't charge if there squadmates around enemy
local flOurDistToEnemySqr = ( self:GetPos() - ene:GetPos() ):LengthSqr()
for i=1, ai.GetSquadMemberCount(self:GetSquad()) do
local ally = ai.GetSquadMembers(self:GetSquad())[i]
if ((self == ally) or (ally:Health() < 1)) then
continue end 
if ally:GetEnemy() == ene && isnumber(ally.ChargeState) && ally != self && ally.ChargeState > 0 then return false end
if ( ally:GetPos() - ene:GetPos() ):LengthSqr() < flOurDistToEnemySqr then  return false end
end end end
if self:HasCondition(COND.ENEMY_UNREACHABLE) then return false end -- there should be movetrace stuff, but there's no movetrace in gmod, so...
if useTime then
self.m_flChargeTime = CurTime() + 5
end
return true end

ENT.m_flChargeTime = CurTime()
ENT.NextA = 0

function ENT:ChargeLookAhead()
local tr = util.TraceHull({
				start = self:WorldSpaceCenter(),
				endpos =  self:WorldSpaceCenter() + self:GetAngles():Forward()*280,
				filter = self,
				mins = self:OBBMins(),
				maxs = self:OBBMaxs(),
			})

			if IsValid(tr.Entity) && (self:WorldSpaceCenter()):Distance(tr.HitPos) < 50 && self:HandleChargeImpact(tr.Entity) then self:ChargeCrash(tr) end
			if tr.HitWorld && (self:WorldSpaceCenter()):Distance(tr.HitPos) < 50 then self:ChargeCrash(tr) end
end

function ENT:ImpactShock(origin, radius, magnitude)
local falloff = 1/2.5
for _, v in ipairs( ents.FindInSphere(origin, radius)) do
if v:GetMoveType() == MOVETYPE_VPHYSICS && !v:IsPlayer() && IsValid(v:GetPhysicsObject()) then
local flDist = ( origin - v:GetPos() ):Length()
local adjustedDamage = magnitude - (flDist * falloff)
if adjustedDamage < 1 then adjustedDamage = 1 end
local vel = (v:GetPos()-self:GetPos()):GetNormalized()*350
	vel.z = 120
	v:GetPhysicsObject():SetVelocity(vel)
local dmginfo = DamageInfo()
    dmginfo:SetInflictor(self)
    dmginfo:SetAttacker(self)
    dmginfo:SetDamage(adjustedDamage)
    dmginfo:SetDamageType(DMG_CLUB)
	dmginfo:SetDamagePosition(v:GetPos())
	v:TakeDamageInfo(dmginfo)
	
end end
	
end


function ENT:ChargeSteer()
local ene = self:GetEnemy()
if !IsValid(ene) then return self:GetIdealYaw() end
local yaw = ((ene:WorldSpaceCenter()) - (self:WorldSpaceCenter())):Angle().y
return  self:GetIdealYaw()*0.35 + yaw*0.65 end

function ENT:ChargeCrash(tr)
self.NextMeleeT = CurTime() + 1
self.NextLeapT = CurTime() + 2
self.ChargeState = 0
self:EmitSound("npc_zombie_alien_grunt.Charge_Crash")
util.ScreenShake(tr.HitPos, 40, 1000, 1, 1200)
self.m_flChargeTime = CurTime() + math.random(8,10)
self.ChargeState = 0
self:TaskComplete()
timer.Simple(0.1,function() if IsValid(self) then self:PlayAct(self:GetSequenceActivity(self:LookupSequence("mgrunt_charge_crash")),nil,1) end end)
			 
end  -- StopCharge


function ENT:HandleChargeImpact(ent)
if ent == self then return false end
if IsValid(ent:GetParent()) then return false end
if !isstring(ent:GetModel()) then return false end
if IsValid(ent) then
if self:Disposition(ent) <= D_FR then
self:EmitSound("NPC_AntlionGuard.Shove")  
self:AddGesture( self:GetSequenceActivity(self:LookupSequence("mgrunt_charge_hit")))
self:EmitSound("npc_zombie_alien_grunt.Charge_Smack")
self:TaskFail("") self:TaskComplete()
self:StopCharge() return false end 
if ((ent:GetMoveType() == MOVETYPE_NONE)) && ent:GetClass() != "base_gmodentity" then print( ent:GetClass())  return true end
if (ent:GetMoveType() == MOVETYPE_VPHYSICS) then
local phys = ent:GetPhysicsObject()
if ((phys:GetMass() > 100) or (!phys:IsMotionEnabled())) then  return true end
end
end
return false end

ENT.m_flChargeTime = 0

function ENT:CanDoAttack() if GetConVar("sv_enable_zombie_grunt_charge"):GetBool() == false then return false end
if self.ChargeState != 0 then return false end
if CurTime() < self.m_flChargeTime then return false end
if !self:ShouldCharge() then return false end
if math.random(1,2) == 1 then self.m_flChargeTime = CurTime() + 2 return false end
return true end

function ENT:CanDoLeap(ene)  if GetConVar("sv_enable_zombie_grunt_leap"):GetBool() == false then return false end
if IsValid(ene:GetNW2Entity("ZagruntKnockout") ) then return false end
if self.ChargeState != 0 then return false end
local vecMins = self:OBBMins() 
local vecMaxs = self:OBBMaxs()
vecMins.z = vecMins.x
vecMaxs.z = vecMaxs.x
local tr = util.TraceHull( {
		start = self:WorldSpaceCenter(),
		endpos = ene:WorldSpaceCenter(),
		maxs = vecMaxs,
		mins = vecMins,
		filter = {self,ene}
	} )
	
return !tr.Hit end

function ENT:OnPunchProp(ent)
if ent:GetClass():find("door") then
ent:Remove()
util.ScreenShake(self:GetPos(),15,150,0.5,400)
local prop = ents.Create("prop_physics")
prop:SetModel(ent:GetModel())
prop:SetPos(ent:GetPos())
prop:SetAngles(ent:GetAngles())
prop:Spawn()
if ent:GetNumBodyGroups() != nil && isnumber(ent:GetNumBodyGroups()) then
for i=1, ent:GetNumBodyGroups() do
prop:SetBodygroup( i, ent:GetBodygroup( i ) )
end end
prop:SetSkin(ent:GetSkin())
prop:EmitSound("d1_trainstation_03.breakin_doorkick")
prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
local phys = prop:GetPhysicsObject()
if IsValid(phys) then phys:SetVelocity(self:GetForward()*400) end

else

local ph = ent:GetPhysicsObject()
local vel = self:GetForward()*350 + self:GetUp()*250
local ene = self:GetEnemy()
if IsValid(ene) && self:Visible(ene) && ene:GetPos():Distance(self:GetPos()) < 800 then
vel = (ene:EyePos() - ent:GetPos()):GetNormalized()*750
vel.z = 200
end

ph:SetVelocity(vel)
end
						
end

function ENT:DoMelee(pos, event, door) 
door = self.BeatProp
self.IsAttacking = false
pos = pos or (IsValid(self:GetEnemy()) && self:GetEnemy():WorldSpaceCenter() ) or self:WorldSpaceCenter() + self:GetForward()*160
local vecMins = self:OBBMins() 
local vecMaxs = self:OBBMaxs()
vecMins.z = vecMins.x
vecMaxs.z = vecMaxs.x
local tr = util.TraceHull( {
		start = self:WorldSpaceCenter(),
		endpos = self:WorldSpaceCenter() + (pos - self:WorldSpaceCenter()):GetNormalized()*90,
		maxs = vecMaxs,
		mins = vecMins,
		filter = function(ento)
		if ento == door then return true end
		if ento == self then return false end
		if self:Disposition(ento) != D_HT then return false end
		if ento:Alive() then return true end
		return false end, 
		mask = MASK_SHOT_HULL
	} )

local ent = door or tr.Entity
if IsValid(ent)  && !ent:Alive() then self:OnPunchProp(ent) end

if IsValid(ent) && ((ent:Alive() && self:Disposition(ent) == D_HT) or (!ent:Alive()))  then
local vp = Angle(15,25,7)
local scrf = false
self:EmitSound("npc_zombie_alien_grunt.Melee_Hit")
local dmg = DamageInfo()
	dmg:SetAttacker( self )
	dmg:SetInflictor( self )
	dmg:SetDamageType( DMG_CLUB )
if event == 565 then
	dmg:SetDamage( 15 )
	ent:SetVelocity(self:GetForward()*110 + self:GetUp()*20)

elseif event == 564 then
	dmg:SetDamage( 20 )
	ent:SetVelocity(self:GetForward()*110 + self:GetUp()*30)
	vp = Angle(15,-25,7)
	
elseif event == 1 then
	dmg:SetDamage( 20 )
	
elseif event == 567 then
vp = Angle(math.random(10,15),math.random(-12,12),math.random(7,9))
if ent:IsPlayer() && !IsValid(ent:GetNW2Entity("ZagruntKnockout") ) && GetConVar("sv_enable_zombie_grunt_ko"):GetBool() == true then
dmg:SetDamage( 15 )
local ko = ents.Create("zagrunt_knockout")
ko:SetOwner(ent)
ko:Spawn()
ent:SetNW2Entity("ZagruntKnockout",ko)
else
dmg:SetDamage( 45 )
scrf = true
end
ent:SetVelocity(self:GetForward()*350 + self:GetUp()*250)

elseif event == 562 then
	dmg:SetDamage( 10 )
scrf = true
vp = Angle(math.random(8,12)*1.5,math.random(-8,8)*1.5,math.random(7,8)*1.5)

elseif event == 563 then
vp = Angle(math.random(10,15)*2,math.random(-12,12)*1.8,math.random(7,9)*1.5)
	dmg:SetDamage( 20 )
	ent:SetVelocity(self:GetForward()*400 + self:GetUp()*280)
scrf = true
elseif event == 566 then
	dmg:SetDamage( 8 )
	end
	if !ent:GetClass():find("door") then
ent:TakeDamageInfo(dmg)
end
if ent:IsPlayer() then
ent:ViewPunch(vp)
if scrf then ent:ScreenFade(SCREENFADE.IN,Color(128,0,0,128),1,0.1)  end
end

if ent:IsPlayerHolding() then -- don't use props as a shield, coward
			ent:ForcePlayerDrop()
			end
else

self:EmitSound("npc_zombie_alien_grunt.Melee_Miss")

end

self.BeatProp = false
end

--


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

function ENT:PlayAct( act, isattacking, dur )
self.IsAttacking = false
self.IsCurrentlyBusy = true
timer.Remove("Zomgrunt_Anim_Timer"..self:EntIndex())
timer.Remove("Zomgrunt_Anim_Timer2"..self:EntIndex())
self:StopMoving()
self:TaskComplete()
self:ResetSequenceInfo()
self:SetSchedule(SCHED_NPC_FREEZE)
self:SetActivity(ACT_IDLE)
self:SetIdealActivity(act)
self:ResetIdealActivity(act)
dur = dur or self:SequenceDuration(self:GetSequence())
if isattacking then self.IsAttacking = true end
timer.Create("Zomgrunt_Anim_Timer2"..self:EntIndex(), 0.01, 1000, function()
if IsValid(self) then
self:MoveStop()
if self.IsAttacking && IsValid(isattacking) then 
self:SetIdealYawAndUpdate((isattacking:WorldSpaceCenter() - self:WorldSpaceCenter()):Angle().y,15)
end

end end)


timer.Create("Zomgrunt_Anim_Timer"..self:EntIndex(), 0.1, dur*10, function()
if isattacking then self.IsAttacking = true end
if IsValid(self) then
if timer.RepsLeft( "Zomgrunt_Anim_Timer"..self:EntIndex() ) == 3 then
self.IsCurrentlyBusy = false
self.IsAttacking = false
self:ClearSchedule() 
timer.Remove("Zomgrunt_Anim_Timer2"..self:EntIndex())
end
end end)

end

function ENT:OnTakeDamage( dmg )
if !self:CurrentlyBusy() && IsValid(dmg:GetAttacker()) && !IsValid(self:GetEnemy()) then 
self:UpdateEnemyMemory( dmg:GetAttacker(), dmg:GetAttacker():GetPos() )
end
local hitgr = self:GetInternalVariable("m_LastHitGroup")

if hitgr then dmg:ScaleDamage(1.2) end

if IsValid(dmg:GetAttacker()) && dmg:GetAttacker().IsSnark && dmg:GetAttacker() != self then return end
self:SetHealth(self:Health() - dmg:GetDamage())

if self:Health() <= 0 then
self:Die( dmg, hitgr )

elseif dmg:GetDamage() > 1 then

if CurTime() > self.NextPainSound then

if dmg:GetDamage() > 35 && !self:CurrentlyBusy() then
self:StopMoving()
self:PlayAct(ACT_BIG_FLINCH,nil,1.5)
self.ChargeState = 0
else
self:EmitSound("npc_zombie_alien_grunt.Pain")
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
