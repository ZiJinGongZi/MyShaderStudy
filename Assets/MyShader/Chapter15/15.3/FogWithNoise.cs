using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithNoise : PostEffectsBase
{
    public Shader fogShader;
    private Material fogMt;

    public Material material
    {
        get
        {
            fogMt = CheckShaderAndCreateMaterial(fogShader, fogMt);
            return fogMt;
        }
    }

    private Camera cam;

    public Camera myCamera
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

    private Transform myCameraTrans;

    public Transform cameraTrans
    {
        get
        {
            if (myCameraTrans == null)
            {
                myCameraTrans = myCamera.transform;
            }
            return myCameraTrans;
        }
    }

    [Range(0.1f, 3)]
    public float fogDensity = 1;

    public Color fogColor = Color.white;
    public float fogStart = 0;
    public float fogEnd = 2;
    public Texture noiseTexture;

    [Range(-0.5f, 0.5f)]
    public float fogXSpeed = 0.1f;

    [Range(-0.5f, 0.5f)]
    public float fogYSpeed = 0.1f;

    [Range(0, 3)]
    public float noiseAmount = 1;

    private void OnEnable()
    {
        myCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = myCamera.fieldOfView;
            float aspect = myCamera.aspect;
            float near = myCamera.nearClipPlane;

            float x = Mathf.Tan(fov / 2 * Mathf.Deg2Rad) * near;
            float y = aspect * x;

            Vector3 toUp = cameraTrans.up * x;
            Vector3 toRight = cameraTrans.right * y;

            Vector3 bottomLeft = (myCameraTrans.forward * near - toUp - toRight) / near;
            Vector3 bottomRight = (myCameraTrans.forward * near - toUp + toRight) / near;
            Vector3 topRight = (myCameraTrans.forward * near + toUp + toRight) / near;
            Vector3 topLeft = (myCameraTrans.forward * near + toUp - toRight) / near;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);

            material.SetFloat("_FogDensity", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);

            material.SetTexture("_NoiseTex", noiseTexture);
            material.SetFloat("_FogXSpeed", fogXSpeed);
            material.SetFloat("_FogYSpeed", fogYSpeed);
            material.SetFloat("_NoiseAmount", noiseAmount);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}