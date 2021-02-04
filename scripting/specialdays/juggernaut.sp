public void SpecialDay_Juggernaut_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
}

public void SpecialDay_Juggernaut_End()
{
    SetConVarBool(g_FriendlyFire, false);
}

public Action Juggernaught_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

    int health = GetClientHealth(attacker);

    SetEntityHealth(attacker, health + 100);
}