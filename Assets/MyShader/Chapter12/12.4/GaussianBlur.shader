Shader "Custom/My/12/GaussianBlur"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BlurSize("Blur Size", Float) = 1
	}
		SubShader
		{
			CGINCLUDE
#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float _BlurSize;

			struct v2f {
				float4 pos:SV_POSITION;
				half2 uv[5]:TEXCOORD0;
			};

			v2f vertBlurVertical(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				half2 uv = v.texcoord;

				i.uv[0] = uv;
				i.uv[1] = uv + float2(0, _MainTex_TexelSize.y * 1)* _BlurSize;
				i.uv[2] = uv - float2(0, _MainTex_TexelSize.y * 1)*_BlurSize;
				i.uv[3] = uv + float2(0, _MainTex_TexelSize.y * 2)*_BlurSize;
				i.uv[4] = uv - float2(0, _MainTex_TexelSize.y * 2)*_BlurSize;
				return i;
			}
			v2f vertBlurHorizontal(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				half2 uv = v.texcoord;

				i.uv[0] = uv;
				i.uv[1] = uv + float2(_MainTex_TexelSize.x * 1, 0)* _BlurSize;
				i.uv[2] = uv - float2(_MainTex_TexelSize.x * 1, 0)*_BlurSize;
				i.uv[3] = uv + float2(_MainTex_TexelSize.x * 2, 0)*_BlurSize;
				i.uv[4] = uv - float2(_MainTex_TexelSize.x * 2, 0)*_BlurSize;
				return i;
			}
			fixed4 fragBlur(v2f i) :SV_Target
			{
				float weight[3] = {0.4026,0.2442,0.0545};

			fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
			for (int j = 1; j < 3; j++)
			{
				sum += tex2D(_MainTex, i.uv[j * 2 - 1]).rgb * weight[j];
				sum += tex2D(_MainTex, i.uv[2 * j]).rgb * weight[j];
			}

			/*sum += tex2D(_MainTex, i.uv[1]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[2]).rgb * weight[2];
			sum += tex2D(_MainTex, i.uv[3]).rgb * weight[1];
			sum += tex2D(_MainTex, i.uv[4]).rgb * weight[2];*/

			return fixed4(sum, 1);
			}
				ENDCG
				ZTest Always Cull Off ZWrite Off
			Pass {
				NAME "GAUSSIAN_BLUR_VERTICAL"
					CGPROGRAM
	#pragma vertex vertBlurVertical
	#pragma fragment fragBlur
					ENDCG
			}
			Pass{
				NAME "GAUSSIAN_BLUR_HORIZONTAL"
				CGPROGRAM
	#pragma vertex vertBlurHorizontal
	#pragma fragment fragBlur
				ENDCG
			}
		}
			FallBack "Diffuse"
}