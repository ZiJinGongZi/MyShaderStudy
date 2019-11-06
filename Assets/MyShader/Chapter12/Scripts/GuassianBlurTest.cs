using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GuassianBlurTest : MyPostEffectBase
{
    public Shader shader;
    private Material mt;

    public Material Mt
    {
        get
        {
            return mt = CheckShaderAndCreateMaterial(shader, mt);
        }
    }

    [Range(0, 4)]
    public int interations = 2;

    [Range(0.2f, 3)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer0);

            RenderTexture buffer1 = null;
            for (int i = 0; i < interations; i++)
            {
                Mt.SetFloat("_BlurSize", 1 + i * blurSpread);
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
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