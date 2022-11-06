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
    [SerializeField] private Button StartGameButton;
    [SerializeField] private Button LanguageGameButton;
    [SerializeField] private Button QuitGameButton;

    private string Language;
    public GameObject SettingsMenuUI;

    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
    }

    public void SaveData(GameData data)
    {
        data.Language = this.Language;
    }

    private void Start()
    {
        SettingsMenuUI.SetActive(false);

        if (SceneManager.GetActiveScene().name == "Menu_Anglais")
        {
            Language = "Anglais";
        }
        else
        {
            Language = "Français";
        }
    }

    public void ChangeMenu()
    {
        DisableMenuButtons();
        if (Language == "Français")
        {
            Language = "Anglais";
            DataPersistenceManager.instance.SaveGame();
            SceneManager.LoadSceneAsync("Menu_Anglais");
        }
        else
        {
            Language = "Français";
            DataPersistenceManager.instance.SaveGame();
            SceneManager.LoadSceneAsync("Menu_Français");
        }
    }

    public void LoadTutorial()
    {
        DisableMenuButtons();
        // initialize game data
        DataPersistenceManager.instance.NewGame();
        // Prepare and laod scene
        Time.timeScale = 1f;

        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Mode_Apprentissage");
    }

    public void LoadEvaluation()
    {
        DisableMenuButtons();
        Time.timeScale = 1f;

        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Mode_Evaluation");
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
        StartGameButton.interactable = false;
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
}