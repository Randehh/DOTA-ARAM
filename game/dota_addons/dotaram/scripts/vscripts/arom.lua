print ('[AROM] AROM.lua' )
local globals = require("globals")

require('lib.statcollection')
statcollection.addStats({
	modID = 'afbfdcaac5981e668fa63e33e127ac3f' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = true             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 0              -- How long should we let people select their hero?
PRE_GAME_TIME = 60.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 3                       -- How much gold should players get per tick?
GOLD_TICK_TIME = 2                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1134.0        -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 60                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = false      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false  -- Should we use a custom buyback time?
BUYBACK_ENABLED = true                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false      -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = false        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = false             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = true -- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = false           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {
	[1] = 100,
	[2] = 150,
	[3] = 200,
	[4] = 250,
	[5] = 300,
	[6] = 350,
	[7] = 400,
	[8] = 450,
	[9] = 500,
	[10] = 550,
	[11] = 600,
	[12] = 650,
	[13] = 700,
	[14] = 750,
	[15] = 800,
	[16] = 850,
	[17] = 900,
	[18] = 950,
	[19] = 100,
	[20] = 100,
	[21] = 100,
	[22] = 100,
	[23] = 100,
	[24] = 100,
	[25] = 100
}

-- Generated from template
if GameMode == nil then
    print ( '[AROM] creating AROM game mode' )
    GameMode = class({})
end


--[[
  This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
  in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
  If this occurs it causes the client to never precache things configured in that block.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).
]]
function GameMode:PostLoadPrecache()
  print("[AROM] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
  --PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  print("[AROM] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  print("[AROM] All Players have loaded into the game")

	for _,ply in pairs(globals.connectedPlayers) do
	    local playerID = ply:GetPlayerID()
	    if PlayerResource:IsValidPlayerID(playerID) and ply:GetAssignedHero() == nil then
	    	ply:MakeRandomHeroSelection()
	    	globals.selectedHeroes[playerID] = ply:GetAssignedHero()
	    	--PlayerResource:SetHasRepicked(playerID)
	    end
	end

	--Also spawn a popup with instructions
  	ShowGenericPopup( "#popup_title_tutorial", "#popup_body_tutorial", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  print("[AROM] Hero spawned in game for first time -- " .. hero:GetUnitName())

  hero:SetGold(1000, false)
  hero:AddExperience(900, false, false)
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  print("[AROM] The game has officially begun")
  globals.spawnRunes = true

  --[[Timers:CreateTimer(0.25, -- Start this timer 30 game-time seconds later
  function()
    print("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
    return 30.0 -- Rerun this timer every 30 game-time seconds 
  end)]]
end




-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  print('[AROM] Player Disconnected ' .. tostring(keys.userid))
  PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  print("[AROM] GameRules State Changed")
  PrintTable(keys)

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        if PlayerResource:HaveAllPlayersJoined() then
          GameMode:PostLoadPrecache()
          GameMode:OnAllPlayersLoaded()
          return 
        end
        return 1
      end
      })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameMode:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  --print("[AROM] NPC Spawned")
  --PrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() then
  	if npc.bFirstSpawned == nil  then
   	 	npc.bFirstSpawned = true
   		GameMode:OnHeroInGame(npc)
   		PlayerResource:GetPlayer(npc:GetPlayerID()).inventory = {}
   		PlayerResource:GetPlayer(npc:GetPlayerID()).inventorySize = 0
	end
    --print("Shop enabled for " .. npc:GetPlayerID())
    PlayerResource:GetPlayer(npc:GetPlayerID()).EnabledShop = true

    npc:SetMinimumGoldBounty(200)
    npc:SetMaximumGoldBounty(200)
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --print("[AROM] Entity Hurt")
  --PrintTable(keys)
  local entCause = EntIndexToHScript(keys.entindex_attacker)
  local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  PrintTable(keys)

  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname

  if string.find(itemname, "item_custom_rune") == false then
  	return
  end

  if(itemname == "item_custom_rune_doubledamage") then --Double damage
  	itemEntity:ApplyDataDrivenModifier(PlayerResource:GetSelectedHeroEntity(keys.PlayerID), PlayerResource:GetSelectedHeroEntity(keys.PlayerID), "modifier_doubledamage", {})
  end

  if(itemname == "item_custom_rune_haste") then --Haste
	itemEntity:ApplyDataDrivenModifier(PlayerResource:GetSelectedHeroEntity(keys.PlayerID), PlayerResource:GetSelectedHeroEntity(keys.PlayerID), "modifier_haste", {})
  end

  if(rune == 2) then --Illusions

  end

  if(itemname == "item_custom_rune_invis") then --Invisibility
	itemEntity:ApplyDataDrivenModifier(PlayerResource:GetSelectedHeroEntity(keys.PlayerID), PlayerResource:GetSelectedHeroEntity(keys.PlayerID), "modifier_invis", {})
	PlayerResource:GetSelectedHeroEntity(keys.PlayerID):AddNewModifier(PlayerResource:GetSelectedHeroEntity(keys.PlayerID), PlayerResource:GetSelectedHeroEntity(keys.PlayerID), "modifier_invisible", {duration = 15}) 
  end

  if(itemname == "item_custom_rune_regeneration") then --Regen
  	PlayerResource:GetSelectedHeroEntity(keys.PlayerID):SetHealth(PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetHealth() + (PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetMaxHealth() / 5))
  	PlayerResource:GetSelectedHeroEntity(keys.PlayerID):SetMana(PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetMana() + (PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetMaxMana() / 5))
  	PlayerResource:GetSelectedHeroEntity(keys.PlayerID):Purge(true, true, true, false, false)
  	print('Regen rune picked up!')
  end

  RemoveRuneFromList(itemEntity, PlayerResource:GetSelectedHeroEntity(keys.PlayerID))
end

function RemoveRuneFromList(itemEntity, playerEntity)
	if globals.activeRunes[4] == itemEntity then
		globals.activeRunes[4] = nil
		playerEntity:RemoveItem(itemEntity)
	end
	
	if globals.activeRunes[1] == itemEntity then
		globals.activeRunes[1] = nil
		playerEntity:RemoveItem(itemEntity)
	end
	
	if globals.activeRunes[2] == itemEntity then
		globals.activeRunes[2] = nil
		playerEntity:RemoveItem(itemEntity)
	end
	
	if globals.activeRunes[3] == itemEntity then
		globals.activeRunes[3] = nil
		playerEntity:RemoveItem(itemEntity)
	end
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  print ( '[AROM] OnPlayerReconnect' )
  PrintTable(keys) 
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
	print ( '[AROM] OnItemPurchased' )
	PrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  local cancelTransaction = false
  local itemName = keys.itemname 
  local itemcost = keys.itemcost
  
  local player = PlayerResource:GetPlayer(keys.PlayerID)

  if player.EnabledShop == false then
  	cancelTransaction = true
  	FireGameEvent("custom_error_show", { player_ID = plyID, _error = "You can't shop anymore." } ) 
  end

  --Cancel the event anyway if the player has no more inventory space
  if GetItemAmountInInventory(plyID) >= 7 and cancelTransaction ~= true then
  	cancelTransaction = true
  	FireGameEvent("custom_error_show", { player_ID = plyID, _error = "No more inventory space." } ) 
  end

  --Cancel transaction
  if cancelTransaction == true then
  	for i=12,0,-1 do 
  		if  PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetItemInSlot(i) ~= nil then
  			if PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetItemInSlot(i):GetName() == itemName then
  				local newGold = (PlayerResource:GetGold(plyID) + itemcost)
  				PlayerResource:GetSelectedHeroEntity(keys.PlayerID):RemoveItem(PlayerResource:GetSelectedHeroEntity(keys.PlayerID):GetItemInSlot(i))
  				PlayerResource:SetGold(plyID, newGold, false)
  				return
  			end
  		end
  	end
  end

  --Also check for item combines
  if player.inventorySize >= GetItemAmountInInventory(plyID) then
  	RevertInventory(plyID)
  	local newGold = (PlayerResource:GetGold(plyID) + itemcost)
  	PlayerResource:SetGold(plyID, newGold, false)
  	FireGameEvent("custom_error_show", { player_ID = plyID, _error = "You can't shop anymore." } ) 
  else
  	SaveInventory(plyID)
  end
end

function GetItemAmountInInventory(playerID)
	local amount = 0
	for i=0,6,1 do 
	    if  PlayerResource:GetSelectedHeroEntity(playerID):GetItemInSlot(i) ~= nil then
	    	amount = amount + 1
	    end
	end
	return amount
end

function SaveInventory(playerID)
	local inventory = {}
	for i=0,6,1 do 
	    if  PlayerResource:GetSelectedHeroEntity(playerID):GetItemInSlot(i) ~= nil then
	    	inventory[i] = PlayerResource:GetSelectedHeroEntity(playerID):GetItemInSlot(i):GetClassname()
	    end
	end
	PlayerResource:GetPlayer(playerID).inventory = inventory
	PlayerResource:GetPlayer(playerID).inventorySize = table.getn(inventory)
end

function RevertInventory(playerID)
	local inventory = PlayerResource:GetPlayer(playerID).inventory
	for i=0,6,1 do
		if  PlayerResource:GetSelectedHeroEntity(playerID):GetItemInSlot(i) ~= nil then
			PlayerResource:GetSelectedHeroEntity(playerID):RemoveItem(PlayerResource:GetSelectedHeroEntity(playerID):GetItemInSlot(i))
		end

	    if  inventory[i] ~= nil then
	    	PlayerResource:GetSelectedHeroEntity(playerID):AddItem(CreateItem(inventory[i], PlayerResource:GetSelectedHeroEntity(playerID), PlayerResource:GetSelectedHeroEntity(playerID)))
	    end
	end
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  print('[AROM] AbilityUsed')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  print('[AROM] OnNonPlayerUsedAbility')
  PrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  print('[AROM] OnPlayerChangedName')
  PrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  print ('[AROM] OnPlayerLearnedAbility')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  print ('[AROM] OnAbilityChannelFinished')
  PrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  print ('[AROM] OnPlayerLevelUp')
  PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  print ('[AROM] OnLastHit')
  PrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  print ('[AROM] OnTreeCut')
  PrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  print ('[AROM] OnRuneActivated')
  PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  print ('[AROM] OnPlayerTakeTowerDamage')
  PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  print ('[AROM] OnPlayerPickHero')
  PrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)

  globals.connectedPlayers[player:GetPlayerID()] = nil
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  print ('[AROM] OnTeamKillCredit')
  PrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  print( '[AROM] OnEntityKilled Called' )
  --PrintTable( keys )
  
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then 
    print ("KILLEDKILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS and killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
      self.nRadiantKills = self.nRadiantKills + 1
      if END_GAME_ON_KILLS and self.nRadiantKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
      end
    elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killerEntity:GetTeam() == DOTA_TEAM_BADGUYS then
      self.nDireKills = self.nDireKills + 1
      if END_GAME_ON_KILLS and self.nDireKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
      end
    end

    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireKills )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantKills )
    end
  end

  -- Put code here to handle when an entity gets killed
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self
  print('[AROM] Starting to load AROM gamemode...')

  -- Setup rules
  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetRuneSpawnTime(10000000000)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
  GameRules:GetGameModeEntity():SetThink( "OnThink", "GameRules", 0, self )
  print('[AROM] GameRules set')

  InitLogFile( "log/AROM.txt","")

  -- Event Hooks
  -- All of these events can potentially be fired by the game, though only the uncommented ones have had
  -- Functions supplied for them.  If you are interested in the other events, you can uncomment the
  -- ListenToGameEvent line and add a function to handle the event
  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(GameMode, 'OnPlayerLevelUp'), self)
  ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(GameMode, 'OnAbilityChannelFinished'), self)
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(GameMode, 'OnPlayerLearnedAbility'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(GameMode, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(GameMode, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(GameMode, 'OnDisconnect'), self)
  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(GameMode, 'OnItemPurchased'), self)
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GameMode, 'OnItemPickedUp'), self)
  ListenToGameEvent('last_hit', Dynamic_Wrap(GameMode, 'OnLastHit'), self)
  ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(GameMode, 'OnNonPlayerUsedAbility'), self)
  ListenToGameEvent('player_changename', Dynamic_Wrap(GameMode, 'OnPlayerChangedName'), self)
  ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(GameMode, 'OnRuneActivated'), self)
  ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(GameMode, 'OnPlayerTakeTowerDamage'), self)
  ListenToGameEvent('tree_cut', Dynamic_Wrap(GameMode, 'OnTreeCut'), self)
  ListenToGameEvent('entity_hurt', Dynamic_Wrap(GameMode, 'OnEntityHurt'), self)
  ListenToGameEvent('player_connect', Dynamic_Wrap(GameMode, 'PlayerConnect'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(GameMode, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GameMode, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(GameMode, 'OnNPCSpawned'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(GameMode, 'OnPlayerPickHero'), self)
  ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(GameMode, 'OnTeamKillCredit'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(GameMode, 'OnPlayerReconnect'), self)
  --ListenToGameEvent('player_spawn', Dynamic_Wrap(GameMode, 'OnPlayerSpawn'), self)
  --ListenToGameEvent('dota_unit_event', Dynamic_Wrap(GameMode, 'OnDotaUnitEvent'), self)
  --ListenToGameEvent('nommed_tree', Dynamic_Wrap(GameMode, 'OnPlayerAteTree'), self)
  --ListenToGameEvent('player_completed_game', Dynamic_Wrap(GameMode, 'OnPlayerCompletedGame'), self)
  --ListenToGameEvent('dota_match_done', Dynamic_Wrap(GameMode, 'OnDotaMatchDone'), self)
  --ListenToGameEvent('dota_combatlog', Dynamic_Wrap(GameMode, 'OnCombatLogEvent'), self)
  --ListenToGameEvent('dota_player_killed', Dynamic_Wrap(GameMode, 'OnPlayerKilled'), self)
  --ListenToGameEvent('player_team', Dynamic_Wrap(GameMode, 'OnPlayerTeam'), self)



  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", 0 )
  
  -- Fill server with fake clients
  -- Fake clients don't use the default bot AI for buying items or moving down lanes and are sometimes necessary for debugging
  Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')
        
      Timers:CreateTimer('assign_fakes', {
        useGameTime = false,
        endTime = Time(),
        callback = function(AROM, args)
          local userID = 20
          for i=0, 9 do
            userID = userID + 1
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
                self:OnConnectFull({
                  userid = userID,
                  index = ply:entindex()-1
                })

                ply:GetAssignedHero():SetControllableByPlayer(0, true)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

  --[[This block is only used for testing events handling in the event that Valve adds more in the future
  Convars:RegisterCommand('events_test', function()
      GameMode:StartEventTest()
    end, "events test", 0)]]

  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- Initialized tables for tracking state
  self.vUserIds = {}
  self.vSteamIds = {}
  self.vBots = {}
  self.vBroadcasters = {}

  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}

  self.nRadiantKills = 0
  self.nDireKills = 0

  self.bSeenWaitForPlayers = false

  print('[AROM] Done loading AROM gamemode!\n\n')
end

mode = nil

-- This function is called as the first player loads and sets up the GameMode parameters
function GameMode:CaptureGameMode()
  if mode == nil then
    -- Set GameMode parameters
    mode = GameRules:GetGameModeEntity()        
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

    --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )


    --GameRules:GetGameModeEntity():SetThink( "Think", self, "GlobalThink", 2 )

    self:OnFirstPlayerLoaded()
  end 
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  print('[AROM] PlayerConnect')
  PrintTable(keys)
  
  if keys.bot == 1 then
    -- This user is a Bot, so add it to the bots table
    self.vBots[keys.userid] = 1
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  print ('[AROM] OnConnectFull')
  PrintTable(keys)
  GameMode:CaptureGameMode()
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
  globals.connectedPlayers[playerID] = ply
  
  -- Update the user ID table with this user
  self.vUserIds[keys.userid] = ply

  -- Update the Steam ID table
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply
  
  -- If the player is a broadcaster flag it in the Broadcasters table
  if PlayerResource:IsBroadcaster(playerID) then
    self.vBroadcasters[keys.userid] = 1
    return
  end
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end

--Check for repick heroes
function GameMode:OnThink()
	print("THINK TIME")
  	for _,ply in pairs(globals.connectedPlayers) do
	    local playerID = ply:GetPlayerID()
	    if PlayerResource:IsValidPlayerID(playerID) and PlayerResource:HasRepicked(ply:GetPlayerID()) == true and ply:GetAssignedHero() == nil and globals.repickedPlayer[playerID] ~= true then
	    	ply:MakeRandomHeroSelection()
	    	globals.selectedHeroes[playerID] = ply:GetAssignedHero()
	    	globals.repickedPlayer[playerID] = true
	    end
	end

	if globals.spawnRunes == false then
		print("Spawn runes is false")
	else

		globals.currentRuneSpawnTime = globals.currentRuneSpawnTime + 0.2
		print(globals.currentRuneSpawnTime)

		if globals.currentRuneSpawnTime >= 30 then

			--Remove all old runes
			if globals.activeRunes[1] ~= nil then
				globals.activeRunes[1]:GetContainer():RemoveSelf()
			end

			if globals.activeRunes[2] ~= nil then
				globals.activeRunes[2]:GetContainer():RemoveSelf()
			end

			if globals.activeRunes[3] ~= nil then
				globals.activeRunes[3]:GetContainer():RemoveSelf()
			end

			if globals.activeRunes[4] ~= nil then
				globals.activeRunes[4]:GetContainer():RemoveSelf()
			end

			--Spawn new runes
			globals.activeRunes = {
				[1] = GetRandomRune(),
				[2] = GetRandomRune(),
				[3] = GetRandomRune(),
				[4] = GetRandomRune()
			}
			CreateItemOnPositionSync(Vector(3200,3584,160), globals.activeRunes[1]) -- Dire outer
			CreateItemOnPositionSync(Vector(2368,2688,160), globals.activeRunes[2]) -- Dire inner
			CreateItemOnPositionSync(Vector(-2464,-2144,160), globals.activeRunes[3]) -- Radiant outer
			CreateItemOnPositionSync(Vector(-1216,-896,160), globals.activeRunes[4]) -- Radiant inner
			print("Spawned rune ")

			globals.currentRuneSpawnTime = 0
		end
	end
  	return 0.2
end

function GetRandomRune()
	local number =  math.random(1, 100)
	if number <= 15 then
		return CreateItem("item_custom_rune_doubledamage", nil, nil)
	elseif number <= 40 then
		return CreateItem("item_custom_rune_haste", nil, nil)
	elseif number <= 60 then
		return CreateItem("item_custom_rune_invis", nil, nil)
	elseif number <= 100 then
		return CreateItem("item_custom_rune_regeneration", nil, nil)
	end
end

--Leave and enter shop
function PlayerEnterShop(keys)
end

function PlayerLeaveShop(keys)
	local playerID = keys.activator:GetPlayerOwnerID()

	if PlayerResource:GetPlayer(playerID).EnabledShop ~= false then
		FireGameEvent("custom_error_show", { player_ID = playerID, _error = "You have left the shop." } ) 
	end   

	PlayerResource:GetPlayer(playerID).EnabledShop = false
end

--require('eventtest')
--GameMode:StartEventTest()