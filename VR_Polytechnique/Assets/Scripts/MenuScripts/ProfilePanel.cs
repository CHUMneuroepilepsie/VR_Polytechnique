using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using UnityEngine.Rendering;

public class ProfilePanel : MonoBehaviour, IDataPersistence
{
    [SerializeField] private Button[] buttons;
    [SerializeField] private Button forwardArrow;
    [SerializeField] private Button backArrow;
    List<string> AvailableIds = new List<string>();
    private const int NBOPTIONS = 4;
    private int pageNb;
    private string Language;
    public GameObject AddProfileMenuUI;
    public GameObject RemoveProfileMenuUI;
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
            pageNb = 0;
            DataPersistenceManager.instance.LoadGame();
            LoadArrowsStatus();
            ShowIds();
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

        //TODO - Show information on the right side
    }

    public void OnForwardArrowClicked()
    {
        pageNb++;
        LoadArrowsStatus();
        ShowIds();
    }

    public void OnBackArrowClicked()
    {
        pageNb--;
        LoadArrowsStatus();
        ShowIds();
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
                if (Language == "Anglais")
                {
                    button.GetComponentInChildren<TextMeshProUGUI>().text = "Empty";
                }
                else
                {
                    button.GetComponentInChildren<TextMeshProUGUI>().text = "Vide";
                }
                
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

    //TODO - Remove a profile 
    public void RemoveProfile()
    {
        //TODO - Remove from directory

        //TODO - Remove from settings file

        DataPersistenceManager.instance.LoadGame();
        LoadArrowsStatus();
        ShowIds();
    }

    public void OpenAddProileMenu()
    {
        AddProfileMenuUI.SetActive(true);
    }

    public void ExitAddProfileMenu()
    {
        AddProfileMenuUI.SetActive(false);
        DataPersistenceManager.instance.LoadGame();
        LoadArrowsStatus();
        ShowIds();
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
