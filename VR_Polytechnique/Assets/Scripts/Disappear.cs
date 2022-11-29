using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Disappear : MonoBehaviour
{
    public GameObject Cube;
    public GameObject Player;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    public void OnMouseDown()
    {
        if (Vector3.Distance(Cube.tranform.position, Player.tranform.position) < 2)
        {
            gameObject.SetActive(false);
        }
        
    }
}
