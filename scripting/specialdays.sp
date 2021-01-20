#pragma semicolon 1

#define PLUGIN_NAME         "CS:S Jailbreak Special Days"
#define PLUGIN_AUTHOR       "organharvester, Jordi, Dunder"
#define PLUGIN_DESCRIPTION  "Jailbreak Special Days"
#define PLUGIN_VERSION      "4.0"
#define PLUGIN_URL          ""

#include <cstrike>
#include <jailbreak>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <specialdays>

#pragma newdecls required

#include "specialdays/death_match.sp"
#include "specialdays/dodgeball.sp"
#include "specialdays/friendly_fire.sp"

typedef FunctionPointer = function void ();
FunctionPointer SpecialDay_Begin;
FunctionPointer SpecialDay_End;

SpecialDay g_SpecialDay;
SpecialDayState g_SpecialDayState;
int g_RoundsUntilWardenSpecialDay = 50;
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
    // Verify that the jailbreak plugin is running
    bool pluginJailbreakExists = LibraryExists("jailbreak");
    if (!pluginJailbreakExists)
    {
        SetFailState("This plugin requires jailbreak.smx to be running");
    }

    // Verify that we are on CS:S
    EngineVersion game = GetEngineVersion();
    if (game != Engine_CSS)
    {
        SetFailState("This plugin is for CS:S only!");
    }

    // Regular Commands
    RegConsoleCmd("sm_wsd", Command_WardenSpecialDay);

    // Admin Commands
    RegAdminCmd("sm_sd", Command_SpecialDay, ADMFLAG_BAN);

    // Hooks
    HookEvent("round_start", OnRoundStart);
    HookEvent("round_end", OnRoundEnd);

    g_FriendlyFire = FindConVar("mp_friendlyfire");
}

public void OnMapStart()
{
    g_GunMenu = BuildGunMenu(MenuHandler_Weapon);
    g_FriendlyFireEnabled = false;
    g_DamageDisabled = false;
}

public void OnMapEnd()
{
    delete g_GunMenu;
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
///////////////////////////////////////////////////////////////////////////////
// Admin Commands
///////////////////////////////////////////////////////////////////////////////
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

    if (g_RoundsUntilWardenSpecialDay > 0)
    {
        PrintToChat(client, "%s You must wait %d more rounds until calling a Warden Special Day!", SD_PREFIX, g_RoundsUntilWardenSpecialDay);
        return Plugin_Handled;
    }

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

    // If the SpecialDay needs to hook into OnEntityCreated(), do so here following this format:
    // case SpecialDay: { SpecialDay_OnEntityCreated(entity, classname); }

    switch(g_SpecialDay)
    {
        case dodgeball: { Dodgeball_OnEntityCreated(entity, classname); }
        default: {}
    }
}


public void OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    if (g_RoundsUntilWardenSpecialDay > 0)
        g_RoundsUntilWardenSpecialDay--;
    else 
        PrintToChatAll("%s A Warden Special Day is available!", SD_PREFIX);
}

public void OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
    // Handle any cleanup here
    PrintToChatAll("%s Special day is over!", SD_PREFIX);
    Call_StartFunction(INVALID_HANDLE, SpecialDay_End);
    Call_Finish();
    g_SpecialDay = normal;
    g_SpecialDayState = inactive;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{

    if (g_SpecialDayState == inactive)
        return Plugin_Continue;

    // In the Countdown before the Special day starts, damage is disabled.
    if (g_DamageDisabled)
    {
        damage = 0.0;
        return Plugin_Changed;
    }

    Action returnStatus = Plugin_Continue;

    // Since a lot of Special Days enable friendly fire, this is in the main
    // file. Make sure to enable both the convar and set the global boolean
    // to true in the SpecialDay_Begin function.
    if (g_FriendlyFireEnabled)
    {
        if (IsValidClient(victim) && IsValidClient(attacker) && GetClientTeam(victim) == GetClientTeam(attacker) && inflictor == attacker)
        {
            damage /= 0.35;
            returnStatus = Plugin_Changed;
        }
    }

    // If the SpecialDay needs to hook into OnTakeDamage(), do so here following this format:
    // case SpecialDay: { returnStatus = SpecialDay_OnTakeDamage(victim, attacker, inflictor, damage, damgetype); }
    switch(g_SpecialDay)
    {
        case dodgeball: { returnStatus = Dodgeball_OnTakeDamage(victim, attacker, inflictor, damage, damagetype); }
        default: {}
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

        g_SpecialDayState = started;
        g_SpecialDay = view_as<SpecialDay>(param2);

        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsValidClient(i))
            {
                if ((GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T) && !IsPlayerAlive(i))
                CS_RespawnPlayer(i);
            }
        }

        switch (g_SpecialDay)
        {
            case friendlyFire:
            {
                DisplayGunMenuToAll();
                SpecialDay_Begin = SpecialDay_FriendlyFire_Begin;
                SpecialDay_End = SpecialDay_FriendlyFire_End;
            }
        }
        g_Countdown = SD_DELAY;
        g_DamageDisabled = true;
        CreateTimer(1.0, Timer_SpecialDay, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
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

        StripAllWeapons(param2);

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
    if (g_Countdown > 0)
    {
        PrintCenterTextAll("Special Day begins in %i...", g_Countdown);
        g_Countdown--;
    }
    else
    {
        delete timer;
        g_DamageDisabled = false;
        g_SpecialDayState = active;
        Call_StartFunction(INVALID_HANDLE, SpecialDay_Begin);
        Call_Finish();
    }
}

///////////////////////////////////////////////////////////////////////////////
// Helper Functions
///////////////////////////////////////////////////////////////////////////////
Menu BuildGunMenu(MenuHandler gunMenuHandler)
{
    const int numGuns = 14;
    static const char gunDisplay [numGuns][] =
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
        gunMenu.AddItem(gunDisplay[i], gunName[i]);
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
        if (IsValidClient(i) && GetClientTeam(i) == CS_TEAM_CT || GetClientTeam(i) == CS_TEAM_T)
        {
            DisplayGunMenu(i);
        }
    }
}