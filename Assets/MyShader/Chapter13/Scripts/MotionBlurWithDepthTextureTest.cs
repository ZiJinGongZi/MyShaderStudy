using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTextureTest : MyPostEffectBase
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
            {
                cam = GetComponent<Camera>();
            }
            return cam;
        }
    }

    private void OnEnable()
    {
        myCamera.depthTextureMode |= DepthTextureMode.Depth;
    }

    [Range(0, 3)]
    public float blurSize = 1;

    private Matrix4x4 viewToWorldMatrix;
    private Matrix4x4 worldToViewMatrix;
    private Matrix4x4 lastMatrix;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Mt.SetMatrix("_PreviousViewProjectionMatrix", lastMatrix);
            worldToViewMatrix = myCamera.worldToCameraMatrix * myCamera.projectionMatrix;
            viewToWorldMatrix = worldToViewMatrix.inverse;
            Mt.SetMatrix("_CurrentViewProjectionInverseMatrix", viewToWorldMatrix);
            lastMatrix = worldToViewMatrix;
            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}