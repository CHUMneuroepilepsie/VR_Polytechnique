using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class TextSlider : MonoBehaviour
{
    public TextMeshProUGUI numberText;
    private Slider slider;
    private float volume;

    private void Start()
    {
        volume = PlayerPrefs.GetFloat("Volume");
        slider = GetComponent<Slider>();
        slider.value = volume;
    }

    public void SetNumberText(float volume)
    {
        numberText.text = volume.ToString();
        PlayerPrefs.SetFloat("Volume", volume);
    }
}
