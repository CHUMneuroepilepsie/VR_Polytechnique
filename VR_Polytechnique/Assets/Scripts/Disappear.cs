using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Disappear : MonoBehaviour
{
    public GameObject Player;
    public Transform Transform => transform;
    public GameObject text;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        RaycastHit hit;
        
       if (Vector3.Distance(Player.transform.position, Transform.position) <= 2)
        {
            if (Input.GetButtonDown("Fire1"))
            {
                if (Physics.Raycast(ray, out hit) && hit.collider.gameObject == gameObject)
                {
                    this.gameObject.SetActive(false);
                    text.SetActive(true);
                }
            }
           }
        
    }      
}
