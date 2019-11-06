using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AAA : MonoBehaviour
{
    private string[] values;

    private void Start()
    {
        KeyCode code = new KeyCode();
        values = System.Enum.GetNames(code.GetType());
    }

    // Update is called once per frame
    private void Update()
    {
        if (Input.anyKeyDown)
        {
            foreach (KeyCode keyCode in Enum.GetValues(typeof(KeyCode)))
            {
                if (Input.GetKeyDown(keyCode))
                {
                    Debug.Log("Current Key is : " + keyCode.ToString());
                }
            }
        }
    }
}