Shader "Custom/My/15/FogWithNoiseTest"
{
	Properties
	{
		_MainTex("Main Texture",2D) = "white" {}
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogDensity("Fog Density",Float) = 1
		_FogXSpeed("Fog Horizontal Speed",Float) = 0.1
		_FogYSpeed("Fog Vertical Speed",Float) = 0.1
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_FogStart("Fog Start", Float) = 0.5
		_FogEnd("Fog End", Float) = 0.5
		_FogAmount("Fog Amount",Float) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			fixed4 _FogColor;
			float _FogDensity;
			float _FogXSpeed;
			float _FogYSpeed;
			sampler2D _NoiseTex;
			half _FogStart;
			half _FogEnd;
			half _FogAmount;
			float4x4 _FrustumCornersRay;
			sampler2D _CameraDepthTexture;

			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float2 depth:TEXCOORD1;
				float4 interpolatedRay:TEXCOORD2;
			};

			v2f vert(appdata_base v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = v.texcoord;

				float index = 0;
				if (v.texcoord.x < 0.5 && v.texcoord.y > 0.5) {
					index = 0;
				}
				else if (v.texcoord.x > 0.5&&v.texcoord.y > 0.5) {
					index = 1;
				}
				else if (v.texcoord.x > 0.5&&v.texcoord.y < 0.5) {
					index = 2;
				}
				else if (v.texcoord.x < 0.5&&v.texcoord.y < 0.5) {
					index = 3;
				}

	#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					i.uv.y = 1 - i.uv.y;
					index = 3 - index;
				}

	#endif
				i.interpolatedRay = _FrustumCornersRay[index];

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.depth));
			float3 worldPos = _WorldSpaceCameraPos + i.interpolatedRay.xyz * depth;

			float2 speed = float2(_FogXSpeed, _FogYSpeed) * _Time.y;
			float noise = (tex2D(_NoiseTex, i.uv + speed).r - 0.5) * _FogAmount;

			float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
			fogDensity = saturate(fogDensity * fogDensity * (1 + noise));

			fixed3 finalColor = lerp(tex2D(_MainTex, i.uv).rgb, _FogColor.rgb, fogDensity);
			return fixed4(finalColor.rgb, 1);
			}

			ENDCG
	}
		}
			FallBack Off
}