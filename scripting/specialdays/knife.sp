public void SpecialDay_Knife_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons();

    for (int i = 1; i <= MaxClients; i++)
    {

        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;

        StripAllWeapons(i);
        GivePlayerItem(i, "weapon_knife");
    }
}

public void SpecialDay_Knife_End()
{
    SetConVarBool(g_FriendlyFire, false);
}