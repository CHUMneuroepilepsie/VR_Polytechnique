using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class PlayerStartPos : MonoBehaviour, IDataPersistence
{
    private int lvl = 0;
    public GameObject Player;

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
            float x = Convert.ToSingle(256.17);
            float y = Convert.ToSingle(1.82);
            float z = Convert.ToSingle(579.97);
            Player.transform.position = new Vector3(x, y, z);
            Quaternion target = Quaternion.Euler(0, -68, 0);
            Player.transform.rotation = target;
        }

        else if (lvl == 2)
        {
            float x = Convert.ToSingle(440.52);
            float y = Convert.ToSingle(9.77);
            float z = Convert.ToSingle(584.32);
            Player.transform.position = new Vector3(x, y, z);
            Quaternion target = Quaternion.Euler(0, 225, 0);
            Player.transform.rotation = target;
        }

        else if (lvl == 3)
        {
            float x = Convert.ToSingle(687.99);
            float y = Convert.ToSingle(3.04);
            float z = Convert.ToSingle(612.2);
            Player.transform.position = new Vector3(x, y, z);
            Quaternion target = Quaternion.Euler(0, -90, 0);
            Player.transform.rotation = target;
        }
    }
}
