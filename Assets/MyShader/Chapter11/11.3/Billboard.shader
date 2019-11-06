﻿Shader "Custom/My/11/Billboard"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_VerticalBillboarding("Vertical Restraints", Range(0,1)) = 1
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

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
		half _VerticalBillboarding;
		fixed4 _Color;

		struct a2v {
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD0;
		};
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv:TEXCOORD0;
		};

		//这个上下翻转到180度时图片会反转，网上搜billboard可以搜到完美实现，应用场景星空
		v2f vert(a2v v)
		{
			v2f i;
			i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			float3 center = float3(0, 0, 0);
			float3 viewer = UnityWorldToObjectDir(_WorldSpaceCameraPos);

			float3 normalDir = viewer - center;
			normalDir.y = normalDir.y * _VerticalBillboarding;
			normalDir = normalize(normalDir);
			float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
			float3 rightDir = normalize(cross(upDir, normalDir));
			upDir = normalize(cross(normalDir, rightDir));
			float3 centerOffs = v.vertex.xyz - center;
			float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
			i.pos = UnityObjectToClipPos(float4(localPos, 1));
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