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
    bool stopwatchActive = false;
    float currentTime;
    public TextMeshProUGUI currentTimeText;

    // Start is called before the first frame update
    void Start()
    {
        stopwatchActive = true;
    }

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
        if (PlayerPrefs.GetInt("TimerPaused") == 0)
        {
            stopwatchActive = true;
        }

        if (PlayerPrefs.GetInt("TimerPaused") == 1)
        {
            stopwatchActive = false;
        }

        if (stopwatchActive==true)
        {
            currentTime = currentTime + Time.deltaTime;
        }
    }
}
