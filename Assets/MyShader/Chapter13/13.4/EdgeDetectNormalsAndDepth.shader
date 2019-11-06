Shader "Custom/My/13/EdgeDetectNormalsAndDepth"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_EdgeOnly("Edge Only", Float) = 1
		_EdgeColor("Edge Color", Color) = (0,0,0,1)
		_BackgroundColor("Background Color", Color) = (1,1,1,1)
		_SampleDistance("Sample Distance", Float) = 1.0
		_Sensitivity("Sensitivity",Vector) = (1,1,1,1)
	}
		SubShader
	{
		CGINCLUDE
#include "UnityCG.cginc"

		sampler2D _MainTex;
	half4 _MainTex_TexelSize;
	fixed _EdgeOnly;
	fixed4 _EdgeColor;
	fixed4 _BackgroundColor;
	float _SampleDistance;
	half4 _Sensitivity;
	sampler2D _CameraDepthNormalsTexture;

	struct v2f {
		float4 pos : SV_POSITION;
		half2 uv[5] : TEXCOORD0;
	};

	v2f vert(appdata_img v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		half2 uv = v.texcoord;
		i.uv[0] = uv;

#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
			uv.y = 1 - uv.y;
#endif

		i.uv[1] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _SampleDistance;
		i.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _SampleDistance;
		i.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDistance;
		i.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _SampleDistance;
		return i;
	}

	half CheckSame(half4 center, half4 sample)
	{
		half2 centerNormal = center.xy;
		float centerDepth = DecodeFloatRG(center.zw);
		half2 sampleNormal = sample.xy;
		float sampleDepth = DecodeFloatRG(sample.zw);

		//法线差异
		//不要费心解码法线——这里没有必要
		half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
		int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;

		//深度差异
		float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;

		//按距离缩放所需的阈值
		int isSameDepth = diffDepth < 0.1 * centerDepth;

		//返回：
		//1 -如果法线和深度足够相似
		//0 -否则
		return isSameNormal * isSameDepth ? 1 : 0;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		half4 sample1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
		half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
		half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
		half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

		half edge = 1;

		edge *= CheckSame(sample1, sample2);
		edge *= CheckSame(sample3, sample4);

		fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
		fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

		return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
	}

		ENDCG

		Pass
	{
		ZTest Always Cull Off ZWrite Off
			CGPROGRAM
#pragma vertex vert
#pragma fragment frag
			ENDCG
	}
	}
		FallBack Off
}