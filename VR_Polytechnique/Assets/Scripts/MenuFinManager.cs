using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System;

public class MenuFinManager : MonoBehaviour
{
    public TextMeshProUGUI numberText;
    private Slider slider;
    private float volume;
    public string MenuScene;
    public TextMeshProUGUI currentTimeText;

    private void Start()
    {
        volume = PlayerPrefs.GetFloat("Volume");
        slider = GameObject.Find("VolumeSlider").GetComponent<Slider>();
        slider.value = volume;
        currentTimeText.text = PlayerPrefs.GetString("Time");
        string scene_name = SceneManager.GetActiveScene().name;
        String[] separator = { "_", "_" };
        String[] strlist = scene_name.Split(separator, 3, StringSplitOptions.RemoveEmptyEntries);
        PlayerPrefs.SetString("Language", strlist[2]);
    }
    public void SetNumberText(float volume)
    {
        numberText.text = volume.ToString();
        PlayerPrefs.SetFloat("Volume", volume);
    }
    public void ReturnMenu()
    {
        string language = PlayerPrefs.GetString("Language");
        SceneManager.LoadScene("Menu_" + language);
    }
    public void ChangeLanguage()
    {
        SceneManager.LoadScene(MenuScene);
    }
    public void QuitGame()
    {
        Application.Quit();
    }
}