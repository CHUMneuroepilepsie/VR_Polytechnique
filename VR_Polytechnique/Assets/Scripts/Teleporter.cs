using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleporter : MonoBehaviour
{
    public GameObject Player;
    public GameObject TeleportTo;

    CharacterController Controller;

    void Start()
    {
        Controller = gameObject.GetComponent<CharacterController>();
    }
    private void OnTriggerEnter( Collider collision)
    {

        if (collision.gameObject.CompareTag("Teleporter")) 
        {
            // Teleportation of a moving object require us to stop his movement, teleporting him, then allowing him to move again.
            // Done by turning off/on his CharacterController component

            Controller.enabled = false;
            Player.transform.position = TeleportTo.transform.position;
            Controller.enabled = true;

            // Debug.Log("Teleportation");
        }
    }
}