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

public void SpecialDay_SkyWars_Begin()
{

    for (int i = 1; i <= MaxClients; i++)
    {

        if (!IsValidClient(i) || !IsPlayerAlive(i))
            continue;

        StripAllWeapons(i);

        SetEntityMoveType(i, MOVETYPE_FLY);
        SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 2.5);
        SetEntProp(i, Prop_Data, "m_ArmorValue", 0.0);
        GivePlayerItem(i, "weapon_deagle");
        GivePlayerItem(i, "weapon_m3");
        
    }

}

public void SpecialDay_SkyWars_End()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsValidClient(i) && IsPlayerOnTeam(i))
        {
            SetEntityMoveType(i, MOVETYPE_WALK);
            SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
        }
    }
}