using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class MenuManager : MonoBehaviour, IDataPersistence
{
    [Header("Menu Buttons")]
    [SerializeField] private Button TutorialButton;
    [SerializeField] private Button SettingsButton;
    [SerializeField] private Button LanguageGameButton;
    [SerializeField] private Button QuitGameButton;

    private string Language;
    public GameObject SettingsMenuUI;
    public GameObject ProfileMenuUI;
    public GameObject FolderMenuUI;
    public GameObject FolderpathMenuUI;
    public GameObject AddProfileMenuUI;
    public GameObject RemoveProfileMenuUI;
    public IDataPersistence MENU;
    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
    }

    public void SaveData(GameData data)
    {
        data.Language = this.Language;
    }

    private void Start()
    {
        SettingsMenuUI.SetActive(false);
        ProfileMenuUI.SetActive(false);
        AddProfileMenuUI.SetActive(false);
        RemoveProfileMenuUI.SetActive(false);

        if (SceneManager.GetActiveScene().name == "Menu_Anglais")
        {
            Language = "Anglais";
        }
        else
        {
            Language = "Français";
        }
        DataPersistenceManager.instance.SaveGame();
    }


    public void ChangeMenu()
    {
        DisableMenuButtons();
        DataPersistenceManager.instance.SaveGame();
        if (Language == "Français")
        {
            Language = "Anglais";
            SceneManager.LoadSceneAsync("Menu_Anglais");
        }
        else
        {
            Language = "Français";
            SceneManager.LoadSceneAsync("Menu_Français");
        }
    }

    public void LoadTutorial()
    {
        DisableMenuButtons();
        // initialize game data
        Time.timeScale = 1f;

        DataPersistenceManager.instance.SaveGame();
        SceneManager.LoadSceneAsync("Mode_Apprentissage");
    }

    public void QuitGame()
    {
        DisableMenuButtons();
        DataPersistenceManager.instance.SaveGame();
        Application.Quit();
    }

    private void DisableMenuButtons()
    {
        TutorialButton.interactable = false;
        SettingsButton.interactable = false;
        LanguageGameButton.interactable = false;
        QuitGameButton.interactable = false;
    }

    public void EnterSettings()
    {
        DataPersistenceManager.instance.SaveGame();
        SettingsMenuUI.SetActive(true);
    }

    public void ExitSettings()
    {
        SettingsMenuUI.SetActive(false);
    }

    public void OpenProileMenu()
    {
        ProfileMenuUI.SetActive(true);
    }

    public void ExitProfileMenu()
    {
        ProfileMenuUI.SetActive(false);
    }

    public void OpenFolderMenu()
    {
        FolderMenuUI.SetActive(true);
    }

    public void ExitFolderMenu()
    {
        FolderMenuUI.SetActive(false);
    }

    public void OpenFolderpathMenu()
    {
        FolderpathMenuUI.SetActive(true);
    }

    public void ExitFolderpathMenu()
    {
        FolderpathMenuUI.SetActive(false);
    }
}