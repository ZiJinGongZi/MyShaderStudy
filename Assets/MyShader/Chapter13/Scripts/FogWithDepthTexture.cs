using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture : PostEffectsBase
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

    private Transform camTransform;

    private Transform cameraTransform
    {
        get
        {
            if (camTransform == null)
            {
                camTransform = myCamera.transform;
            }
            return camTransform;
        }
    }

    [Range(0, 3)]
    public float fogDensity = 1;//密度

    public Color fogColor = Color.white;
    public float fogStart = 0;//起始高度
    public float fogEnd = 2;//终止高度

    private void OnEnable()
    {
        myCamera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (Mt)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = myCamera.fieldOfView;
            float near = myCamera.nearClipPlane;
            //float far = myCamera.farClipPlane;
            float aspect = myCamera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = cameraTransform.right * halfHeight * aspect;
            Vector3 toTop = cameraTransform.up * halfHeight;

            Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            topLeft.Normalize();
            topLeft *= scale;

            Vector3 topRight = cameraTransform.forward * near + toRight + toTop;
            topRight.Normalize();
            topRight *= scale;
            #region
            Vector3 bottomLeft = cameraTransform.forward * near - toTop - toRight;
            bottomLeft.Normalize();
            bottomLeft *= scale;

            Vector3 bottomRight = cameraTransform.forward * near + toRight - toTop;
            bottomRight.Normalize();
            bottomRight *= scale;

            frustumCorners.SetRow(0, bottomLeft);
            frustumCorners.SetRow(1, bottomRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            Mt.SetMatrix("_FrustumCornersRay", frustumCorners);
            //Mt.SetMatrix("_ViewProjectionInverseMatrix", (myCamera.projectionMatrix * myCamera.worldToCameraMatrix).inverse);

            Mt.SetFloat("_FogDensity", fogDensity);
            Mt.SetColor("_FogColor", fogColor);
            Mt.SetFloat("_FogStart", fogStart);
            Mt.SetFloat("_FogEnd", fogEnd);

            Graphics.Blit(source, destination, Mt);
            #endregion
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}