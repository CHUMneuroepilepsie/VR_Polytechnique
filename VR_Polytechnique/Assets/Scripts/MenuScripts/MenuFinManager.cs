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
        Debug.Log("Saving " + Language);
        data.Language = this.Language;
    }

    public void ReturnMenu()
    {
        SceneManager.LoadScene("Menu_" + Language);
    }
    public void ChangeLanguage()
    {
        if (Language == "Anglais")
        {
            Debug.Log(Language);
            Language = "Français";
            Debug.Log(Language);
            SceneManager.LoadScene("Menu_Fin_Français");
        }
        else
        {
            Debug.Log(Language);
            Language = "Anglais";
            Debug.Log(Language);
            SceneManager.LoadScene("Menu_Fin_Anglais");
        }        
    }
    public void QuitGame()
    {
        Application.Quit();
    }
}