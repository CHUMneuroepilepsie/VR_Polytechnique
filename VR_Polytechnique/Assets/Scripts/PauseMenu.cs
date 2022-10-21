using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PauseMenu : MonoBehaviour, IDataPersistence
{
    // Start is called before the first frame update
    // Update is called once per frame
    public static bool GameIsPaused = false;
    public GameObject pauseMenuUI;
    private int NbPaused = 0;

    private void Start()
    {
        GameIsPaused = false;
        pauseMenuUI.SetActive(false);
    }

    public void LoadData(GameData data)
    {
        this.NbPaused = data.NbPaused; 
    }

    public void SaveData(ref GameData data)
    {
        data.NbPaused = this.NbPaused;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (GameIsPaused)
            {
                ResumeGame();
            }
            else
            {
                PauseGame(); 
            }
        }
    }

    public void ResumeGame()
    {
        PlayerPrefs.SetInt("TimerPaused", 0);
        pauseMenuUI.SetActive(false);
        Time.timeScale = 1f;
        GameIsPaused = false;
    }
    void PauseGame()
    {
        NbPaused++;
        PlayerPrefs.SetInt("TimerPaused", 1);
        pauseMenuUI.SetActive(true);
        Time.timeScale = 0f;
        GameIsPaused = true;
    }

    public void QuitGame()
    {
        SceneManager.LoadScene("Menu_Fin_" + PlayerPrefs.GetString("Language"));
    }
}