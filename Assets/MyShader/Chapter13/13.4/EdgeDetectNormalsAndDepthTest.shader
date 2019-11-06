Shader "Custom/My/13/EdgeDetectNormalsAndDepthTest"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_BackgroundColor("Background Color", Color) = (1,1,1,1)
		_SampleDistance("Sample Distance",Float) = 1
		_EdgeOnly("Edge Only", Float) = 1
		_Sensitivity("Sensitivity", Float) = 1
	}
		SubShader
		{
			CGINCLUDE
	#include "UnityCG.cginc"

			sampler2D _MainTex;
		sampler2D _CameraDepthNormalsTexture;
		float4 _MainTex_TexelSize;
		fixed4 _EdgeColor;
		fixed4 _BackgroundColor;
			half _SampleDistance;
			half _EdgeOnly;
			float4 _Sensitivity;

			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv[5]:TEXCOORD0;
			};

			v2f vert(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				float2 uv = v.texcoord;

#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					uv.y = 1 - uv.y;
#endif

				i.uv[0] = uv;
				i.uv[1] = uv + _MainTex_TexelSize.xy * float2(-1, -1) * _SampleDistance;
				i.uv[2] = uv + _MainTex_TexelSize.xy * float2(1, 1) *  _SampleDistance;
				i.uv[3] = uv + _MainTex_TexelSize.xy * float2(1, -1) *  _SampleDistance;
				i.uv[4] = uv + _MainTex_TexelSize.xy * float2(-1, 1) *  _SampleDistance;

				return i;
			}

				float CheckSame(fixed4 color1, fixed4 color2)
				{
					float2 normal1 = color1.xy;
					float2 normal2 = color2.xy;
					//获取法线二维向量的差乘以灵敏度
					float2 diffNormal = abs(normal1 - normal2) * _Sensitivity.x;
					//原理是近似线段的模小于0.1
					float diffNor = abs(diffNormal.x) + abs(diffNormal.y) < 0.1 ? 1 : 0;

					float depth1 = DecodeFloatRG(color1.zw);
					float depth2 = DecodeFloatRG(color2.zw);
					//左边是深度值的差乘以灵敏度  右边是根据距离缩放了一下阈值
					float diffDepth = abs(depth1 - depth2)* _Sensitivity.y < 0.1 * depth1 ? 1 : 0;

					return diffNor * diffDepth;
				}

					fixed4 frag(v2f i) :SV_Target
					{
						half4 color1 = tex2D(_CameraDepthNormalsTexture,i.uv[1]);
						half4 color2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
						half4 color3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
						half4 color4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

						half4 edge = 1;
					edge *= CheckSame(color1, color2);
					edge *= CheckSame(color3, color4);

					fixed4 backgroundColor = tex2D(_MainTex, i.uv[0]);
					fixed4 edgeColor = lerp(_EdgeColor, backgroundColor, edge);
					fixed4 finalColor = lerp(_EdgeColor, _BackgroundColor, edge);
					return lerp(edgeColor, finalColor, _EdgeOnly);
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