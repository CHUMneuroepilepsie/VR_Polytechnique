using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Globalization;
using System;

public class MenuManager : MonoBehaviour
{
    public TextMeshProUGUI numberText;
    private Slider slider;
    private float volume;
    public int gameStartScene;

    private void Start()
    {
        volume = PlayerPrefs.GetFloat("Volume");
        slider = GameObject.Find("VolumeSlider").GetComponent<Slider>();
        slider.value = volume;
        string scene_name = SceneManager.GetActiveScene().name;
        String[] separator = {"_"};
        String[] strlist = scene_name.Split(separator, 2, StringSplitOptions.RemoveEmptyEntries);
        if (strlist[1] == "Anglais" || strlist[1] == "Français") {
            PlayerPrefs.SetString("Language", strlist[1]);
        }
    }
    public void SetNumberText(float volume)
    {
        numberText.text = volume.ToString();
        PlayerPrefs.SetFloat("Volume", volume);
    }
    public void StartGame()
    {
        PlayerPrefs.SetInt("TimerPaused", 0);
        PlayerPrefs.SetInt("IsFirst", 1);
        Time.timeScale = 1f;
        SceneManager.LoadScene(gameStartScene);
    }
    public void QuitGame()
    {
        Application.Quit();
    }
}