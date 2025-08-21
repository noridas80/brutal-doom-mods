class LastWeaponEvent : EventHandler
{
    override void PlayerEntered(PlayerEvent e)
    {
        let pmo = players[e.PlayerNumber].mo;
        if (pmo)
        {
            if (!pmo.FindInventory("LastWeaponTracker"))
                pmo.GiveInventory("LastWeaponTracker", 1);
            if (!pmo.FindInventory("LastWeaponActivator"))
                pmo.GiveInventory("LastWeaponActivator", 1);
        }
    }
}

class LastWeaponTracker : Inventory
{
    Class<Weapon> PrevClass;
    Class<Weapon> CurrClass;
    private Weapon CurrInst;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }

    override void Tick()
    {
        let p = PlayerPawn(Owner);
        if (!p || !p.player) { Super.Tick(); return; }

        let w = p.player.ReadyWeapon;
        if (w != CurrInst) // 武器が変わった
        {
            if (w)
            {
                PrevClass = CurrClass;
                CurrClass = w.GetClass();
                CurrInst  = w;
            }
        }
        Super.Tick();
    }
}

class LastWeaponActivator : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }

    override bool Use (bool pickup)
    {
        let p = PlayerPawn(Owner);
        if (!p) return false;

        let tr = LastWeaponTracker(p.FindInventory("LastWeaponTracker"));
        if (!tr || !tr.PrevClass) return false;

        // 所持確認（無ければ失敗）
        if (!p.FindInventory(tr.PrevClass)) return false;

        p.A_SelectWeapon(tr.PrevClass);
        return false;
    }
}
