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
    
    override void NetworkProcess(ConsoleEvent e)
    {
        // 武器選択コマンドを監視
        if (e.Name == "weapnext" || e.Name == "weapprev" || 
            e.Name.Left(6) == "slot " || e.Name.Left(4) == "use " ||
            e.Name.Left(14) == "selectweapon ")
        {
            let pmo = players[e.Player].mo;
            if (pmo)
            {
                let tracker = LastWeaponTracker(pmo.FindInventory("LastWeaponTracker"));
                if (tracker)
                {
                    tracker.CheckWeaponChange();
                }
            }
        }
    }
    
    override void WorldTick()
    {
        // 全プレイヤーの武器状態を定期的にチェック（35ティック = 1秒に1回）
        if (level.time % 35 == 0)
        {
            for (int i = 0; i < MAXPLAYERS; i++)
            {
                if (playeringame[i])
                {
                    let pmo = players[i].mo;
                    if (pmo)
                    {
                        let tracker = LastWeaponTracker(pmo.FindInventory("LastWeaponTracker"));
                        if (tracker)
                        {
                            tracker.CheckWeaponChange();
                        }
                    }
                }
            }
        }
    }
}

class LastWeaponTracker : Inventory
{
    Class<Weapon> PrevClass;
    Class<Weapon> CurrClass;
    private string LastCheckedWeaponName;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }

    void CheckWeaponChange()
    {
        let p = PlayerPawn(Owner);
        if (!p || !p.player) return;

        let w = p.player.ReadyWeapon;
        if (!w) return;
        
        // 武器名で比較
        string weaponName = w.GetClassName();
        if (weaponName != LastCheckedWeaponName)
        {
            // 武器が変わった
            if (LastCheckedWeaponName != "")
            {
                PrevClass = CurrClass;
            }
            CurrClass = w.GetClass();
            LastCheckedWeaponName = weaponName;
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
        if (!tr || !tr.PrevClass) return false;

        // 所持確認（無ければ失敗）
        if (!p.FindInventory(tr.PrevClass)) return false;

        p.A_SelectWeapon(tr.PrevClass);
        return false;
    }
}