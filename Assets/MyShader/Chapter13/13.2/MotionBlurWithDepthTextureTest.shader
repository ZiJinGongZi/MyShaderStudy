Shader "Custom/My/13/MotionBlurWithDepthTextureTest"
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
			sampler2D _CameraDepthTexture;
			half _BlurSize;
			float4x4 _PreviousViewProjectionMatrix;
			float4x4 _CurrentViewProjectionInverseMatrix;
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
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv.zw);
			fixed4 viewPos = fixed4(i.uv.xy * 2 - 1, d * 2 - 1, 1);
			fixed4 worldPos = mul(_CurrentViewProjectionInverseMatrix, viewPos);
			worldPos = worldPos / worldPos.w;

			fixed4 previousViewPos = mul(_PreviousViewProjectionMatrix, worldPos);
			previousViewPos = previousViewPos / previousViewPos.w;
			float2 velocity = (viewPos.xy - previousViewPos.xy) / 2;
			float2 uv = i.uv.xy;
			fixed4 color = tex2D(_MainTex, uv);
			uv += _BlurSize * velocity;

			for (int j = 1; j < 3; j++, uv += _BlurSize * velocity)
			{
				color += tex2D(_MainTex, uv);
			}
			color /= 3;
			return fixed4(color.rgb, 1);
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