using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.Globalization;
using System;

public class MenuManager : MonoBehaviour, IDataPersistence
{
    [Header("Menu Buttons")]
    [SerializeField] private Button TutorialButton;
    [SerializeField] private Button SettingsButton;
    [SerializeField] private Button LanguageGameButton;
    [SerializeField] private Button QuitGameButton;

    private string Language;
    public GameObject SettingsMenuUI;
    public GameObject ProfileMenuUI;
    public GameObject AddProfileMenuUI;
    public GameObject RemoveProfileMenuUI;
    private string profileId;
    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
    }

    public void SaveData(GameData data)
    {
        data.Language = this.Language;
        data.profileId = profileId;
    }

    private void Start()
    {
        SettingsMenuUI.SetActive(false);
        ProfileMenuUI.SetActive(false);
        AddProfileMenuUI.SetActive(false);
        RemoveProfileMenuUI.SetActive(false);

        if (SceneManager.GetActiveScene().name == "Menu_Anglais")
        {
            Language = "Anglais";
        }
        else
        {
            Language = "Français";
        }

        DataPersistenceManager.instance.SaveGame();
    }


    public void ChangeMenu()
    {
        DisableMenuButtons();
        DataPersistenceManager.instance.SaveGame();
        if (Language == "Français")
        {
            Language = "Anglais";
            SceneManager.LoadSceneAsync("Menu_Anglais");
        }
        else
        {
            Language = "Français";
            SceneManager.LoadSceneAsync("Menu_Français");
        }
    }

    public void LoadTutorial()
    {
        DisableMenuButtons();
        // initialize game data
        Time.timeScale = 1f;

        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Mode_Apprentissage");
    }

    public void LoadEvaluation()
    {
        TMPro.TMP_Dropdown D = GameObject.Find("UserDropdown").GetComponent<TMPro.TMP_Dropdown>();
        // Make sure they selected a profile Id
        if (D.value == 0)
        {
            TextMeshProUGUI DText = GameObject.Find("IdLabel").GetComponent<TMPro.TextMeshProUGUI>();
            DText.color = Color.red;
            return;
        }

        // If Id is selected
        DisableMenuButtons();
        profileId = D.options[D.value].text;
        Time.timeScale = 1f;
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Splash_Screen");
    }

    public void QuitGame()
    {
        DisableMenuButtons();
        DataPersistenceManager.instance.SaveGame();
        Application.Quit();
    }

    private void DisableMenuButtons()
    {
        TutorialButton.interactable = false;
        SettingsButton.interactable = false;
        LanguageGameButton.interactable = false;
        QuitGameButton.interactable = false;
    }

    public void EnterSettings()
    {
        DataPersistenceManager.instance.SaveGame();
        SettingsMenuUI.SetActive(true);
    }

    public void ExitSettings()
    {
        SettingsMenuUI.SetActive(false);
    }

    public void OpenProileMenu()
    {
        ProfileMenuUI.SetActive(true);
    }

    public void ExitProfileMenu()
    {
        ProfileMenuUI.SetActive(false);
    }
}