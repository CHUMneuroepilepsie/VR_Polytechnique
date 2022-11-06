using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Checkpoint : MonoBehaviour, IDataPersistence
{
   
    [SerializeField] private string id;
    private bool checkpoint = false;
    public GameObject Player;

    public void LoadData(GameData data)
    {
        data.checkpointPassed.TryGetValue(id, out checkpoint);

    }
    public void SaveData( GameData data)
    {
        if (data.checkpointPassed.ContainsKey(id))
        {
            data.checkpointPassed.Remove(id);
        }
        data.checkpointPassed.Add(id, checkpoint);
    }
    private void OnTriggerEnter(Collider collision)
    {

        if (collision.gameObject.CompareTag("Player") && checkpoint == false)
        {
            checkpoint = true;
        }
    }
}

