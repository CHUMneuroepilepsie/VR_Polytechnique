using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData 
{
    public int NbPaused;
    public float currentTime;
    public string Language;
    public float volume;
    public GameData()
    {
        NbPaused = 0;
        currentTime = 0;
        Language = "";
        volume = 50;
    }
}
