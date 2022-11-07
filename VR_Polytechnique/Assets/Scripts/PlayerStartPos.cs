using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerStartPos : MonoBehaviour, IDataPersistence
{
    private int lvl = 0;

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
            transform.position = new Vector3(0, 50, 10);
        }

        else if (lvl == 2)
        {
            transform.position = new Vector3(0, 200, 10);
        }

        else if (lvl == 3)
        {
            transform.position = new Vector3(0, 400, 10);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
