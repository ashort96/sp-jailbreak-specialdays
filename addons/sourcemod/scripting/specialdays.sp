// sp-jailbreak-specialdays
// Copyright (C) 2021  Adam Short

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#pragma semicolon 1

#define PLUGIN_NAME         "CS:S Jailbreak Special Days"
#define PLUGIN_AUTHOR       "organharvester, Jordi, Dunder"
#define PLUGIN_DESCRIPTION  "Jailbreak Special Days"
#define PLUGIN_VERSION      "4.1"
#define PLUGIN_URL          "https://github.com/ashort96/sp-jailbreak-specialdays"

#include <cstrike>
#include <jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <SetCollisionGroup>
#include <sourcemod>
#include <specialdays>

#pragma newdecls required

#include "specialdays/death_match.sp"
#include "specialdays/dodgeball.sp"
#include "specialdays/friendly_fire.sp"
#include "specialdays/grenade.sp"
#include "specialdays/gun_game.sp"
#include "specialdays/headshot.sp"
#include "specialdays/juggernaut.sp"
#include "specialdays/knife.sp"
#include "specialdays/tank.sp"
#include "specialdays/scoutknives.sp"
#include "specialdays/zombie.sp"

typedef FunctionPointer = function void ();
FunctionPointer SpecialDay_Begin;
FunctionPointer SpecialDay_End;

int g_RoundsUntilWardenSpecialDay = 51;
int g_Countdown;

Menu g_GunMenu;

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
}

public void OnPluginStart()
{

    // Verify that we are on CS:S
    EngineVersion game = GetEngineVersion();
    if (game != Engine_CSS)
    {
        SetFailState("This plugin is for CS:S only!");
    }

    // Regular Commands
    RegConsoleCmd("jointeam", Command_JoinTeam);
    RegConsoleCmd("sm_wsd", Command_WardenSpecialDay);

    // Admin Commands
    RegAdminCmd("sm_sd", Command_SpecialDay, ADMFLAG_BAN);

    // Hooks
    HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);
    HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
    HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Pre);
    HookEvent("round_start", OnRoundStart);
    HookEvent("round_end", OnRoundEnd);

    g_FriendlyFire = FindConVar("mp_friendlyfire");
    g_WeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
}

public void OnMapStart()
{
    g_GunMenu = BuildGunMenu(MenuHandler_Weapon);
    Zombie_OnMapStart();
}

public void OnMapEnd()
{
    delete g_GunMenu;
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
}
///////////////////////////////////////////////////////////////////////////////
// Admin Commands
///////////////////////////////////////////////////////////////////////////////
public Action Command_JoinTeam(int client, int args)
{
    if (g_SpecialDayState == inactive)
        return;
    
    switch(g_SpecialDay)
    {
        case tank: { Tank_JoinTeam(client, args); }
        default: {}
    } 

}

public Action Command_SpecialDay(int client, int args)
{
    Callback_SpecialDay(client);
    return Plugin_Handled;
}

///////////////////////////////////////////////////////////////////////////////
// Regular Commands
///////////////////////////////////////////////////////////////////////////////
public Action Command_WardenSpecialDay(int client, int args)
{
    if (client != GetWardenID())
    {
        PrintToChat(client, "%s Only the Warden can use a Warden Special Day!", SD_PREFIX);
        return Plugin_Handled;
    }

    int numberOfPeople;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
            numberOfPeople++;
    }

    if (numberOfPeople < 4)
    {
        PrintToChat(client, "%s At least 4 people are required to call a Warden Special Day!", SD_PREFIX);
        return Plugin_Handled;
    }

    if (g_RoundsUntilWardenSpecialDay > 0)
    {
        PrintToChat(client, "%s You must wait %d more rounds until calling a Warden Special Day!", SD_PREFIX, g_RoundsUntilWardenSpecialDay);
        return Plugin_Handled;
    }

    g_RoundsUntilWardenSpecialDay = 51;

    Callback_SpecialDay(client);
    return Plugin_Handled;
}

