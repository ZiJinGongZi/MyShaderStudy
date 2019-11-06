using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationAndContrastTest : MyPostEffectBase
{
    public Shader shader;
    private Material mt;

    [Range(0, 3)]
    public float brightness = 1;

    [Range(0, 3)]
    public float saturation = 1;

    [Range(0, 3)]
    public float contrast = 1;

    public Material Mt
    {
        get
        {
            mt = CheckShaderAndCreateMaterial(shader, mt);
            return mt;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetFloat("_Brightness", brightness);
            Mt.SetFloat("_Saturation", saturation);
            Mt.SetFloat("_Contrast", contrast);
            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}