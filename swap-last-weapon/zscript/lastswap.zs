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
            e.Name.Left(5) == "slot " || e.Name.Left(4) == "use " ||
            e.Name.Left(13) == "selectweapon ")
        {
            // 遅延実行のため1ティック待つ
            let pmo = players[e.Player].mo;
            if (pmo)
            {
                let tracker = LastWeaponTracker(pmo.FindInventory("LastWeaponTracker"));
                if (tracker)
                {
                    tracker.ScheduleCheck();
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
    private int checkTimer;

    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }
    
    override void AttachToOwner(Actor other)
    {
        Super.AttachToOwner(other);
        // 初期武器をBrutalPistolに設定
        CurrClass = "BrutalPistol";
        LastCheckedWeaponName = "BrutalPistol";
    }
    
    void ScheduleCheck()
    {
        checkTimer = 2; // 2ティック後にチェック
    }
    
    override void DoEffect()
    {
        Super.DoEffect();
        
        // 遅延チェックのみ処理
        if (checkTimer > 0)
        {
            checkTimer--;
            if (checkTimer == 0)
            {
                CheckWeaponChange();
            }
        }
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
            PrevClass = CurrClass;
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