using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurPrac : PostEffectsBasePrac
{
    public Shader shader;
    private Material mt;

    [Range(0, 1)]
    public float motionAmount = 0.5f;

    [Range(1, 6)]
    public int downSample = 1;

    private Material Mt
    {
        get
        {
            mt = CheckShaderAndCreateMaterial(shader, mt);
            return mt;
        }
    }

    private RenderTexture tempTex;

    private void OnDestroy()
    {
        DestroyImmediate(tempTex);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            //if (tempTex == null || tempTex.width != source.width || tempTex.height != source.height)
            //{
            //    int rtW = source.width / downSample;
            //    int rtH = source.height / downSample;
            //    tempTex = new RenderTexture(rtW, rtH, 0);
            //    //tempTex.filterMode = FilterMode.Bilinear;
            //    tempTex.hideFlags = HideFlags.HideAndDontSave;
            //    //对tempTex进行初始化，没有这步也不会报错
            //    Graphics.Blit(source, tempTex);
            //}
            //tempTex.MarkRestoreExpected();

            Mt.SetFloat("_BlurAmount", 1 - motionAmount);
            //Graphics.Blit(source, tempTex, Mt);
            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}