using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class NewBehaviourScript : MonoBehaviour
{
    private EventSystem enent;

    private void Start()
    {
    }

    // Update is called once per frame
    private void Update()
    {
        enent = EventSystem.current;
        if (enent.currentSelectedGameObject)
            print(enent.currentSelectedGameObject.name);
    }
}