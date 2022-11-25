using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Linq;
using UnityEngine.SceneManagement;

public class SettingsPanel : MonoBehaviour, IDataPersistence
{
    List<string> AvailableIds = new List<string>();
    public TextMeshProUGUI Id;
    TextMeshProUGUI bText;
    public GameObject InputId;
    public GameObject backgroundText;

    public void LoadData(GameData data)
    {
        AvailableIds = data.AvailableIds;
    }

    public void SaveData(GameData data)
    {
        if (Id != null) {data.profileId = Id.text; }
    }

    void OnEnable()
    {
        // Security in case SettingsPanel was enabled on launch (which should not be the case in the builded game
        try
        {
            Id = InputId.GetComponent<TMPro.TextMeshProUGUI>();
            bText = backgroundText.GetComponent<TMPro.TextMeshProUGUI>();
            bText.color = Color.black;
            Id.color = Color.black;
        }
        catch
        {
            Debug.Log("Settings Menu should not be active on launch");
        }
    }

    public void LoadEvaluation()
    {
        // Make sure they selected a profile Id
        if (Id.text.Length == 1)
        {
            bText.color = Color.red;
            Id.color = Color.black;
            return;
        }
        else if (!AvailableIds.Contains(Id.text))
        {
            Id.color = Color.red;
            bText.color = Color.black;
            return;
        }

        // If Id is selected
        Time.timeScale = 1f;
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadScene("Mode_Evaluation");
    }
}
