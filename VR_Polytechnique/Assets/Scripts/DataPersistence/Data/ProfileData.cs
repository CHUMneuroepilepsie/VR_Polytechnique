using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class ProfileData
{
    public string profileId;
    public List<EvaluationData> evaluationData;
    public ProfileData()
    {
        profileId = "";
        evaluationData = new List<EvaluationData>();
    }
}
