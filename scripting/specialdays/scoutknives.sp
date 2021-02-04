int g_ScoutKnivesKills[MAXPLAYERS];

public void SpecialDay_Scoutknives_Begin()
{
    for (int i = 1; i < MAXPLAYERS; i++)
    {
        g_ScoutKnivesKills[i] = 0;
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;
        
        StripAllWeapons(i);
        GivePlayerItem(i, "weapon_scout");
        GivePlayerItem(i, "weapon_knife");
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        SetEntityGravity(i, 0.1);
    }

    SetConVarBool(g_FriendlyFire, false);

    CreateTimer(90.0, Timer_ScoutknivesEnd);
}

public void SpecialDay_Scoutknives_End()
{
    SetConVarBool(g_FriendlyFire, false);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i))
        {
            SetEntityGravity(i, 1.0);
        }
    }

}

public void Scoutknives_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(3.0, Timer_ScoutknivesRevive, victim);
    g_ScoutKnivesKills[attacker]++;
}

public Action Timer_ScoutknivesRevive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        StripAllWeapons(client);
        GivePlayerItem(client, "weapon_scout");
        GivePlayerItem(client, "weapon_knife");
        SetEntProp(client, Prop_Data, "m_ArmorValue", 0.0);
        SetEntityGravity(client, 0.1);
    }
    return Plugin_Handled;
}

public Action Timer_ScoutknivesEnd(Handle timer)
{
    
    if (g_SpecialDayState == inactive || g_SpecialDay != scoutknives)
        return Plugin_Handled;

    int clientIndex = GetMaximumIndexFromArray(g_ScoutKnivesKills, sizeof(g_ScoutKnivesKills));

    if (IsValidClient(clientIndex))
    {
        PrintToChatAll("%s %N won Scoutknives!", SD_PREFIX, clientIndex);
    }
    else 
    {
        PrintToChatAll("%s The winner left the game!", SD_PREFIX);
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i))
        {
            if (i != clientIndex)
                ForcePlayerSuicide(i);
        }
    }
    return Plugin_Handled;

}