using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class VolumeSlider : MonoBehaviour, IDataPersistence
{
    private Slider slider;
    private float volume;
    public TextMeshProUGUI numberText;
    // Start is called before the first frame update

    public void LoadData(GameData data)
    {
        // Load data when entering scene (DO NOT DELETE)
        this.volume = data.volume;
    }

    public void SaveData(GameData data)
    {
        data.volume = this.volume;
    }
    private void Start()
    {
        slider = GameObject.Find("VolumeSlider").GetComponent<Slider>();
        slider.value = volume;
    }
    public void SetNumberText(float v)
    {
        numberText.text = v.ToString();
        volume = v;
    }
}
