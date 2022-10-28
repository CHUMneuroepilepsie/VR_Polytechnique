using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class LevelDropdown : MonoBehaviour, IDataPersistence
{
    public TextMeshProUGUI output;
    private int Level = 1;
    private string Language = "";
    private TMPro.TMP_Dropdown LvlDropdown;

    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
        this.Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        LvlDropdown = GameObject.Find("LevelDropdown").GetComponent<TMPro.TMP_Dropdown>();
        data.Level = LvlDropdown.value + 1;
    }

    // Start is called before the first frame update
    public void HandleInputData(int val)
    {
        if (val == 0)
        {
            if (Language == "Fran�ais")
            {
                output.text = "Niveau 1 : 12 points de contr�le";
            }
            else if (Language == "Anglais")
            {
                output.text = "Level 1 : 12 checkpoints";
            }
        }
        if (val == 1)
        {
            if (Language == "Fran�ais")
            {
                output.text = "Niveau 2 : 15 points de contr�le";
            }
            else if (Language == "Anglais")
            {
                output.text = "Level 2 : 15 checkpoints";
            }
        }
        if (val == 2)
        {
            if (Language == "Fran�ais")
            {
                output.text = "Niveau 3 : 18 points de contr�le";
            }
            else if (Language == "Anglais")
            {
                output.text = "Level 3 : 18 checkpoints";
            }
        }
    }

    public void SavePreferences()
    {
        DataPersistenceManager.instance.SaveGame();
    }
}
