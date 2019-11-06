﻿Shader "Custom/My/12/MotionBlur"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BlurAmount("Blur Amount", Float) = 1
	}
		SubShader
		{
			CGINCLUDE
#include "UnityCG.cginc"
			sampler2D _MainTex;
		fixed _BlurAmount;

		struct v2f {
			float4 pos:SV_POSITION;
			half2 uv:TEXCOORD0;
		};

		v2f vert(appdata_img v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv = v.texcoord;
			return i;
		}

		fixed4 fragRGB(v2f i) :SV_Target
		{
			return fixed4(tex2D(_MainTex,i.uv).rgb,_BlurAmount);
		}

			fixed4 fragA(v2f i) : SV_Target
		{
			return tex2D(_MainTex,i.uv);
		}

			ENDCG

			ZTest Always Cull Off ZWrite Off

			Pass {
			Blend SrcAlpha OneMinusSrcAlpha
				ColorMask RGB
				CGPROGRAM
#pragma vertex vert
#pragma fragment fragRGB
				ENDCG
		}

		Pass{
			Blend One One
			ColorMask A
			CGPROGRAM
#pragma vertex vert
#pragma fragment fragA
			ENDCG
		}
		}
			FallBack Off
}