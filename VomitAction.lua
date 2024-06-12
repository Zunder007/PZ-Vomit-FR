Vomit = ISBaseTimedAction:derive("Vomit");


function Vomit.isValidForPlayer(player)
    return true;
end

function Vomit:isValid()
    -- We only check when populating.
    return true;
end

function Vomit:recovery()
    local player = self.character
	local poison = player:getBodyDamage():getFoodSicknessLevel()

	local visual = player:getHumanVisual()
    local endurence =player:getStats():getEndurance()
	--player:getBodyDamage():getNutrition():getProteins()
	
	player:getBodyDamage():setFoodSicknessLevel(90)
	player:getBodyDamage():setPoisonLevel(0)
	for i=0,BloodBodyPartType.MAX:index()-1 do
		local part = BloodBodyPartType.FromIndex(i)
		local newValue = player:getHumanVisual():getBlood(part)
		--print(tostring(part))
		player:getHumanVisual():setDirt(part,1)
	end
    player:getStats():setEndurance(endurence*0.5)
    self.character:resetModel();
    
end

function Vomit:update()
    self.tick = self.tick + 1;
    print("hello")
    if (self.tick == self.quashTime) then
        print("bweaawweeeee!");
        print(tostring(self.tick))
        self:recovery()
    end
end

function Vomit:start()
    self.character:Say("Uggh!!")
    self:setActionAnim("Vomit");
end

function Vomit:stop()
    print("vomit done!")

    ISBaseTimedAction.stop(self);
end

function Vomit:perform()    
    ISBaseTimedAction.perform(self);
end

function Vomit:new(character, time, quashTime)
    local o = ISBaseTimedAction.new(self, character);
    o.stopOnAim = true;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.tick = 0;
    o.quashTime = quashTime;
    o.maxTime = time;
    o.ignoreHandsWounds = true;
    o.animSpeed = 1.0;
    if o.character:isTimedActionInstant() then o.maxTime = 1; end
    o.caloriesModifier = 10;
    return o;
end

function Vomit.doVomitAction(player)
    local hunger = player:getStats():getHunger()
	local thirst = player:getStats():getThirst()
    local pain = player:getStats():getPain()
    player:getStats():setHunger(hunger+0.6)
	player:getStats():setThirst(hunger+0.6)
    -- player:getStats():setPain(pain+60)

    local VomitAction = Vomit:new(player, 150, 150);
    ISTimedActionQueue.add(VomitAction);
end

function Vomit.onFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    if test then return end;

    local player = getSpecificPlayer(playerNum);

    if Vomit.isValidForPlayer(player) then
        context:addOption("Je vais vomir...", player, Vomit.doVomitAction, player:getSquare());
    end
end

Events.OnFillWorldObjectContextMenu.Add(Vomit.onFillWorldObjectContextMenu);
