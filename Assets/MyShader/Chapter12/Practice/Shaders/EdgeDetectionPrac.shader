Shader "Custom/My/12/EdgeDetectionPrac"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,1,1,1)
		_BackgroungColor("Backgound Color",Color) = (1,1,1,1)
		_EdgeOnly("Edge Only",Range(0,1)) = 0.5
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			ZTest Always Cull Off ZWrite Off
			Pass
			{
				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			fixed4 _EdgeColor;
			fixed4 _BackgroungColor;
			fixed _EdgeOnly;

			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv[9]:TEXCOORD0;
			};

			v2f vert(appdata_img v)
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

			float liminance(fixed4 color)
			{
				return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
			}

			float sobel(v2f i)
			{
				float Gx[9] = { -1,-2,-1,
								0,0,0,
								1,2,1 };
				float Gy[9] = { -1,0,1,
								-2,0,2,
								-1,0,1 };

				float texColor;
				float sum_x = 0;
				float sum_y = 0;
				for (int it = 0; it < 9; it++)
				{
					texColor = liminance(tex2D(_MainTex, i.uv[it]));
					sum_x += texColor * Gx[it];
					sum_y += texColor * Gy[it];
				}
				float sobel = 1 - abs(sum_x) - abs(sum_y);
				return sobel;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 texColor = tex2D(_MainTex,i.uv[4]);
			float edge = sobel(i);
			fixed4 edgeColor = lerp(_EdgeColor, texColor, edge);
			fixed4 backgroundColor = lerp(_EdgeColor, _BackgroungColor, edge);
			fixed4 finalColor = lerp(edgeColor, backgroundColor, _EdgeOnly);
			return finalColor;
			}

			ENDCG
	}
		}
			FallBack Off
}