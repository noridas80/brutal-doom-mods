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
    private string PrevWeaponName;
    private string CurrWeaponName;
    private int tickCounter;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }

    override void Tick()
    {
        let p = PlayerPawn(Owner);
        if (!p || !p.player) { Super.Tick(); return; }

        // 3ティックごとにチェック（パフォーマンスとテクスチャ問題の回避）
        tickCounter++;
        if (tickCounter < 3) { Super.Tick(); return; }
        tickCounter = 0;

        let w = p.player.ReadyWeapon;
        if (!w) { Super.Tick(); return; }
        
        // 武器名で比較（インスタンスではなく）
        string weaponName = w.GetClassName();
        if (weaponName != CurrWeaponName) // 武器が変わった
        {
            PrevWeaponName = CurrWeaponName;
            PrevClass = CurrClass;
            CurrWeaponName = weaponName;
            CurrClass = w.GetClass();
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
