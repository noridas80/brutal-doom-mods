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
    private Class<Weapon> LastCheckedWeapon;
    private int updateDelay;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.PERSISTENTPOWER
    }

    override void DoEffect()
    {
        Super.DoEffect();
        
        if (!Owner || !Owner.player) return;
        
        updateDelay++;
        if (updateDelay < 17) return;
        updateDelay = 0;
        
        let w = Owner.player.ReadyWeapon;
        if (!w) return;
        
        Class<Weapon> currentWeaponClass = w.GetClass();
        if (currentWeaponClass != LastCheckedWeapon)
        {
            if (LastCheckedWeapon && currentWeaponClass != PrevClass)
            {
                PrevClass = CurrClass;
            }
            CurrClass = currentWeaponClass;
            LastCheckedWeapon = currentWeaponClass;
        }
    }
}

class LastWeaponActivator : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.PERSISTENTPOWER
    }

    override bool Use (bool pickup)
    {
        if (!Owner) return false;

        let tr = LastWeaponTracker(Owner.FindInventory("LastWeaponTracker"));
        if (!tr || !tr.PrevClass) return false;

        let weapon = Owner.FindInventory(tr.PrevClass);
        if (!weapon) return false;

        PlayerPawn(Owner).A_SelectWeapon(tr.PrevClass);
        return false;
    }
}