///////////////////////////////////////////////////////////////////////////////
// Hooks
///////////////////////////////////////////////////////////////////////////////
public void OnEntityCreated(int entity, const char[] classname)
{
    if (g_SpecialDayState == inactive)
        return;

    switch(g_SpecialDay)
    {
        case dodgeball: { Dodgeball_OnEntityCreated(entity, classname); }
        case grenade: { Grenade_OnEntityCreated(entity, classname); }
        default: {}
    }
}

public Action OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
    if (g_SpecialDayState == inactive)
    {
        return;
    }

    switch (g_SpecialDay)
    {
        case headshot: { Headshot_OnPlayerHurt(event, name, dontBroadcast); }
        default: {}
    }

}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    if (g_SpecialDayState == inactive)
    {
        return;
    }

    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));

    // If friendly fire is enabled, we still want to give the person a frag
    if (GetConVarBool(g_FriendlyFire))
    {
        if (GetClientTeam(attacker) == GetClientTeam(victim))
        {
            int frags = GetEntProp(attacker, Prop_Data, "m_iFrags");
            SetEntProp(attacker, Prop_Data, "m_iFrags", frags + 2);
        }

    }

    switch (g_SpecialDay)
    {
        case deathMatch: { DeathMatch_OnPlayerDeath(event, name, dontBroadcast);  }
        case gunGame: { GunGame_OnPlayerDeath(event, name, dontBroadcast); }
        case juggernaut: { Juggernaught_OnPlayerDeath(event, name, dontBroadcast); }
        case scoutknives: { Scoutknives_OnPlayerDeath(event, name, dontBroadcast); }
        case zombie: { Zombie_OnPlayerDeath(event, name, dontBroadcast); }
        default: {}
    }

}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
    if (g_SpecialDayState == inactive)
    {
        return;
    }

    switch (g_SpecialDay)
    {
        case tank: { Tank_OnPlayerDisconnect(event, name, dontBroadcast); }
        case zombie: { Zombie_OnPlayerDisconnect(event, name, dontBroadcast); }
    }
}


