using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepth : PostEffectsBase
{
    public Shader shader;
    private Material mt;

    public Material Mt
    {
        get
        {
            mt = CheckShaderAndCreateMaterial(shader, mt);
            return mt;
        }
    }

    [Range(0, 1)]
    public float edgesOnly = 0;

    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1;
    public float sensitivityDepth = 1;
    public float sensitivityNormals = 1;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetFloat("_EdgeOnly", edgesOnly);
            Mt.SetColor("_EdgeColor", edgeColor);
            Mt.SetColor("_BackgroundColor", backgroundColor);
            Mt.SetFloat("_SampleDistance", sampleDistance);
            Mt.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0, 0));
            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}