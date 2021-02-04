public void SpecialDay_Headshot_Begin()
{
    SetConVarBool(g_FriendlyFire, true);
    RemoveAllWeapons();

    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;
        
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        StripAllWeapons(i);
        GivePlayerItem(i, "weapon_deagle");
        int weapon = GetPlayerWeaponSlot(i, CS_SLOT_SECONDARY);
        SetReserveAmmo(i, weapon, 999);
    }
}

public void SpecialDay_Headshot_End()
{
    SetConVarBool(g_FriendlyFire, false);
}

public Action Headshot_OnPlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
    int hitgroup = GetEventInt(event, "hitgroup");
    int damageToHealth = GetEventInt(event, "dmg_health");
    int health = GetEventInt(event, "health");

    if (hitgroup != 1)
    {
        int victim = GetClientOfUserId(GetEventInt(event, "userid"));
        if (IsValidClient(victim))
        {
            SetEntProp(victim, Prop_Send, "m_iHealth", (health + damageToHealth), 4);
        }
    }
}