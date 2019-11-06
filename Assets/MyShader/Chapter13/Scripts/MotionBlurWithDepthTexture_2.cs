using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture_2 : PostEffectsBase
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

    private Camera cam;

    private Camera myCamera
    {
        get
        {
            if (cam == null)
                cam = GetComponent<Camera>();
            return cam;
        }
    }

    private Matrix4x4 worldToClipMatrix;
    private Matrix4x4 clipToWorldMatrix;
    private Matrix4x4 previousMatrix;

    [Range(0, 3)]
    public float blurSize = 1;

    private void OnEnable()
    {
        myCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetFloat("_BlurSize", blurSize);

            Mt.SetMatrix("_PreviousViewProjectionMatrix", previousMatrix);

            worldToClipMatrix = myCamera.projectionMatrix * myCamera.worldToCameraMatrix;
            clipToWorldMatrix = worldToClipMatrix.inverse;
            previousMatrix = worldToClipMatrix;
            Mt.SetMatrix("CurrentViewProjectionInverseMatrix", clipToWorldMatrix);

            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}