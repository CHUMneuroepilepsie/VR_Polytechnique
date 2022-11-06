using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData 
{
    public float currentTime;
    public string Language;
    public float volume;
    public int Level;

    public GameData()
    {
        currentTime = 0;
        Language = "";
        volume = 50;
        Level = 1;
    }
}
