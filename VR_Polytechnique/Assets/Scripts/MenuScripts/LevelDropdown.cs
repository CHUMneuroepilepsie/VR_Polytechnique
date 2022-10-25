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

    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
        this.Language = data.Language;
    }

    public void SaveData(GameData data)
    {
        data.Level = this.Level;
    }

    // Start is called before the first frame update
    public void HandleInputData(int val)
    {
        if (val == 0)
        {
            if (Language == "Français")
            {
                output.text = "Niveau 1 : 12 points de contrôle";
            }
            else if (Language == "Anglais")
            {
                output.text = "Level 1 : 12 checkpoints";
            }
            Level = val+1;
        }
        if (val == 1)
        {
            if (Language == "Français")
            {
                output.text = "Niveau 2 : 15 points de contrôle";
            }
            else if (Language == "Anglais")
            {
                output.text = "Level 2 : 15 checkpoints";
            }
            Level = val+1;
        }
        if (val == 2)
        {
            if (Language == "Français")
            {
                output.text = "Niveau 3 : 18 points de contrôle";
            }
            else if (Language == "Anglais")
            {
                output.text = "Level 3 : 18 checkpoints";
            }
            Level = val+1;
        }
    }

    public void SavePreferences()
    {
        DataPersistenceManager.instance.SaveGame();
    }
}
