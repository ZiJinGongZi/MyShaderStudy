using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class RenderCubemapWizard : ScriptableWizard
{
    public Transform renderFromPosition;
    public Cubemap cubemap;

    private void OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderFromPosition != null) && (cubemap != null);
    }

    private void OnWizardCreate()
    {
        //创建一个用于渲染的临时摄像机
        GameObject go = new GameObject("CubemapCamera");
        Camera camera = go.AddComponent<Camera>();
        go.transform.position = renderFromPosition.position;
        //渲染到cube map
        camera.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }

    [MenuItem("GameObject/RenderIntoCubemap")]
    private static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>("Render cubemap", "Render!");
    }
}