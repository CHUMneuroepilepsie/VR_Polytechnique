using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class TimerText : MonoBehaviour, IDataPersistence
{
    public TextMeshProUGUI currentTimeText;
    private float currentTime;
    // Start is called before the first frame update
    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
        this.currentTime = data.currentTime;
    }

    public void SaveData(GameData data)
    {
        // DO NOT DELETE
    }
            
    private void Start()
    {
        TimeSpan time = TimeSpan.FromSeconds(currentTime);
        currentTimeText.text = time.ToString(@"mm\:ss\:fff");
    }
}
