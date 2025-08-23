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
    Class<Weapon> LastCheckedWeapon;
    private int updateDelay;
    Class<Weapon> ExpectedWeapon;  // スワップ後に期待される武器

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
        if (updateDelay < 10) return;
        updateDelay = 0;
        
        let w = Owner.player.ReadyWeapon;
        if (!w) return;
        
        Class<Weapon> currentWeaponClass = w.GetClass();
        
        // 期待される武器への切り替えが完了したかチェック
        if (ExpectedWeapon && currentWeaponClass == ExpectedWeapon)
        {
            ExpectedWeapon = null;
            LastCheckedWeapon = currentWeaponClass;
            return;
        }
        
        // スワップによる切り替え中は通常の更新をスキップ
        if (ExpectedWeapon)
        {
            return;
        }
        
        if (currentWeaponClass != LastCheckedWeapon)
        {
            // 現在の武器と前の武器が異なることを確認
            if (LastCheckedWeapon && currentWeaponClass != PrevClass && currentWeaponClass != CurrClass)
            {
                PrevClass = CurrClass;
                CurrClass = currentWeaponClass;
            }
            else if (LastCheckedWeapon)
            {
                // PrevClassまたはCurrClassと同じ場合は、適切に更新
                if (currentWeaponClass != CurrClass)
                {
                    PrevClass = CurrClass;
                    CurrClass = currentWeaponClass;
                }
            }
            else
            {
                CurrClass = currentWeaponClass;
            }
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

        // 同じ武器へのスワップは防ぐ
        if (tr.PrevClass == tr.CurrClass) return false;

        let weapon = Owner.FindInventory(tr.PrevClass);
        if (!weapon) return false;

        PlayerPawn(Owner).A_SelectWeapon(tr.PrevClass);
        
        // 期待される武器を設定
        tr.ExpectedWeapon = tr.PrevClass;
        
        // 切り替え後、現在と前の武器を即座に入れ替え
        Class<Weapon> temp = tr.CurrClass;
        tr.CurrClass = tr.PrevClass;
        tr.PrevClass = temp;
        tr.LastCheckedWeapon = tr.CurrClass;
        
        return false;
    }
}
