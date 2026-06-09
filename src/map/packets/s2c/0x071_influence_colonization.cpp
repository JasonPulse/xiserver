/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "0x071_influence_colonization.h"

#include "0x071_influence.h"
#include "entities/charentity.h"
#include "utils/charutils.h"

namespace
{
// Coalition rank field is 4 bits — clamp anything stored in CharVars
// to the legal packet range. Defaults to 0 if the CharVar is unset.
inline uint32_t readCoalitionRank(CCharEntity* PChar, const std::string& varName)
{
    const auto raw = PChar->getCharVar(varName);
    if (raw <= 0)
    {
        return 0;
    }
    if (raw >= 15)
    {
        return 15;
    }
    return static_cast<uint32_t>(raw);
}
} // namespace

// Coalition ranks and zone colonization rates come from CharVars; the
// Lua-side API lives in scripts/globals/coalition.lua. Zone colonization
// state isn't yet tracked per-server, so those stay 0.
GP_SERV_COMMAND_INFLUENCE::COLONIZATION::COLONIZATION(CCharEntity* PChar)
{
    auto& packet = this->data();

    packet.Mode   = GP_SERV_COMMAND_INFLUENCE_MODE::Colonization;
    packet.Length = 0x34; // This is the size of the rest of the packet after Length but without the padding.
    packet.Bayld  = charutils::GetPoints(PChar, "bayld");

    packet.Ranks = {
        .Pioneers     = readCoalitionRank(PChar, "Coalition_Pioneers_Rank"),
        .Peacekeepers = readCoalitionRank(PChar, "Coalition_Peacekeepers_Rank"),
        .Couriers     = readCoalitionRank(PChar, "Coalition_Couriers_Rank"),
        .Scouts       = readCoalitionRank(PChar, "Coalition_Scouts_Rank"),
        .Inventors    = readCoalitionRank(PChar, "Coalition_Inventors_Rank"),
        .Mummers      = readCoalitionRank(PChar, "Coalition_Mummers_Rank"),
    };

    packet.Zones = {
        .YahseHuntingGrounds = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 3,
        },
        .CeizakBattlegrounds = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 3,
        },
        .ForetDeHennetiel = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 4,
        },
        .YorciaWeald = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 3,
        },
        .MorimarBasaltFields = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 5,
        },
        .MarjamiRavine = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 4,
        },
        .KamihrDrifts = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 4,
        },
        .RaKaznar = {
            .ColonizationRate = 0,
            .CurrentBivouacs  = 0,
            .MaxBivouacs      = 0,
        },
    };
}
