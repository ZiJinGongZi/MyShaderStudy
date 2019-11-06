// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My/10/Mirror"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
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

	struct a2v {
		float4 vertex:POSITION;
		float3 texcoord:TEXCOORD0;
	};
	struct v2f {
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
	};

	v2f vert(a2v v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.uv = v.texcoord;
		i.uv.x = 1 - i.uv.x;
		return i;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		return tex2D(_MainTex,i.uv);
	}

		ENDCG
}
	}
		FallBack Off
}