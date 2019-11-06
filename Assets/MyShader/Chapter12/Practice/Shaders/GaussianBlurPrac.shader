Shader "Custom/My/12/GaussianBlurPrac"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_BlurSize("Blur Size",Float) = 1.0
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
ZTest Always Cull Off ZWrite Off
		CGINCLUDE
#include "UnityCG.cginc"

		sampler2D _MainTex;
	float4 _MainTex_TexelSize;
		half _BlurSize;

		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv[5]:TEXCOORD0;
		};

		v2f vertHorizontal(appdata_img v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv[0] = v.texcoord;
			i.uv[1] = v.texcoord + float2(_MainTex_TexelSize.x * 1, 0) * _BlurSize;
			i.uv[2] = v.texcoord - float2(_MainTex_TexelSize.x * 1, 0)* _BlurSize;
			i.uv[3] = v.texcoord + float2(_MainTex_TexelSize.x * 2, 0)* _BlurSize;
			i.uv[4] = v.texcoord - float2(_MainTex_TexelSize.x * 2, 0)* _BlurSize;
			return i;
		}
		v2f vertVertical(appdata_img v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv[0] = v.texcoord;
			i.uv[1] = v.texcoord + float2(0,_MainTex_TexelSize.x * 1)* _BlurSize;
			i.uv[2] = v.texcoord - float2(0,_MainTex_TexelSize.x * 1)* _BlurSize;
			i.uv[3] = v.texcoord + float2(0,_MainTex_TexelSize.x * 2)* _BlurSize;
			i.uv[4] = v.texcoord - float2(0,_MainTex_TexelSize.x * 2)* _BlurSize;
			return i;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			float weights[3] = {0.4026,0.2442f,0.0545};

		fixed3  sum = tex2D(_MainTex, i.uv[0]).rgb * weights[0];
		for (int j = 1; j < 3; j++)
		{
			sum += tex2D(_MainTex, i.uv[2 * j - 1]).rgb * weights[j];
			sum += tex2D(_MainTex, i.uv[2 * j]).rgb * weights[j];
		}
		return fixed4(sum, 1);
		}

			ENDCG

			Pass {
			NAME"GAUSSIAN_BLUR_HORIZONTAL"
			CGPROGRAM
#pragma vertex vertHorizontal
#pragma fragment frag
				ENDCG
		}
		Pass
		{
			NAME"GAUSSIAN_BLUR_VERTICAL"
			CGPROGRAM
#pragma vertex vertVertical
#pragma fragment frag
			ENDCG
		}
	}
		FallBack Off
}