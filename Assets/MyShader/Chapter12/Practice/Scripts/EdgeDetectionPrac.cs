using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectionPrac : PostEffectsBasePrac
{
    public Shader shader;
    private Material mt;

    private Material Mt
    {
        get
        {
            mt = CheckShaderAndCreateMaterial(shader, mt);
            return mt;
        }
    }

    [Range(0, 1)]
    public float edgeOnly = 0.5f;

    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetFloat("_EdgeOnly", edgeOnly);
            Mt.SetColor("_EdgeColor", edgeColor);
            Mt.SetColor("_BackgroundColor", backgroundColor);
            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}