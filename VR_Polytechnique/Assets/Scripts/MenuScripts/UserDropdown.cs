using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;

public class UserDropdown : MonoBehaviour, IDataPersistence
{
    public TextMeshProUGUI new_id;
    private TextMeshProUGUI DText;
    public GameObject warningText;
    private TMPro.TMP_Dropdown UsrDropdown;
    private string Language;
    List<string> AvailableIds = new List<string>();
    
    public void LoadData(GameData data)
    {
        AvailableIds = data.AvailableIds;
        Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        data.AvailableIds = this.AvailableIds;
    }

    // Start is called before the first frame update
    void OnEnable()
    {
        try
        {
            UsrDropdown = GameObject.Find("UserDropdown").GetComponent<TMPro.TMP_Dropdown>();
            DText = GameObject.Find("IdLabel").GetComponent<TMPro.TextMeshProUGUI>();
            LoadDropdownOptions();
        }
        catch
        {
            Debug.Log("Settings Menu should not be active on launch");
        }
    }

    private void LoadDropdownOptions()
    {
        DataPersistenceManager.instance.LoadGame();
        UsrDropdown.ClearOptions();
        if (Language == "Anglais") { UsrDropdown.AddOptions(new List<string> { "No profile selected" }); }
        else { UsrDropdown.AddOptions(new List<string> { "Aucun profil sélectionné" }); }
        UsrDropdown.AddOptions(AvailableIds);
    }

    public void AddId()
    {
        warningText.SetActive(false);
        string id = new_id.text;
        if (id.Length == 1)
        {
            return;
        }
        else if (AvailableIds.Contains(id))
        {
            warningText.SetActive(true);
            UsrDropdown.value = AvailableIds.FindIndex(p => p == id) + 1;
            return;
        }
        AvailableIds.Add(new_id.text);
        DataPersistenceManager.instance.SaveGame();
        LoadDropdownOptions();
        UsrDropdown.value = AvailableIds.Count;
    }

    public void OnDropdownValueChanged()
    {
        DText.color = Color.white;
    }
}
