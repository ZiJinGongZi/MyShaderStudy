using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussianBlur : PostEffectsBase
{
    public Shader gaussianBlurShader;
    private Material gaussianBlurMt;

    public Material Mt
    {
        get
        {
            gaussianBlurMt = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMt);
            return gaussianBlurMt;
        }
    }

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    //private void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (Mt)
    //    {
    //        int rtW = source.width;
    //        int rtH = source.height;
    //        RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);

    //        Graphics.Blit(source, buffer, Mt, 0);

    //        Graphics.Blit(buffer, destination, Mt, 1);

    //        RenderTexture.ReleaseTemporary(buffer);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}

    //private void OnRenderImage(RenderTexture source, RenderTexture destination)
    //{
    //    if (Mt)
    //    {
    //        int rtW = source.width/downSample;
    //        int rtH = source.height/downSample;
    //        RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
    //        buffer.filterMode = FilterMode.Bilinear;

    //        Graphics.Blit(source, buffer, Mt, 0);

    //        Graphics.Blit(buffer, destination, Mt, 1);

    //        RenderTexture.ReleaseTemporary(buffer);
    //    }
    //    else
    //    {
    //        Graphics.Blit(source, destination);
    //    }
    //}

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0);
            RenderTexture buffer1 = null; ;
            for (int i = 0; i < iterations; i++)
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