using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Linq;
using System.IO;

public class ProfilePanel : MonoBehaviour, IDataPersistence
{
    [SerializeField] private Button[] buttons;
    [SerializeField] private Button forwardArrow;
    [SerializeField] private Button backArrow;

    private Button currentClickedButton;

    public GameObject AddProfileMenuUI;
    public GameObject RemoveProfileMenuUI;
    public TextMeshProUGUI IdText;
    public TextMeshProUGUI DateOfBirthText;
    public TextMeshProUGUI NameText;
    public GameObject EvalText1;
    public GameObject EvalText2;
    public GameObject EvalText3;
    public GameObject searchBar;
    public GameObject ModifyButton;
    public GameObject SaveButton;
    public GameObject IdModifyInput;
    public GameObject dateModifyInput;

    List<string> AvailableIds = new List<string>();
    private const int NBOPTIONS = 4;
    private int pageNb;
    private string Language;
    const string DEFAULT = "-----";
    private string fileName = "Evaluation_Results";
    private bool isModifyActive = false;
    public void LoadData(GameData data)
    {
       AvailableIds = data.AvailableIds;
       Language = data.Language;
    }

    public void SaveData(GameData data)
    {
       data.AvailableIds = AvailableIds.OrderByDescending(q => q).ToList();
    }

    void OnEnable()
    {
        // Security in case ProfilePanel was enabled on launch (which should not be the case in the builded game
        try
        {
            pageNb = 0;
            DataPersistenceManager.instance.LoadGame();
            LoadArrowsStatus();
            ShowIds();
            SaveButton.SetActive(false);
            ModifyButton.SetActive(false);
            IdModifyInput.SetActive(false);
            dateModifyInput.SetActive(false);
            if (Language == "Anglais")
            {
                ModifyButton.GetComponentInChildren<TextMeshProUGUI>().text = "Modify";
            }
            else
            {
                ModifyButton.GetComponentInChildren<TextMeshProUGUI>().text = "Modifier";
            }
        }
        catch
        {
            Debug.Log("Profile menu should not be active on launch");
        }

    }

    public void SetAllButtonsInteractable()
    {
        foreach (Button button in buttons)
        {
            button.interactable = true;
        }
    }
    public void OnButtonClicked(Button clickedButton)
    {
        int buttonIndex = System.Array.IndexOf(buttons, clickedButton);

        if (buttonIndex == -1)
            return;

        SetAllButtonsInteractable();
        clickedButton.interactable = false;
        currentClickedButton = clickedButton;

        ShowInformations();
    }

    public void OnForwardArrowClicked()
    {
        pageNb++;
        UpdatePanel();
    }

    public void OnBackArrowClicked()
    {
        pageNb--;
        UpdatePanel();
    }

    private void ShowIds()
    {
        int i = 0;
        foreach (Button button in buttons)
        {
            if (AvailableIds.Count > pageNb * NBOPTIONS + i)
            {
                button.GetComponentInChildren<TextMeshProUGUI>().text = AvailableIds[pageNb * NBOPTIONS + i];
            }
            else
            {
                button.GetComponentInChildren<TextMeshProUGUI>().text = DEFAULT;
            }
            i++;
        }
    }

    private void LoadArrowsStatus()
    {
        if (AvailableIds.Count <= (pageNb + 1) * NBOPTIONS)
        {
            forwardArrow.interactable = false;
        }
        else
        {
            forwardArrow.interactable = true;
        }
        if (pageNb == 0)
        {
            backArrow.interactable = false;
        }
        else
        {
            backArrow.interactable = true;
        }
    }

    private void ShowInformations()
    {
        if (currentClickedButton == null)
        {
            ResetInformation();
            return;
        }

        string profileId = currentClickedButton.GetComponentInChildren<TextMeshProUGUI>().text;
        if (currentClickedButton.interactable == true || profileId == DEFAULT)
        {
            ResetInformation();
            return;
        }

        FileDataHandler dataHandler = new FileDataHandler(Application.persistentDataPath, fileName);
        ProfileData pData = dataHandler.LoadProfile(profileId);

        IdText.text = pData.profileId;
        DateOfBirthText.text = pData.dateOfBirth;
        if (pData.profileName.Length == 1)
        {
            NameText.text = DEFAULT;
        }
        else
        {
            NameText.text = "******";
        }
        
        ModifyButton.SetActive(true);
        int i = pData.evaluationData.Count - 1;
        foreach (GameObject g in new List<GameObject> {EvalText1, EvalText2, EvalText3})
        {
            if (i < 0)
            {
                foreach (TextMeshProUGUI t in g.GetComponentsInChildren<TextMeshProUGUI>())
                {
                    t.text = DEFAULT;
                }
            }
            else
            {
                foreach (TextMeshProUGUI t in g.GetComponentsInChildren<TextMeshProUGUI>())
                {
                    if (t.gameObject.name.Substring(t.gameObject.name.Length - 4) == "Date")
                    {
                        t.text = pData.evaluationData[i].date;
                    }
                    else if (t.gameObject.name.Substring(t.gameObject.name.Length - 3) == "Lvl")
                    {
                        t.text = pData.evaluationData[i].lvl.ToString();
                    }
                    else if (t.gameObject.name.Substring(t.gameObject.name.Length - 4) == "Time")
                    {
                        t.text = pData.evaluationData[i].time;
                    }
                }
            }
            i--;
        }
    }

