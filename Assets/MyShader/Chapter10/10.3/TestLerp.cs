using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TestLerp : MonoBehaviour
{
    public float A;
    public float B;
    public float T;
    public float Result;

    private void Update()
    {
        Result = Mathf.Lerp(A, B, T);
    }
}