public void OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{

    g_SpecialDay = normal;
    g_SpecialDayState = inactive;

    if (g_RoundsUntilWardenSpecialDay > 0)
        g_RoundsUntilWardenSpecialDay--;
    else 
        PrintToChatAll("%s A Warden Special Day is available!", SD_PREFIX);
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    // Handle any cleanup here
    if (g_SpecialDayState != inactive)
    {
        PrintToChatAll("%s Special day is over!", SD_PREFIX);
        EnableWarden();
        EnableWardenHud();
        Call_StartFunction(INVALID_HANDLE, SpecialDay_End);
        Call_Finish();
    }

    g_SpecialDay = normal;
    g_SpecialDayState = inactive;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{

    if (g_SpecialDayState == inactive)
        return Plugin_Continue;

    // In the Countdown before the Special day starts, damage is disabled.
    else if (g_SpecialDayState == started)
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    Action returnStatus = Plugin_Continue;

    // Since a lot of Special Days enable friendly fire, this is in the main
    // file. Make sure to enable the convar in the SpecialDay_Begin function.
    if (GetConVarBool(g_FriendlyFire))
    {
        if (IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == GetClientTeam(attacker) && inflictor == attacker)
        {
            damage /= 0.35;
            returnStatus = Plugin_Changed;
        }
    }

    // If the SpecialDay needs to hook into OnTakeDamage(), do so here following this format:
    // case SpecialDay: { returnStatus = SpecialDay_OnTakeDamage(victim, attacker, inflictor, damage, damgetype); }
    switch (g_SpecialDay)
    {
        case dodgeball: { returnStatus = Dodgeball_OnTakeDamage(victim, attacker, inflictor, damage, damagetype); }
        case zombie: { returnStatus = Zombie_OnTakeDamage(victim, attacker, inflictor, damage, damagetype); }
        default: {}
    }

    return returnStatus;
}

public Action OnWeaponEquip(int client, int weapon)
{
    if (g_SpecialDayState != active)
        return Plugin_Continue;

    Action returnStatus = Plugin_Continue;

    switch (g_SpecialDay)
    {
        case scoutknives: { returnStatus = Scoutknives_OnWeaponEquip(client, weapon); }
        case zombie: { returnStatus = Zombie_OnWeaponEquip(client, weapon); }
    }
    return returnStatus;
}

///////////////////////////////////////////////////////////////////////////////
// Callbacks
///////////////////////////////////////////////////////////////////////////////
void Callback_SpecialDay(int client)
{
    if (g_SpecialDayState != inactive)
    {
        PrintToChat(client, "%s A Special Day has already been called!", SD_PREFIX);
        return;
    }
    Menu specialDayMenu = new Menu(MenuHandler_SpecialDay);

    specialDayMenu.SetTitle("Special Days");
    for (int i = 0; i < SD_LIST_SIZE; i++)
    {
        specialDayMenu.AddItem(SD_LIST[i], SD_LIST[i]);
    }
    specialDayMenu.ExitButton = true;
    specialDayMenu.Display(client, MENU_TIME_FOREVER);

}

///////////////////////////////////////////////////////////////////////////////
// Menu Handlers
///////////////////////////////////////////////////////////////////////////////
public int MenuHandler_SpecialDay(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        PrintToChatAll("%s %s Special Day selected!", SD_PREFIX, SD_LIST[param2]);
        LogAction(param1, -1, "%N Started Special Day %s", param1, SD_LIST[param2]);

        RemoveWarden();
        DisableWarden();
        DisableWardenHud();

        g_SpecialDayState = started;
        g_SpecialDay = view_as<SpecialDay>(param2);

        // Open all the doors
        char openEntityList[][] = {
            "func_door",
            "func_movelinear",
            "func_door_rotating",
            "prop_door_rotating"
        };

        int entity;

        for (int i = 0; i < sizeof(openEntityList); i++)
        {
            while ((entity = FindEntityByClassname(entity, openEntityList[i])) != -1)
            {
                if (IsValidEntity(entity))
                {
                    AcceptEntityInput(entity, "Open");
                }
            }
        }

        while ((entity = FindEntityByClassname(entity, "func_breakable")) != -1)
        {
            if (IsValidEntity(entity))
            {
                AcceptEntityInput(entity, "Break");
            }
        }

        CreateTimer(1.0, Timer_SpecialDayHud, param2, TIMER_REPEAT);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsValidClient(i))
            {
                if (IsPlayerOnTeam(i) && !IsPlayerAlive(i))
                CS_RespawnPlayer(i);
            }
        }

        switch (g_SpecialDay)
        {
            case deathMatch:
            {
                SpecialDay_Begin = SpecialDay_DeathMatch_Begin;
                SpecialDay_End = SpecialDay_DeathMatch_End;
            }
            case dodgeball:
            {
                SpecialDay_Begin = SpecialDay_Dodgeball_Begin;
                SpecialDay_End = SpecialDay_Dodgeball_End;
            }
            case friendlyFire:
            {
                DisplayGunMenuToAll();
                SpecialDay_Begin = SpecialDay_FriendlyFire_Begin;
                SpecialDay_End = SpecialDay_FriendlyFire_End;
            }
            case grenade:
            {
                SpecialDay_Begin = SpecialDay_Grenade_Begin;
                SpecialDay_End = SpecialDay_Grenade_End;
            }
            case gunGame:
            {
                SpecialDay_Begin = SpecialDay_GunGame_Begin;
                SpecialDay_End = SpecialDay_GunGame_End;
            }
            case headshot:
            {
                SpecialDay_Begin = SpecialDay_Headshot_Begin;
                SpecialDay_End = SpecialDay_Headshot_End;
            }
            case juggernaut:
            {
                DisplayGunMenuToAll();
                SpecialDay_Begin = SpecialDay_Juggernaut_Begin;
                SpecialDay_End = SpecialDay_Juggernaut_End;
            }
            case knife:
            {
                SpecialDay_Begin = SpecialDay_Knife_Begin;
                SpecialDay_End = SpecialDay_Knife_End;
            }
            case tank:
            {
                DisplayGunMenuToAll();
                SpecialDay_Begin = SpecialDay_Tank_Begin;
                SpecialDay_End = SpecialDay_Tank_End; 
            }
            case scoutknives:
            {
                SpecialDay_Begin = SpecialDay_Scoutknives_Begin;
                SpecialDay_End = SpecialDay_Scoutknives_End;
            }
            case zombie:
            {
                DisplayGunMenuToAll();
                SpecialDay_Begin = SpecialDay_Zombie_Begin;
                SpecialDay_End = SpecialDay_Zombie_End;
            }
        }
        g_Countdown = SD_DELAY;
        CreateTimer(1.0, Timer_SpecialDay, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
    }
    else if (action == MenuAction_Cancel)
    {
        PrintToServer("Client %d's menu was cancelled. Reason: %d", param1, param2);
    }
    else if (action == MenuAction_End)
    {
        delete menu;
    }
}

