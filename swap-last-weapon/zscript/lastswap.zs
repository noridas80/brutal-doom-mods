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
    bool isSwapping;
    int swapCooldown;

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
        
        if (swapCooldown > 0)
        {
            swapCooldown--;
        }
        
        updateDelay++;
        if (updateDelay < 10) return;
        updateDelay = 0;
        
        let w = Owner.player.ReadyWeapon;
        if (!w) return;
        
        Class<Weapon> currentWeaponClass = w.GetClass();
        
        // スワップ中は通常の更新をスキップ
        if (isSwapping)
        {
            // スワップが完了したかチェック
            if (currentWeaponClass == CurrClass)
            {
                isSwapping = false;
                LastCheckedWeapon = currentWeaponClass;
            }
            return;
        }
        
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

        // スワップクールダウン中は処理しない
        if (tr.swapCooldown > 0) return false;

        let weapon = Owner.FindInventory(tr.PrevClass);
        if (!weapon) return false;

        // 同じ武器へのスワップは防ぐ
        if (tr.PrevClass == tr.CurrClass) return false;

        PlayerPawn(Owner).A_SelectWeapon(tr.PrevClass);
        
        // スワップ状態を設定
        tr.isSwapping = true;
        tr.swapCooldown = 15; // 0.5秒程度のクールダウン
        
        // 切り替え後、現在と前の武器を即座に入れ替え
        Class<Weapon> temp = tr.CurrClass;
        tr.CurrClass = tr.PrevClass;
        tr.PrevClass = temp;
        tr.LastCheckedWeapon = tr.CurrClass;
        
        return false;
    }
}
