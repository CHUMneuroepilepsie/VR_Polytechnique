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
    public int MenuScene = 1;
    private String current_time;

    // Start is called before the first frame update
    void Start()
    {
        current_time = PlayerPrefs.GetString("Time");
        String[] separator = { ":", ":" };
        String[] strlist = current_time.Split(separator, 3, StringSplitOptions.RemoveEmptyEntries);
        currentTime = (float)((Convert.ToDouble(strlist[0]))*60 + (Convert.ToDouble(strlist[1])) + (Convert.ToDouble(strlist[2]))/1000);
        stopwatchActive = true;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown("space"))
        {
            PlayerPrefs.SetString("Time", current_time);
            stopwatchActive = false;
            SceneManager.LoadScene(MenuScene);
        }

        if (stopwatchActive==true)
        {
            currentTime = currentTime + Time.deltaTime;
        }

        TimeSpan time = TimeSpan.FromSeconds(currentTime);
        current_time = time.ToString(@"mm\:ss\:fff");
    }
}
