using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class LevelDropdown : MonoBehaviour, IDataPersistence
{
    public TextMeshProUGUI output;
    private string Language = "";
    private TMPro.TMP_Dropdown LvlDropdown;
    private int lvl = 0;

    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
        this.Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        data.Level = lvl + 1;
    }

    // Start is called before the first frame update
    public void HandleInputData(int val)
    {
        LvlDropdown = GameObject.Find("LevelDropdown").GetComponent<TMPro.TMP_Dropdown>();
        lvl = LvlDropdown.value;
    }

    public void SavePreferences()
    {
        DataPersistenceManager.instance.SaveGame();
    }
}
