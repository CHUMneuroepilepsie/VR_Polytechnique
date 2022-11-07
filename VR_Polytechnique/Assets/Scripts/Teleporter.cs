using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleporter : MonoBehaviour
{
    private GameObject player;
    public GameObject teleportTo;
    CharacterController controller;
    private Checkpoint checkpoint;

    void Start()
    {
        controller = GameObject.FindWithTag("Player").GetComponent<CharacterController>();
        checkpoint = teleportTo.GetComponent<Checkpoint>();
        player = GameObject.FindWithTag("Player");
    }
    private void OnTriggerEnter( Collider collision)
    {

        if (collision.gameObject.CompareTag("Player"))
        {
            // Teleportation of a moving object require us to stop his movement, teleporting him, then allowing him to move again.
            // Done by turning off/on his CharacterController component

            controller.enabled = false;

            player.transform.position = teleportTo.transform.position;
            checkpoint.showmessage = true;

            controller.enabled = true;

        }
    }
}