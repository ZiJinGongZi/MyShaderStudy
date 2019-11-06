using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MyPostEffectBase : MonoBehaviour
{
    private void Start()
    {
        CheckResource();
    }

    private void CheckResource()
    {
        if (!CheckSupport())
        {
            enabled = false;
        }
    }

    private bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if (shader == null || !shader.isSupported)
            return null;
        if (material && shader == material.shader)
        {
            return material;
        }
        else
        {
            Material mt = new Material(shader);
            mt.hideFlags = HideFlags.DontSave;
            return mt;
        }
    }
}