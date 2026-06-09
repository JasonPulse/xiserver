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

#include "0x0c9_equip_inspect_general.h"

#include "common/settings.h"
#include "entities/charentity.h"
#include "items/item_linkshell.h"

GP_SERV_COMMAND_EQUIP_INSPECT::GENERAL::GENERAL(const CCharEntity* PChar, const CCharEntity* PTarget)
{
    auto& packet = this->data();

    packet.UniqNo     = PTarget->id;
    packet.ActIndex   = PTarget->targid;
    packet.OptionFlag = 0x01;

    auto* PLinkshell = reinterpret_cast<CItemLinkshell*>(PTarget->getEquip(SLOT_LINK1));
    if (PLinkshell && PLinkshell->isType(ITEM_LINKSHELL))
    {
        packet.ItemNo = PLinkshell->getID();
        std::memcpy(packet.sComLinkName, PLinkshell->getSignature().c_str(), std::clamp<size_t>(PLinkshell->getSignature().size(), 0, 15));
        packet.sComColor = PLinkshell->GetLSRawColor();
    }

    if (PChar->visibleGmLevel >= 3 || !PTarget->isAnon())
    {
        packet.job[0] = PTarget->GetMJob();
        packet.job[1] = PTarget->GetSJob();
        packet.lvl[0] = PTarget->GetMLevel();
        packet.lvl[1] = PTarget->GetSLevel();

        // Master Levels: populate from the target's tracked ML. Client may or
        // may not render this depending on version; the stat bonuses still
        // apply server-side regardless of UI display.
        packet.mjob       = PTarget->GetMJob(); // This is sent even if the job isnt mastered
        const uint8 maxML = settings::get<uint8>("main.MAX_MASTER_LEVEL");
        packet.mlvl       = PTarget->GetMasterLevel();
        // 0x01: actively earning (below cap), 0x02: capped.
        packet.mflags = packet.mlvl >= maxML ? 0x02 : (packet.mlvl > 0 ? 0x01 : 0x00);
    }

    // TODO: Ballista info
    packet.BallistaChevronCount = 0; // The checked entities Ballista chevron count.
    packet.BallistaChevronFlags = 0; // The checked entities Ballista chevron flags.
    packet.BallistaFlags        = 0; // This value holds the entities current Ballista flags.
    packet.MesNo                = 0; // Message to print during Ballista if flag is 0x02
    packet.Params[0]            = 0; // Params for the message
}
