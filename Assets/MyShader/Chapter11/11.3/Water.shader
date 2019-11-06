﻿Shader "Custom/My/11/Water"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Magnitude("Distortion Magnitude", Float) = 1
		_Frequency("Distortion Frequency", Float) = 1
		_InvWaveLength("Distortion Inverse Wave Length", Float) = 10
		_Speed("Speed", Float) = 0.5
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}
				ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "Lighting.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	fixed4 _Color;
	float _Magnitude;
	float _Frequency;
	float _InvWaveLength;
	float _Speed;

	struct a2v {
		float4 vertex:POSITION;
		float2 texcoord:TEXCOORD0;
	};

	struct v2f {
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
	};

	v2f vert(a2v v)
	{
		v2f i;
		float4 offset;

		//这里的xyzw指的是模型坐标轴
		offset.yzw = float3(0, 0, 0);
		offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
		i.pos = UnityObjectToClipPos(v.vertex + offset);

		//这里的xy对应的是贴图的xy分量
		i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		i.uv += float2 (0,_Time.y * _Speed);

		return i;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed4 c = tex2D(_MainTex,i.uv);
	c.rgb *= _Color.rgb;

	return c;
	}

	ENDCG
}
		}
			FallBack "Transparent/VertexLit"
}