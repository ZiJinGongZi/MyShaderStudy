using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomPrac : PostEffectsBasePrac
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

    [Range(0, 8)]
    public int iterations = 1;

    [Range(0, 8)]
    public float blurSpread = 1;

    [Range(1, 6)]
    public int downSample = 1;

    [Range(0, 1)]
    public float luminanceThreshold = 0.5f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetFloat("_LuminanceThreshold", luminanceThreshold);
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0, Mt, 0);
            RenderTexture buffer1 = null;

            for (int i = 0; i < iterations; i++)
            {
                Mt.SetFloat("_BlurSize", 1 + blurSpread * i);
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, Mt, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, Mt, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Mt.SetTexture("_Bloom", buffer0);
            RenderTexture.ReleaseTemporary(buffer0);
            Graphics.Blit(source, destination, Mt, 3);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}