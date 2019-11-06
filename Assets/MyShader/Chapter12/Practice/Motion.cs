using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Motion : MonoBehaviour
{
    public float speed = 2;
    public Vector3 start;
    public Vector3 end;
    public Transform target;
    private Vector3 temp;

    private void Update()
    {
        transform.LookAt(target);
        transform.position = Vector3.Slerp(transform.position, end, speed);
        if (Vector3.Distance(transform.position, end) < 0.001f)
        {
            temp = end;
            end = start;
            start = temp;
        }
    }
}