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
    if (IsValidClient(client))
    {
        CS_RespawnPlayer(client);
        DisplayGunMenu(client);
    }
}

public Action Timer_DeathMatchEnd(Handle timer)
{
    int clientIndex = GetMaximumIndexFromArray(g_DeathMatchKills, sizeof(g_DeathMatchKills));
    if (IsValidClient(clientIndex))
    {
        PrintToChatAll("%s %N won the Death Match!");
    }
    else 
    {
        PrintToChatAll("%s The winner left the game!");
    }

    // Slay everyone but the person that one
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerAlive(i))
        {
            if (i != clientIndex)
                ForcePlayerSuicide(i);
        }
    }

}