Shader "Custom/My/12/EdgeDetectionTest"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_BackgroundColor("Background Color", Color) = (1,1,1,1)
		_EdgeOnly("Edge Only", Float) = 0.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass{
			/*Tags{"LightMode"="ForwardBase"}*/
			ZTest Always Cull Off ZWrite Off

			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
			//#include "Lighting.cginc"

					sampler2D _MainTex;
					float4 _MainTex_TexelSize;
					fixed4 _EdgeColor;
					fixed4 _BackgroundColor;
					float _EdgeOnly;

					struct a2v {
						float4 vertex:POSITION;
						float2 texcoord:TEXCOORD0;
					};
					struct v2f {
						float4 pos:SV_POSITION;
						float2 uv[9]:TEXCOORD0;
					};

					v2f vert(a2v v)
					{
						v2f i;
						i.pos = UnityObjectToClipPos(v.vertex);
						float2 uv = v.texcoord;
						i.uv[0] = uv + _MainTex_TexelSize.xy * float2(-1, -1);
						i.uv[1] = uv + _MainTex_TexelSize.xy * float2(0, -1);
						i.uv[2] = uv + _MainTex_TexelSize.xy * float2(1, -1);
						i.uv[3] = uv + _MainTex_TexelSize.xy * float2(-1, 0);
						i.uv[4] = uv + _MainTex_TexelSize.xy * float2(0, 0);
						i.uv[5] = uv + _MainTex_TexelSize.xy * float2(1, 0);
						i.uv[6] = uv + _MainTex_TexelSize.xy * float2(-1, 1);
						i.uv[7] = uv + _MainTex_TexelSize.xy * float2(0, 1);
						i.uv[8] = uv + _MainTex_TexelSize.xy * float2(1, 1);
						return i;
					}
					float lumination(fixed4 texColor)
					{
						return 0.2125 * texColor.r + 0.7154 * texColor.g + 0.0721 * texColor.b;
					}
					float Sobel(v2f i)
					{
						float Gx[9] = { -1,-2,-1,
										0,0,0,
										1,2,1 };
						float Gy[9] = { -1,0,1,
										-2,0,2,
										-1,0,1 };

						fixed lum;
						float edgeX = 0;
						float edgeY = 0;
						for (int j = 0; j < 9; j++)
						{
							lum = lumination(tex2D(_MainTex, i.uv[j]));
							edgeX += lum * Gx[j];
							edgeY += lum * Gy[j];
						}
						float edge = 1 - abs(edgeX) - abs(edgeY);
						return edge;
					}

					fixed4 frag(v2f i) :SV_Target
					{
						float edge = Sobel(i);
						fixed4 texColor = tex2D(_MainTex, i.uv[4]);
						fixed4 withEdgeColor = lerp(_EdgeColor, texColor, edge);
						fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
						return lerp(onlyEdgeColor, withEdgeColor, _EdgeOnly);
					}

					ENDCG
			}
		}
			FallBack Off
}