int g_DeathMatchKills[MAXPLAYERS];

public void SpecialDay_DeathMatch_Begin()
{
    // Make sure everything is zero'd out
    for (int i = 0; i < MAXPLAYERS; i++)
    {
        g_DeathMatchKills[i] = 0;
    }

    CreateTimer(90.0, Timer_DeathMatchEnd);

}

public void SpecialDay_DeathMatch_End()
{

}

public void DeathMatch_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    int victim = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(3.0, Timer_DeathMatchRevive, victim);
    g_DeathMatchKills[attacker]++;
}

public Action Timer_DeathMatchRevive(Handle timer, int client)
{
    if (g_SpecialDayState == inactive)
        return Plugin_Handled;

    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        DisplayGunMenu(client);
    }
    return Plugin_Handled;
}

public Action Timer_DeathMatchEnd(Handle timer)
{

    if (g_SpecialDayState == inactive || g_SpecialDay != deathMatch)
        return Plugin_Handled;

    int clientIndex = GetMaximumIndexFromArray(g_DeathMatchKills, sizeof(g_DeathMatchKills));
    if (IsValidClient(clientIndex))
    {
        PrintToChatAll("%s %N won the Death Match!", SD_PREFIX, clientIndex);
    }
    else 
    {
        PrintToChatAll("%s The winner left the game!", SD_PREFIX);
    }

    // Slay everyone but the person that won
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