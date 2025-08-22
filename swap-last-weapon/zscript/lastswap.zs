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
    private int tickSkip;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }

    override void DoEffect()
    {
        Super.DoEffect();
        
        // 10ティックごとにチェック（パフォーマンス対策）
        tickSkip++;
        if (tickSkip < 10) return;
        tickSkip = 0;
        
        let p = PlayerPawn(Owner);
        if (!p || !p.player) return;

        let w = p.player.ReadyWeapon;
        // インスタンスで比較（名前ではなく）
        if (w != CurrInst) // 武器が変わった
        {
            if (w)
            {
                // デバッグ出力
                Console.Printf("Weapon changed: %s -> %s", 
                    CurrClass ? CurrClass.GetClassName() : "none",
                    w.GetClassName());
                    
                PrevClass = CurrClass;
                CurrClass = w.GetClass();
                CurrInst  = w;
            }
        }
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
        if (!tr || !tr.PrevClass) 
        {
            Console.Printf("Swap failed: PrevClass=%s", 
                tr ? (tr.PrevClass ? tr.PrevClass.GetClassName() : "null") : "no tracker");
            return false;
        }

        // 所持確認（無ければ失敗）
        if (!p.FindInventory(tr.PrevClass)) 
        {
            Console.Printf("Swap failed: Don't have %s", tr.PrevClass.GetClassName());
            return false;
        }

        Console.Printf("Swapping to: %s", tr.PrevClass.GetClassName());
        p.A_SelectWeapon(tr.PrevClass);
        return false;
    }
}