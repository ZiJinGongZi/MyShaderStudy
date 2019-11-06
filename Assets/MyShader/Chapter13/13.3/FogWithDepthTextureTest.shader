Shader "Custom/My/13/FogWithDepthTextureTest"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogDensity("Fog Density",Float) = 1
		_FogStart("Fog Start", Float) = 1
		_FogEnd("Fog End", Float) = 1.0
	}
		SubShader
		{
			CGINCLUDE
	#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			half _FogDensity;
			half _FogStart;
			half _FogEnd;
			fixed4 _FogColor;
			float4x4 _FrustumCornersRay;

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 frustumCorners:TEXCOORD1;
			};

			v2f vert(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = v.texcoord;
				i.uv.zw = v.texcoord;

				int index = 0;
				if (i.uv.x < 0.5 && i.uv.y < 0.5)
					index = 0;
				else if (i.uv.x > 0.5 && i.uv.y < 0.5)
					index = 1;
				else if (i.uv.x > 0.5 && i.uv.y > 0.5)
					index = 2;
				else
					index = 3;

	#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					i.uv.zw.y = 1 - i.uv.zw.y;

				index = 3 - index;
	#endif

				i.frustumCorners = _FrustumCornersRay[index];
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = _WorldSpaceCameraPos + SAMPLE_DEPTH_TEXTURE(_MainTex,i.uv.zw) * i.frustumCorners.xyz;
				float fogDensity = (_FogEnd - worldPos) / (_FogEnd - _FogStart);
				fogDensity = saturate(fogDensity * _FogDensity);

				fixed4 color = tex2D(_MainTex, i.uv.xy);
				fixed4 finalColor = lerp(_FogColor, color, fogDensity);
				return finalColor;
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