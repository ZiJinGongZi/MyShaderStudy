Shader "Custom/My/13/MotioBlurWithDepthTexture_2"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BlurSize("Blur Size",Float) = 1.0
	}
		SubShader
		{
			CGINCLUDE
	#include "UnityCG.cginc"

			sampler2D _MainTex;
			half _BlurSize;
			float4x4 _PreviousViewProjectionMatrix;
			float4x4 _CurrentViewProjectionMatrix;
			sampler2D _CameraDepthTexture;
			float4 _MainTex_TexelSize;

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
			};

			v2f vert(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = v.texcoord;
				i.uv.zw = v.texcoord;

	#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					i.uv.zw.y = 1 - i.uv.zw.y;
				}
	#endif
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float d = SAMPLE_DEPTH_TEXTURE(_MainTex,i.uv.zw);
			float4 D = float4(i.uv.xy * 2 - 1, d * 2 - 1, 1);
			float4 H = mul(_CurrentViewProjectionMatrix, D);
			float4 worldPos = H / H.w;

			float4 lastPos = mul(_PreviousViewProjectionMatrix, worldPos);
			lastPos = lastPos / lastPos.w;
			float2 speed = (D.xy - lastPos.xy) / 2;
			float2 uv = i.uv.xy;
			float4 c = tex2D(_MainTex, uv);
			uv += speed * _BlurSize;

			for (int j = 1; j < 3; j++, uv += speed * _BlurSize)
			{
				c += tex2D(_MainTex, uv);
			}
			c /= 3;
			return fixed4(c.rgb, 1.0);
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