    private void ResetInformation()
    {
        ModifyButton.SetActive(false);
        foreach (TextMeshProUGUI t in new List<TextMeshProUGUI> {IdText, NameText, DateOfBirthText})
        {
            t.text = DEFAULT;
        }
        foreach(GameObject g in new List<GameObject> {EvalText1, EvalText2, EvalText3})
        {
            foreach(TextMeshProUGUI t in g.GetComponentsInChildren<TextMeshProUGUI>())
            {
                t.text = DEFAULT;
            }
        }
    }

    public void UpdatePanel()
    {
        LoadArrowsStatus();
        ShowIds();
        ShowInformations();
    }

    public void RemoveProfile()
    {
        string profileId = currentClickedButton.GetComponentInChildren<TextMeshProUGUI>().text;
        string fullPath = Path.Combine(Application.persistentDataPath, profileId);
        try
        {
            Directory.Delete(fullPath, true);
            AvailableIds.Remove(profileId);
        }
        catch
        {
            Debug.Log("This Id does not have a directory");
        }
        
        DataPersistenceManager.instance.SaveGame();
        DataPersistenceManager.instance.LoadGame();

        RemoveProfileMenuUI.SetActive(false);
        UpdatePanel();
    }

    public void SearchProfile()
    {
        string searchText = searchBar.GetComponent<TMP_InputField>().text;
        if (searchText.Length == 0) { LoadArrowsStatus(); }
        else
        {
            forwardArrow.interactable = false;
            backArrow.interactable = false;
        }
        List<string> listIds = AvailableIds.FindAll(FindProfile);
        int i = 0;
        foreach (Button button in buttons)
        {
            if (listIds.Count > i)
            {
                button.GetComponentInChildren<TextMeshProUGUI>().text = listIds[i];
            }
            else
            {
                button.GetComponentInChildren<TextMeshProUGUI>().text = DEFAULT;
            }
            i++;
        }
    }

    private bool FindProfile(string id)
    {
        string searchText = searchBar.GetComponent<TMP_InputField>().text;
        if (searchText.Length <= id.Length){
            return id.Substring(0, searchText.Length) == searchText;
        }
        return false;
    }


    public void ModifyProfile()
    {
        if (isModifyActive)
        {
            SaveButton.SetActive(false);
            IdModifyInput.SetActive(false);
            dateModifyInput.SetActive(false);
            if (Language == "Anglais")
            {
                ModifyButton.GetComponentInChildren<TextMeshProUGUI>().text = "Modify";
            }
            else
            {
                ModifyButton.GetComponentInChildren<TextMeshProUGUI>().text = "Modifier";
            }
            isModifyActive = false;
            return;
        }

        isModifyActive = true;
        if(Language == "Anglais")
        {
            ModifyButton.GetComponentInChildren<TextMeshProUGUI>().text = "Cancel";
        }
        else
        {
            ModifyButton.GetComponentInChildren<TextMeshProUGUI>().text = "Anuler";
        }

        SaveButton.SetActive(true);
        IdModifyInput.SetActive(true);
        dateModifyInput.SetActive(true);

        IdModifyInput.GetComponent<TMP_InputField>().text = IdText.text;
        dateModifyInput.GetComponent<TMP_InputField>().text = DateOfBirthText.text;
    }

    public void SaveModifications()
    {
        string new_id = IdModifyInput.GetComponent<TMP_InputField>().text;
        string new_date = dateModifyInput.GetComponent<TMP_InputField>().text;
        FileDataHandler dataHandler = new FileDataHandler(Application.persistentDataPath, fileName);
        ProfileData pData = dataHandler.LoadProfile(IdText.text);
        if (IdText.text != new_id)
        {
            RemoveProfile();
            AvailableIds.Add(new_id);
            DataPersistenceManager.instance.SaveGame();
            DataPersistenceManager.instance.LoadGame();
        }
        
        pData.profileId = new_id;
        pData.dateOfBirth = new_date;
        dataHandler.SaveEvaluation(pData);
        UpdatePanel();
        ModifyProfile();
    }

    public void OpenAddProileMenu()
    {
        AddProfileMenuUI.SetActive(true);
    }

    public void ExitAddProfileMenu()
    {
        AddProfileMenuUI.SetActive(false);
    }

    public void RemoveProfileWarning()
    {
        RemoveProfileMenuUI.SetActive(true);
    }

    public void ExitRemoveProfileWarning()
    {
        RemoveProfileMenuUI.SetActive(false);
    }
}
