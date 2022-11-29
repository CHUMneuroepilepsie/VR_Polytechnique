using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;


public class AddProfilePanel : MonoBehaviour, IDataPersistence
{
    public ProfilePanel pPanel;
    List<string> AvailableIds = new List<string>();
    public GameObject warningText;
    public GameObject IdInput;
    public GameObject dateOfBirthInput;
    public GameObject nameInput;

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
            IdInput.GetComponent<TMP_InputField>().text = "";
            dateOfBirthInput.GetComponent<TMP_InputField>().text = "";
            nameInput.GetComponent<TMP_InputField>().text = "";
        }
        catch
        {
            Debug.Log("Add profile menu should not be active on launch");
        }
    }

    public void AddProfile()
    {
        DataPersistenceManager.instance.LoadGame();
        string id = IdInput.GetComponent<TMP_InputField>().text;
        string date = dateOfBirthInput.GetComponent<TMP_InputField>().text;
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
                warningText.GetComponent<TextMeshProUGUI>().text = "Ce Id existe déjà";
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
            warningText.GetComponent<TextMeshProUGUI>().text = "Profil ajouté!";
        }
        warningText.SetActive(true);
        DataPersistenceManager.instance.LoadGame();
        pPanel.UpdatePanel();
    }

    public void SaveProfile()
    {
        FileDataHandler dataHandler = new FileDataHandler(Application.persistentDataPath, fileName);
        ProfileData pData = dataHandler.LoadProfile(IdInput.GetComponent<TMP_InputField>().text);

        pData.profileName = nameInput.GetComponent<TMP_InputField>().text;
        pData.profileId = IdInput.GetComponent<TMP_InputField>().text;
        pData.dateOfBirth = dateOfBirthInput.GetComponent<TMP_InputField>().text;

        dataHandler.SaveEvaluation(pData);
    }

    private static bool isNumber(string s)
    {
        return int.TryParse(s, out _);
    }
}
