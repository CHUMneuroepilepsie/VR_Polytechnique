using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System;

public class MenuFinManager : MonoBehaviour, IDataPersistence
{
    private string Language;

    public void LoadData(GameData data)
    {
        this.Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        // Save data when leaving scene (DO NOT DELETE)
        data.Language = this.Language;
    }

    public void ReturnMenu()
    {
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadScene("Menu_" + Language);
    }
    public void ChangeLanguage()
    {
        if (Language == "Anglais")
        {
            Language = "Français";
            DataPersistenceManager.instance.SaveGame();
            SceneManager.LoadScene("Menu_Fin_Français");
        }
        else
        {
            Language = "Anglais";
            DataPersistenceManager.instance.SaveGame();
            SceneManager.LoadScene("Menu_Fin_Anglais");
        }        
    }
    public void QuitGame()
    {
        DataPersistenceManager.instance.SaveGame();
        Application.Quit();
    }
}