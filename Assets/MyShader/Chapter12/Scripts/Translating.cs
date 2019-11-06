using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Translating : MonoBehaviour
{
    public float speed = 2;
    public Vector3 start;
    public Vector3 end;
    public Transform target;
    private int a;

    private void Start()
    {
    }

    private void Update()
    {
        transform.LookAt(target);
        transform.position = Vector3.Slerp(transform.position, end, speed * Time.deltaTime);
        if (Vector3.Distance(transform.position, end) < 0.001f)
        {
            //transform.position = end;
            Vector3 temp = end;
            end = start;
            start = temp;
        }
    }
}