using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBasePrac : MonoBehaviour
{
    private void Start()
    {
        if (!CheckResource())
        {
            enabled = false;
        }
    }

    private bool CheckResource()
    {
        if (SystemInfo.supportsImageEffects)
            return true;
        return false;
    }

    public Material CheckShaderAndCreateMaterial(Shader shader, Material mt)
    {
        if (shader == null || !shader.isSupported)
            return null;
        if (mt != null && mt.shader == shader)
        {
            return mt;
        }
        else
        {
            mt = new Material(shader);
            mt.hideFlags = HideFlags.DontSave;
            return mt;
        }
    }
}