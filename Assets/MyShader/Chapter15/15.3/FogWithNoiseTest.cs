using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithNoiseTest : PostEffectsBase
{
    public Shader shader;
    private Material myMt;

    private Material mt
    {
        get
        {
            myMt = CheckShaderAndCreateMaterial(shader, myMt);
            return myMt;
        }
    }

    public Color fogColor;

    [Range(0, 1)]
    public float fogDensity;

    [Range(-1, 1)]
    public float xSpeed;

    [Range(-1, 1)]
    public float ySpeed;

    public Texture noiseTex;

    [Range(0, 5)]
    public float fogAmount;

    public float fogStart;
    public float fogEnd;

    private Camera myCam;

    private Camera cam
    {
        get
        {
            if (myCam == null)
                myCam = GetComponent<Camera>();
            return myCam;
        }
    }

    private Transform myCamTrans;

    private Transform camTrans
    {
        get
        {
            return cam.transform;
        }
    }

    private void OnEnable()
    {
        cam.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (mt)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = cam.fieldOfView;
            float aspect = cam.aspect;
            float near = cam.nearClipPlane;

            float x = Mathf.Tan(fov / 2 * Mathf.Deg2Rad) * near;
            float y = x * aspect;
            Vector3 top = camTrans.up * y;
            Vector3 right = camTrans.right * x;

            Vector3 topLeft = (camTrans.forward * near - right + top) / near;
            Vector3 topRight = (camTrans.forward * near + right + top) / near;
            Vector3 bottomRight = (camTrans.forward * near + right - top) / near;
            Vector3 bottomLeft = (camTrans.forward * near - right - top) / near;

            frustumCorners.SetRow(0, topLeft);
            frustumCorners.SetRow(1, topRight);
            frustumCorners.SetRow(2, bottomRight);
            frustumCorners.SetRow(3, bottomLeft);
            mt.SetMatrix("_FrustumCornersRay", frustumCorners);

            mt.SetColor("_FogColor", fogColor);
            mt.SetFloat("_FogDensity", fogDensity);
            mt.SetFloat("_FogXSpeed", xSpeed);
            mt.SetFloat("_FogYSpeed", ySpeed);
            mt.SetFloat("_FogAmount", fogAmount);
            mt.SetFloat("_FogStart", fogStart);
            mt.SetFloat("_FogEnd", fogEnd);
            mt.SetTexture("_NoiseTex", noiseTex);

            Graphics.Blit(source, destination, mt);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}