﻿Shader "Custom/My/11/ScrollingBackground"
{
	Properties
	{
		_MainTex("Base Layer (RGB)", 2D) = "white" {}
		_DetailTex("2nd Layer (RGB)", 2D) = "white" {}
		_ScrollX("Base Layer Scroll Speed", Float) = 1.0
		_Scroll2X("2nd Layer Scroll Speed", Float) = 1.0
		_Multiplier("Layer Multiplier", Float) = 1.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass{
				Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DetailTex;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Multiplier;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _DetailTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);
				//frac(x):
				//Returns the fractional (or decimal) part of x; which is greater than or equal to 0 and less than 1.
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 firstLayer = tex2D(_MainTex,i.uv.xy);
			fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
			fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
			c.rgb *= _Multiplier;
			return c;
			}

			ENDCG
	}
		}
			FallBack "Diffuse"
}