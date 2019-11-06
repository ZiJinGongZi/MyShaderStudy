using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTextureTest : PostEffectsBase
{
    public Shader shader;
    private Material mt;

    private Material Mt
    {
        get
        {
            if (mt == null)
            {
                mt = CheckShaderAndCreateMaterial(shader, mt);
            }
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

    [Range(0, 6)]
    public float fogDensity = 0;

    public Color fogColor = Color.white;
    public float fogStart = 0;
    public float fogEnd = 1;

    private void OnEnable()
    {
        myCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;
            float fov = myCamera.fieldOfView;
            float depth = myCamera.depth;
            float aspect = myCamera.aspect;

            float height = Mathf.Tan(Mathf.Deg2Rad * fov * 0.5f) * depth;
            Vector3 up = height * myCamera.transform.up;
            Vector3 right = height * aspect * myCamera.transform.right;

            Vector3 topRight = myCamera.transform.forward * depth + up + right;
            topRight /= depth;

            Vector3 topLeft = myCamera.transform.forward * depth + up - right;
            topLeft /= depth;

            Vector3 bottomLeft = myCamera.transform.forward * depth + -up - right;
            bottomLeft /= depth;

            Vector3 bottomRight = myCamera.transform.forward * depth + right - up;
            bottomRight /= depth;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            Mt.SetMatrix("_FrustumCornersRay", frustumCorners);
            Mt.SetColor("_FogColor", fogColor);
            Mt.SetFloat("_FogStart", fogStart);
            Mt.SetFloat("_FogEnd", fogEnd);
            Mt.SetFloat("_FogDensity", fogDensity);

            Graphics.Blit(source, destination, Mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}