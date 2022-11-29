using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System;
using System.IO;
//using System.Text.Json;

public class MenuFinManager : MonoBehaviour, IDataPersistence
{
    private string Language;
    private string profileId;
    private float currentTime;
    private int lvl;
    private bool isSaved;
    private string fileName = "Evaluation_Results";
    private GameObject ConfirmationText;

    private void Start()
    {
        ConfirmationText = GameObject.Find("ConfirmationText");
        ConfirmationText.SetActive(false);
        isSaved = false;
    }

    public void LoadData(GameData data)
    {
        this.Language = data.Language;
        this.profileId = data.profileId;
        this.currentTime = data.currentTime;
        this.lvl = data.Level;
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

    public void SaveResults()
    {
        if (!isSaved)
        {
            FileDataHandler dataHandler = new FileDataHandler(Application.persistentDataPath, fileName);

            ProfileData pData = dataHandler.LoadProfile(profileId);
            EvaluationData eData = new EvaluationData();
            DateTime date = DateTime.Now;
            eData.date = date.ToString("g");
            eData.time = TimeSpan.FromSeconds(currentTime).ToString(@"mm\:ss");
            eData.lvl = lvl;
            pData.evaluationData.Add(eData);

            dataHandler.SaveEvaluation(pData);
            isSaved = true;
            ConfirmationText.SetActive(true);
        }
    }

    public void QuitGame()
    {
        DataPersistenceManager.instance.SaveGame();
        Application.Quit();
    }
}