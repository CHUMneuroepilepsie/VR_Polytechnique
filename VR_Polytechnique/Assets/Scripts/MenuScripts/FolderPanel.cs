using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.EventSystems;

public class FolderPanel : MonoBehaviour
{
    public GameObject canvas;
    public GameObject button;
    public TextMeshProUGUI FolderpathName;
    public TextMeshProUGUI FolderName;

    string BasePath = "C:";
    int sceneCount = 0;

    List<string> activeButtons = new List<string>();


    private void Start()
    {
        sceneCount += 1;
        Debug.Log(sceneCount);
        if (sceneCount == 1)
        {
            PlayerPrefs.SetString("CSV_path", BasePath);
        }
        string path = PlayerPrefs.GetString("CSV_path");
        PlayerPrefs.SetString("Temp_CSV_path", path);
        FolderpathName.text = path;
        FolderName.text = path;
    }


    public void CreateButton()
    {
        string path = PlayerPrefs.GetString("Temp_CSV_path");
        var folders = Directory.EnumerateDirectories(path);
        foreach (string folder in folders)
        {
            string fileName = folder.Substring(path.Length + 1);
            activeButtons.Add(fileName);

            GameObject newButton = Instantiate(button) as GameObject;
            newButton.transform.SetParent(canvas.transform, false);
            newButton.GetComponentInChildren<TextMeshProUGUI>().text = fileName;
            newButton.name = fileName;
            Button folderButton = newButton.GetComponent<Button>();
            folderButton.onClick.AddListener(AddFolder);
        }
    }


    public void AddFolder()
    {
        GameObject clickedGameObject = EventSystem.current.currentSelectedGameObject;
        Button clickedButton = clickedGameObject.GetComponent<Button>();
        string clickedButtonName = clickedButton.GetComponentInChildren<TextMeshProUGUI>().text;
        string newfolderpath = PlayerPrefs.GetString("Temp_CSV_path") + Path.DirectorySeparatorChar + clickedButtonName;
        PlayerPrefs.SetString("Temp_CSV_path", newfolderpath);

        foreach (string activeButton in activeButtons)
        {
            Button buttonToDestroy = GameObject.Find(activeButton).GetComponent<Button>();
            Destroy(buttonToDestroy.gameObject);
        }

        activeButtons.RemoveRange(0, activeButtons.Count);

        CreateButton();

        FolderName.text = PlayerPrefs.GetString("Temp_CSV_path");
    }


    public void ChoosePath()
    {
        string path = PlayerPrefs.GetString("Temp_CSV_path");
        PlayerPrefs.SetString("CSV_path", path);
        FolderpathName.text = path;
    }
}