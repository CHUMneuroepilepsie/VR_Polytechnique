using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.UI;

public class AddProfilePanel : MonoBehaviour, IDataPersistence
{
    public ProfilePanel pPanel;
    List<string> AvailableIds = new List<string>();
    public TextMeshProUGUI new_id;
    public TextMeshProUGUI dateOfBirth;
    public TextMeshProUGUI fullName;
    public GameObject warningText;
    private string fileName = "Evaluation_Results";
    private string Language;
    public void LoadData(GameData data)
    {
        AvailableIds = data.AvailableIds;
        Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        data.AvailableIds = AvailableIds.OrderBy(q => q).ToList();
    }

    void OnEnable()
    {
        // Security in case ProfilePanel was enabled on launch (which should not be the case in the builded game
        try
        {
            DataPersistenceManager.instance.LoadGame();
            warningText.SetActive(false);
        }
        catch
        {
            Debug.Log("Add profile menu should not be active on launch");
        }
    }

    public void AddProfile()
    {
        DataPersistenceManager.instance.LoadGame();
        string id = new_id.text;
        id = id.Remove(id.Length - 1);
        string date = dateOfBirth.text;
        date = date.Remove(date.Length - 1); 
        TextMeshProUGUI idText = GameObject.Find("IdText (TMP)").GetComponent<TextMeshProUGUI>();
        TextMeshProUGUI dateText = GameObject.Find("DateOfBirthInputText").GetComponent<TextMeshProUGUI>();

        idText.color = Color.white;
        dateText.color = Color.white;
        warningText.SetActive(false);

        if (id.Length == 0)
        {
            idText.color = Color.red;
            return;
        }
        if (date.Length == 0)
        {
            dateText.color = Color.red;
            return;
        }
        if (AvailableIds.Contains(id))
        {
            if (Language == "Anglais")
            {
                warningText.GetComponent<TextMeshProUGUI>().color = Color.red;
                warningText.GetComponent<TextMeshProUGUI>().text = "This Id already exists";
            }
            else
            {
                warningText.GetComponent<TextMeshProUGUI>().color = Color.red;
                warningText.GetComponent<TextMeshProUGUI>().text = "Ce Id existe d�j�";
            }
            warningText.SetActive(true);
            return;
        }

        List<string> dateSplits = new List<string>();
        dateSplits.AddRange(date.Split('-'));
        if (dateSplits.Count() != 3 || dateSplits[0].Length != 4 
            || dateSplits[1].Length != 2 || dateSplits[2].Length != 2
            || !dateSplits.TrueForAll(isNumber))
        {
            if (Language == "Anglais")
            {
                warningText.GetComponent<TextMeshProUGUI>().color = Color.red;
                warningText.GetComponent<TextMeshProUGUI>().text = "Date should have this format: aaaa-mm-dd";
            }
            else
            {
                warningText.GetComponent<TextMeshProUGUI>().color = Color.red;
                warningText.GetComponent<TextMeshProUGUI>().text = "La date devrait avoir le format aaaa-mm-dd";
            }
            warningText.SetActive(true);
            return;
        }

        AvailableIds.Add(id);
        SaveProfile();
        DataPersistenceManager.instance.SaveGame();
        if (Language == "Anglais")
        {
            warningText.GetComponent<TextMeshProUGUI>().color = Color.white;
            warningText.GetComponent<TextMeshProUGUI>().text = "Profile added!";
        }
        else
        {
            warningText.GetComponent<TextMeshProUGUI>().color = Color.white;
            warningText.GetComponent<TextMeshProUGUI>().text = "Profil ajout�!";
        }
        warningText.SetActive(true);
        DataPersistenceManager.instance.LoadGame();
        pPanel.UpdatePanel();
    }

    public void SaveProfile()
    {
        FileDataHandler dataHandler = new FileDataHandler(Application.persistentDataPath, fileName);
        ProfileData pData = dataHandler.LoadProfile(new_id.text);

        pData.profileName = fullName.text;
        pData.profileId = new_id.text;
        pData.dateOfBirth = dateOfBirth.text;

        dataHandler.SaveEvaluation(pData);
    }

    private static bool isNumber(string s)
    {
        return int.TryParse(s, out _);
    }
}
