using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using Unity.VisualScripting;
using System.Linq;

public class UserDropdown : MonoBehaviour, IDataPersistence
{
    public TextMeshProUGUI new_id;
    private TextMeshProUGUI DText;
    public GameObject warningText;
    private TMPro.TMP_Dropdown UsrDropdown;
    public GameObject AddProfileMenuUI;
    private string Language;
    List<string> AvailableIds = new List<string>();
    
    public void LoadData(GameData data)
    {
        AvailableIds = data.AvailableIds;
        Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        data.AvailableIds = this.AvailableIds.OrderBy(q => q).ToList();
    }

    // Start is called before the first frame update
    void OnEnable()
    {
        // Security in case SettingsPanel was enabled on launch (which should not be the case in the builded game
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

    public void LoadDropdownOptions()
    {
        DataPersistenceManager.instance.LoadGame();
        UsrDropdown.ClearOptions();
        if (Language == "Anglais") { UsrDropdown.AddOptions(new List<string> { "No profile selected" }); }
        else { UsrDropdown.AddOptions(new List<string> { "Aucun profil sélectionné" }); }
        UsrDropdown.AddOptions(AvailableIds);
    }

    public void AddId()
    {
        AddProfileMenuUI.SetActive(true);
        LoadDropdownOptions();
        UsrDropdown.value = AvailableIds.Count;
    }

    public void OnDropdownValueChanged()
    {
        DText.color = Color.white;
    }
}
