using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MenuManager : MonoBehaviour
{
    public TextMeshProUGUI numberText;
    private Slider slider;
    private float volume;
    public int gameStartScene;
    public TextMeshProUGUI currentTimeText;

    private void Start()
    {
        volume = PlayerPrefs.GetFloat("Volume");
        slider = GameObject.Find("VolumeSlider").GetComponent<Slider>();
        slider.value = volume;
        currentTimeText.text = PlayerPrefs.GetString("Time");
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
