AddCSLuaFile()
ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Author = "Limakenori"
ENT.PrintName = "KNOCKOUT"
ENT.Spawnable = true
ENT.Category = "Black Mesa"

hook.Add( "SetupMove", "ZagruntKnockout", function( ply, mv, cmd )
if IsValid(ply:GetNW2Entity("ZagruntKnockout")) then
		mv:SetUpSpeed( -100		)
		mv:SetMaxClientSpeed(5)
	end
end )

if (CLIENT) then

local tab = {
	[ "$pp_colour_addr" ] = 0.02,
	[ "$pp_colour_addg" ] = 0.0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = -0.2,
	[ "$pp_colour_contrast" ] = 1.1,
	[ "$pp_colour_colour" ] = 0.4,
	[ "$pp_colour_mulr" ] = 0,
	[ "$pp_colour_mulg" ] = 0,
	[ "$pp_colour_mulb" ] = 0
}

hook.Add( "RenderScreenspaceEffects", "ZagruntKnockout", function()
local ply = LocalPlayer()
if IsValid(ply:GetNW2Entity("ZagruntKnockout")) then
DrawMotionBlur( 0.4, 0.8, 0.01 )
RunConsoleCommand( "+duck" )
if !ply.ZagruntKnockout then
ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.3, 0 )
ply.ZagruntKnockout = true
end

ply:SetDSP( 15,false )
util.ScreenShake( ply:EyePos(), 1, 0.5, 0.1, 100, true, ply )
	DrawColorModify( tab )

else
ply:SetDSP( 0,true )
if ply.ZagruntKnockout then
ply:ScreenFade( SCREENFADE.IN, Color( 255, 255, 255, 255 ), 0.3, 0 )
ply.ZagruntKnockout = false
RunConsoleCommand( "-duck" )
end
end

end )


	function ENT:Draw() 
	self:DrawModel()
	end
end


function ENT:OnRemove()
end


function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)
    self:DrawShadow(false)
	self.TimeUntilRemove = CurTime() + 4
--Entity(1):SetNW2Entity("ZagruntKnockout",self)
    if SERVER then 
		 self:SetSolid(SOLID_NONE)
		 self:SetMoveType(MOVETYPE_NONE)
		 self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    end
end

function ENT:Think()
if SERVER && IsValid(self:GetOwner()) then
if !self.LastOwnerHealth then self.LastOwnerHealth = self:GetOwner():Health() end
if self:GetOwner():Health() < self.LastOwnerHealth - 6 then
self.TimeUntilRemove = math.Clamp(self.TimeUntilRemove + 1,0, CurTime() + 6)
self.LastOwnerHealth = self:GetOwner():Health()
end 
if !self:GetOwner():Alive() then self:Remove() return end
if CurTime() > self.TimeUntilRemove then
self:Remove()
end
end

		self:NextThink(CurTime())
return true end
