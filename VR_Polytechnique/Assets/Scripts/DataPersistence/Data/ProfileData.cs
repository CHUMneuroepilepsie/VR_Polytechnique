using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ProfileData
{
    public string profileId;
    public string dateOfBirth;
    public string profileName;
    public List<EvaluationData> evaluationData;
    public ProfileData()
    {
        profileId = "";
        dateOfBirth = "";
        profileName = "";
        evaluationData = new List<EvaluationData>();
    }
}
