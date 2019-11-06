using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepthTest : PostEffectsBase
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

    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    [Range(0, 1)]
    public float edgeOnly = 1;

    public float sampleDistance = 1;
    public float edgeNormals = 1;
    public float edgeDepth = 1;

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetColor("_EdgeColor", edgeColor);
            Mt.SetColor("_BackgroundColor", backgroundColor);
            Mt.SetFloat("_EdgeOnly", edgeOnly);
            Mt.SetFloat("_SampleDistance", sampleDistance);
            Mt.SetVector("_Sensitivity", new Vector4(edgeNormals, edgeDepth, 0, 0));
            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}