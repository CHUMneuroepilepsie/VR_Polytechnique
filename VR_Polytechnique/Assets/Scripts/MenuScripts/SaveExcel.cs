using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using UnityEngine;

public class SaveExcel : MonoBehaviour
{
    string filepath = "C:\\Users\\lucas\\AppData\\LocalLow\\DefaultCompany\\My project\\422\\Evaluation_Results.json";
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public void SaveResults()
    {
        using (StreamReader r = new StreamReader(filepath))
        {
            string json = r.ReadToEnd();
            var obj = JsonConvert.DeserializeObject<JObject>(json);

            List<JsonData> dataList = GetDataList(obj);

            var fileName = file.Split('\\').Last().Split('.')[0].Trim().ToString();

            using (ExcelPackage excel = new ExcelPackage())
            {
                excel.Workbook.Worksheets.Add(fileName);

                var headerRow = new List<string[]>()
                        {
                                new string[] { "Key", "Value"}
                            };

                string headerRange = "A1:" + Char.ConvertFromUtf32(headerRow[0].Length + 64) + "1";

                var worksheet = excel.Workbook.Worksheets[fileName];

                worksheet.Cells[headerRange].LoadFromArrays(headerRow);

                worksheet.Cells[2, 1].LoadFromCollection(dataList);

                FileInfo excelFile = new FileInfo($"D:\\JsonFilesToExcel\\{folder}\\{fileName}.xlsx");
                excel.SaveAs(excelFile);
            }
        }
    }
}