public int MenuHandler_Weapon(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select && IsPlayerAlive(param1))
    {
        if (g_SpecialDayState == inactive)
            return -1;
        
        char primary[32];
        int weapon;
        menu.GetItem(param2, primary, sizeof(primary));

        StripAllWeapons(param1);
        
        GivePlayerItem(param1, "weapon_knife");
        GivePlayerItem(param1, "weapon_deagle");

        weapon = GetPlayerWeaponSlot(param1, CS_SLOT_SECONDARY);
        SetReserveAmmo(param1, weapon, 999);

        GivePlayerItem(param1, "weapon_flashbang");
        GivePlayerItem(param1, "weapon_hegrenade");
        GivePlayerItem(param1, "weapon_smokegrenade");

        GivePlayerItem(param1, "item_assaultsuit");

        GivePlayerItem(param1, primary);
        weapon = GetPlayerWeaponSlot(param1, CS_SLOT_PRIMARY);
        SetReserveAmmo(param1, weapon, 999);
    }

    else if (action == MenuAction_Cancel)
    {
        PrintToServer("Client %d's menu was cancelled. Reason: %d", param1, param2);
    }

    return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Timers
///////////////////////////////////////////////////////////////////////////////
public Action Timer_SpecialDay(Handle timer)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Stop;
    if (g_Countdown > 0)
    {
        PrintCenterTextAll("Special Day begins in %i...", g_Countdown);
        g_Countdown--;
        return Plugin_Continue;
    }
    else
    {
        PrintToChatAll("%s Special day started!", SD_PREFIX);
        PrintCenterTextAll("Special day started!");
        g_SpecialDayState = active;
        Call_StartFunction(INVALID_HANDLE, SpecialDay_Begin);
        Call_Finish();
        return Plugin_Stop;
    }
}

public Action Timer_SpecialDayHud(Handle timer, int choice)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Stop;
    
    char buf[256];

    Format(buf, sizeof(buf), "SD: %s", SD_LIST[choice]);

    Handle hudText = CreateHudSynchronizer();
    SetHudTextParams(-1.5, -1.7, 1.0, 255, 255, 255, 255);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            ShowSyncHudText(i, hudText, buf);
        }
    }

    return Plugin_Continue;

}

///////////////////////////////////////////////////////////////////////////////
// Helper Functions
///////////////////////////////////////////////////////////////////////////////
Menu BuildGunMenu(MenuHandler gunMenuHandler)
{
    const int numGuns = 14;
    static const char gunDisplay[numGuns][] =
    {
        "AK47", "M4A1", "AWP", "M3", "P90", "M249",
        "SCOUT", "MP5", "GALIL", "SG", "TMP", "AUG",
        "FAMAS", "XM1014"
    };
    static const char gunName[numGuns][] =
    {
        "weapon_ak47", "weapon_m4a1", "weapon_awp", "weapon_m3",
        "weapon_p90", "weapon_m249", "weapon_scout", "weapon_mp5navy",
        "weapon_galil", "weapon_sg552", "weapon_tmp", "weapon_aug",
        "weapon_famas", "weapon_xm1014"
    };

    Menu gunMenu = new Menu(gunMenuHandler);
    for (int i = 0; i < numGuns; i++)
    {
        gunMenu.AddItem(gunName[i], gunDisplay[i]);
    }
    gunMenu.SetTitle("Weapon Selection");
    return gunMenu;
}

void DisplayGunMenu(int client)
{
    g_GunMenu.Display(client, 20);
}

void DisplayGunMenuToAll()
{
    PrintToChatAll("%s Please select a primary for the special day", SD_PREFIX);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerOnTeam(i) && IsPlayerAlive(i))
        {
            DisplayGunMenu(i);
        }
    }
}