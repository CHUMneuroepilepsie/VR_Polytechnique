using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;


public class FileDataHandler
{
    private string dataDirPath = "";
    private string dataFilename = "";

    public FileDataHandler(string dataDirPath, string dataFilename)
    {
        this.dataDirPath = dataDirPath;
        this.dataFilename = dataFilename;
    }

    public GameData Load()
    {
        string fullPath = Path.Combine(dataDirPath, dataFilename);
        GameData loadedData = null;
        if (File.Exists(fullPath))
        {
            try
            {
                // Load the serialized data from file
                string dataToLoad = "";
                using (FileStream stream = new FileStream(fullPath, FileMode.Open))
                {
                    using (StreamReader reader = new StreamReader(stream))
                    {
                        dataToLoad = reader.ReadToEnd();
                    }
                }

                // deserialize the data from Json back into C# object
                loadedData = JsonUtility.FromJson<GameData>(dataToLoad);
            }
            catch (Exception e)
            { 
                Debug.LogError("Error occured when trying to load data to file: " + fullPath + "\n" + e);
            }
        }
        return loadedData;
    }

    public void Save(GameData data)
    {
        // Path.Combine() accounts for different type of OS
        string fullPath = Path.Combine(dataDirPath, dataFilename); 
        try
        {
            //Create directory if it doesn't exist
            Directory.CreateDirectory(Path.GetDirectoryName(fullPath));

            //serialize the C# game data object into Json
            string dataToStore = JsonUtility.ToJson(data, true);

            // write the seralized data to the file
            using (FileStream stream = new FileStream(fullPath, FileMode.Create))
            {
                using (StreamWriter writer = new StreamWriter(stream))
                {
                    writer.Write(dataToStore);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError("Error occured when trying to save data to file: " + fullPath + "\n" + e);
        }
    }

    public void SaveEvaluation(ProfileData data)
    {
        // Path.Combine() accounts for different type of OS
        string fullPath = Path.Combine(dataDirPath, data.profileId, dataFilename);
        try
        {
            //Create directory if it doesn't exist
            Directory.CreateDirectory(Path.GetDirectoryName(fullPath));

            //serialize the C# game data object into Json
            string dataToStore = JsonUtility.ToJson(data, true);

            // write the seralized data to the file
            using (FileStream stream = new FileStream(fullPath, FileMode.Create))
            {
                using (StreamWriter writer = new StreamWriter(stream))
                {
                    writer.Write(dataToStore);
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogError("Error occured when trying to save data to file: " + fullPath + "\n" + e);
        }
    }

    public ProfileData LoadProfile(string profileId)
    {
        string fullPath = Path.Combine(dataDirPath, profileId, dataFilename);
        ProfileData loadedData = null;
        if (File.Exists(fullPath))
        {
            try
            {
                // Load the serialized data from file
                string dataToLoad = "";
                using (FileStream stream = new FileStream(fullPath, FileMode.Open))
                {
                    using (StreamReader reader = new StreamReader(stream))
                    {
                        dataToLoad = reader.ReadToEnd();
                    }
                }

                // deserialize the data from Json back into C# object
                loadedData = JsonUtility.FromJson<ProfileData>(dataToLoad);
            }
            catch (Exception e)
            {
                Debug.LogError("Error occured when trying to load data to file: " + fullPath + "\n" + e);
            }
        }
        else
        {
            loadedData = new ProfileData() {profileId = profileId};
        }
        return loadedData;
    }

    public void SaveCSV(string profileId)
    {
        ProfileData loadedData = LoadProfile(profileId);
        string filepath = Path.Combine(dataDirPath, profileId, dataFilename + ".csv");

        StreamWriter tw = new StreamWriter(filepath, false);
        tw.Write("Profile ID;Date of birth;Name;Test;Date;Level;Time");

        //for (int i = 0; i < loadedData.evaluationData.Count; i++)
        //{
        //    tw.Write("Test " + (i+1).ToString() + " : Date;");
        //    tw.Write("Test " + (i+1).ToString() + " : Level;");
        //    tw.Write("Test " + (i+1).ToString() + " : Time;");
        //}
        
        tw.Write("\n");

        tw.Write(loadedData.profileId + ";" + loadedData.dateOfBirth + ";" + loadedData.profileName + ";");

        if (loadedData.evaluationData.Count > 0)
        {
            tw.Write("1;" + loadedData.evaluationData[0].date + ";" + loadedData.evaluationData[0].lvl + ";" + loadedData.evaluationData[0].time + ";");
            tw.Write("\n");
            for (int i = 1; i < loadedData.evaluationData.Count; i++)
            {
                tw.Write(";;;" + (i+1).ToString() + ";" + loadedData.evaluationData[i].date + ";" + loadedData.evaluationData[i].lvl + ";" + loadedData.evaluationData[i].time + ";");
                tw.Write("\n");
            }
        }

        tw.Close();
    }
}
