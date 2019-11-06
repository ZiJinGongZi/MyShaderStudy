Shader "Custom/My/12/BloomPrac"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Bloom("Bloom",2D) = "white" {}
		_BlurSize("Blur Size",Float) = 1.0
		_LuminanceThreshold("Luminance Threshold",Float) = 0.5
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			CGINCLUDE
				#include"UnityCG.cginc"

			sampler2D _MainTex;
		float4 _MainTex_TexelSize;
			sampler2D _Bloom;
			half _BlurSize;
			half _LuminanceThreshold;

			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			half Luminance(fixed4 texColor)
			{
				return 0.2125 * texColor.r + 0.7154 * texColor.g + 0.0721 * texColor.b;
			}

			v2f vertExtractBright(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = v.texcoord;
				return i;
			}
			fixed4 fragExtractBright(v2f i) :SV_Target
			{
				fixed4 texColor = tex2D(_MainTex,i.uv);
			half luminance = Luminance(texColor);
			half c = clamp(luminance - _LuminanceThreshold, 0, 1);
			return texColor * c;
			}

				struct v2fBloom {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
			};

			v2fBloom vertBloom(appdata_img v)
			{
				v2fBloom i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = v.texcoord;
				i.uv.zw = v.texcoord;
	#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				i.uv.w = 1 - i.uv.w;
	#endif
				return i;
			}

			fixed4 fragBloom(v2fBloom i) :SV_Target
			{
				return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
			}

			ENDCG

				Pass {
				CGPROGRAM
	#pragma vertex vertExtractBright
	#pragma fragment fragExtractBright
				ENDCG
			}

			UsePass "Custom/GaussianBlurPrac/GAUSSIAN_BLUR_HORIZONTAL"
				UsePass "Custom/GaussianBlurPrac/GAUSSIAN_BLUR_VERTICAL"
				Pass{
				CGPROGRAM
				#pragma vertex vertBloom
	#pragma fragment fragBloom
				ENDCG
			}
		}
			FallBack Off
}