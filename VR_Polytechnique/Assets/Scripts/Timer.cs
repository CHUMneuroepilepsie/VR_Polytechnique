using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using TMPro;
using UnityEngine.SceneManagement;
using System.Globalization;

public class Timer : MonoBehaviour, IDataPersistence
{
    float currentTime;
    public TextMeshProUGUI currentTimeText;

    public void LoadData(GameData data)
    {
        // For loading data when entering scene (DO NOT DELETE)
    }

    public void SaveData(GameData data)
    {
        data.currentTime = this.currentTime;
    }

    // Update is called once per frame
    void Update()
    {
        currentTime = currentTime + Time.deltaTime;
    }
}
