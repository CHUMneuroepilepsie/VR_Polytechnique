using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class PlayerStartPos : MonoBehaviour, IDataPersistence
{
    private int lvl = 0;
    public GameObject Player;

    Vector3 LVL1POS = new Vector3(Convert.ToSingle(256.17), Convert.ToSingle(1.82), Convert.ToSingle(579.97));
    Vector3 LVL2POS = new Vector3(Convert.ToSingle(440.52), Convert.ToSingle(9.77), Convert.ToSingle(584.32));
    Vector3 LVL3POS = new Vector3(Convert.ToSingle(687.99), Convert.ToSingle(3.04), Convert.ToSingle(612.2));

    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
        this.lvl = data.Level;
    }

    public void SaveData(GameData data)
    {
        // Do not delete
    }

    // Start is called before the first frame update
    void Start()
    {
        if (lvl == 1)
        {
            Player.transform.position = LVL1POS;
            Quaternion target = Quaternion.Euler(0, -68, 0);
            Player.transform.rotation = target;
        }

        else if (lvl == 2)
        {
            Player.transform.position = LVL2POS;
            Quaternion target = Quaternion.Euler(0, 225, 0);
            Player.transform.rotation = target;
        }

        else if (lvl == 3)
        {
            Player.transform.position = LVL3POS;
            Quaternion target = Quaternion.Euler(0, -90, 0);
            Player.transform.rotation = target;
        }
    }
}
