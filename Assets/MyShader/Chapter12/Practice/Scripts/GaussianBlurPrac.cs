using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlurPrac : PostEffectsBasePrac
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

    [Range(1, 8)]
    public int sampleDown = 1;

    [Range(0f, 6)]
    public float blurSpread = 1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            int rtW = source.width / sampleDown;
            int rtH = source.height / sampleDown;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0);

            RenderTexture buffer1 = null;
            for (int i = 0; i < iterations; i++)
            {
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                mt.SetFloat("_BlurSize", 1 + i * blurSpread);
                Graphics.Blit(buffer0, buffer1, Mt, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, Mt, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}