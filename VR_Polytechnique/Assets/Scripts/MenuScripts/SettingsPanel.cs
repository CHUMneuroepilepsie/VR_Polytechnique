using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System.Linq;
using UnityEngine.SceneManagement;

public class SettingsPanel : MonoBehaviour, IDataPersistence
{
    List<string> AvailableIds = new List<string>();
    private TextMeshProUGUI IdText;
    TextMeshProUGUI bText;
    public GameObject InputId;
    public GameObject backgroundText;
    public GameObject idInputField;

    public void LoadData(GameData data)
    {
        AvailableIds = data.AvailableIds;
    }

    public void SaveData(GameData data)
    {
        data.profileId = idInputField.GetComponent<TMP_InputField>().text;
    }

    void OnEnable()
    {
        // Security in case SettingsPanel was enabled on launch (which should not be the case in the builded game
        try
        {
            IdText = InputId.GetComponent<TextMeshProUGUI>();
            bText = backgroundText.GetComponent<TextMeshProUGUI>();
            bText.color = Color.black;
            IdText.color = Color.black;
        }
        catch
        {
            Debug.Log("Settings Menu should not be active on launch");
        }
    }

    public void LoadEvaluation()
    {
        //Id text uses invisble characters
        string Id = idInputField.GetComponent<TMP_InputField>().text;
        // Make sure they selected a profile Id
        if (Id.Length == 0)
        {
            bText.color = Color.red;
            IdText.color = Color.black;
            return;
        }
        else if (!AvailableIds.Contains(Id))
        {
            IdText.color = Color.red;
            bText.color = Color.black;
            return;
        }

        // If Id is selected
        Time.timeScale = 1f;
        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadScene("Mode_Evaluation");
    }
}
