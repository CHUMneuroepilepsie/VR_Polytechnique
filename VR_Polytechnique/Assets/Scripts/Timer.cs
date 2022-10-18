using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using TMPro;
using UnityEngine.SceneManagement;
using System.Globalization;

public class Timer : MonoBehaviour
{
    bool stopwatchActive = false;
    float currentTime;
    private String current_time;
    public TextMeshProUGUI currentTimeText;

    // Start is called before the first frame update
    void Start()
    {
        current_time = PlayerPrefs.GetString("Time");
        if (PlayerPrefs.GetInt("IsFirst") == 1) {
            current_time = "00:00:000";
        }
        String[] separator = { ":", ":" };
        String[] strlist = current_time.Split(separator, 3, StringSplitOptions.RemoveEmptyEntries);
        currentTime = (float)((Convert.ToDouble(strlist[0]))*60 + (Convert.ToDouble(strlist[1])) + (Convert.ToDouble(strlist[2]))/1000);
        stopwatchActive = true;
        PlayerPrefs.SetInt("TimerPaused", 0);
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
            PlayerPrefs.SetString("Time", current_time);
            stopwatchActive = false;
        }

        if (stopwatchActive==true)
        {
            currentTime = currentTime + Time.deltaTime;
        }

        TimeSpan time = TimeSpan.FromSeconds(currentTime);
        current_time = time.ToString(@"mm\:ss\:fff");
    }
}
