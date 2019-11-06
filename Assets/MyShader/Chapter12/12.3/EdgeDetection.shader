Shader "Custom/My/12/EdgeDetection"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_EdgeOnly("Edge Only",Float) = 1.0
		_EdgeColor("Color", Color) = (1,1,1,1)
		_BackgroundColor("Color", Color) = (1,1,1,1)
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass{
				ZTest Always Cull Off ZWrite Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment fragSobel

				sampler2D _MainTex;
			fixed4 _MainTex_TexelSize;
				float _EdgeOnly;
				fixed4 _EdgeColor;
				fixed4 _BackgroundColor;

				struct a2v {
					float4 vertex:POSITION;
					float2 texcoord:TEXCOORD0;
				};
				struct v2f {
					float4 pos:SV_POSITION;
					half2 uv[9]:TEXCOORD0;
				};

				v2f vert(a2v v)
				{
					v2f i;
					i.pos = UnityObjectToClipPos(v.vertex);

					half2 uv = v.texcoord;

					i.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
					i.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
					i.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
					i.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
					i.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
					i.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
					i.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
					i.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
					i.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
					return i;
				}

					fixed luminance(fixed4 color)
				{
					return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
				}

				half Sobel(v2f i)
				{
					const half Gx[9] = { -1,-2,-1,
										0,0,0,
										1,2,1 };
					const half Gy[9] = { -1,0,1,
										-2,0,2,
										-1,0,1 };

					half texColor;
					half edgeX = 0;
					half edgeY = 0;
					for (int it = 0; it < 9; it++)
					{
						texColor = luminance(tex2D(_MainTex, i.uv[it]));
						edgeX += texColor * Gx[it];
						edgeY += texColor * Gy[it];
					}
					half edge = 1 - abs(edgeX) - abs(edgeY);
					return edge;
				}
				fixed4 fragSobel(v2f i) :SV_Target
				{
					half edge = Sobel(i);
				fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
				fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
				return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
				}

				ENDCG
	}
		}
			FallBack Off
}