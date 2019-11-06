Shader "Custom/My/15/FogWithNoise"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_FogDensity("Fog Density",Float) = 1
	_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogStart("Fog Start",Float) = 0
		_FogEnd("Fog End",Float) = 1
		_NoiseTex("Noise Texture",2D) = "white" {}
	_FogXSpeed("Fog Horizontal Speed",Float) = 0.1
		_FogYSpeed("Fog Vertical Speed",Float) = 0.1
		_NoiseAmount("Noise Amount",Float) = 1
	}
		SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"
		float4x4 _FrustumCornersRay;
	sampler2D _MainTex;
	half4 _MainTex_TexelSize;
	sampler2D _CameraDepthTexture;
	half _FogDensity;
	fixed4 _FogColor;
	float _FogStart;
	float _FogEnd;
	sampler2D _NoiseTex;
	half _FogXSpeed;
	half _FogYSpeed;
	half _NoiseAmount;

	struct v2f {
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
		float2 uv_depth:TEXCOORD1;
		float4 interpolatedRay:TEXCOORD2;
	};

	v2f vert(appdata_img v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.uv = v.texcoord;
		i.uv_depth = v.texcoord;

			int index = 0;
		if (v.texcoord.x < 0.5&&v.texcoord.y < 0.5)
			index = 0;
		else if (v.texcoord.x > 0.5&&v.texcoord.y < 0.5)
			index = 1;
		else if (v.texcoord.x > 0.5&&v.texcoord.y > 0.5)
			index = 2;
		else if (v.texcoord.x<0.5&&v.texcoord.y>0.5)
			index = 3;

#if UNITY_UV_STARTS_AT_TOP
		if (_MainTex_TexelSize.y < 0)
		{
			i.uv.y = 1 - i.uv.y;
			index = 3 - index;
		}

#endif

		//按照解析的索引值得到需要传递的插值射线
		i.interpolatedRay = _FrustumCornersRay[index];

		return i;
	}
	fixed4 frag(v2f i) :SV_Target
	{
		float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
	float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

	float2 speed = _Time.y* float2(_FogXSpeed, _FogYSpeed);
	float noise = (tex2D(_NoiseTex, i.uv + speed).r - 0.5)*_NoiseAmount;

	//计算雾效系数，这里主要用的关于世界空间高度的线性雾计算
	float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
	fogDensity = saturate(fogDensity*_FogDensity*(1 + noise));

	fixed4 finalColor = tex2D(_MainTex,i.uv);
	finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

	return finalColor;
	}

		ENDCG

		Pass
	{
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag

			ENDCG
	}
	}
		FallBack Off
}