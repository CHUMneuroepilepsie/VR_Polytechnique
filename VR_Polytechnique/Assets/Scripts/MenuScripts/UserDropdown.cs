using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class UserDropdown : MonoBehaviour, IDataPersistence
{
    public TextMeshProUGUI new_id;
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
            LoadDropdownoptions();
        }
        catch
        {
            Debug.Log("Settings Menu should not be active on launch");
        }
    }

    private void LoadDropdownoptions()
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
        if (id == "")
        {
            return;
        }
        else if (AvailableIds.Contains(id))
        {
            warningText.SetActive(true);
            return;
        }
        AvailableIds.Add(new_id.text);
        DataPersistenceManager.instance.SaveGame();
        LoadDropdownoptions();
        UsrDropdown.value = AvailableIds.Count;
    }
}
