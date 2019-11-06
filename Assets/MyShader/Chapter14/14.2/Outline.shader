Shader "Custom/My/14/Outline"
{
	Properties
	{
		_OutlineColor("Color", Color) = (1,1,1,1)
		_Outline("Outline", Float) = 0
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass
	{
		NAME "MYOUTLINE"
		Cull Front

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
#include "UnityCG.cginc"

		half _Outline;
		fixed4 _OutlineColor;

		struct a2v {
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};
		struct v2f {
			float4 pos:SV_POSITION;
		};

		v2f vert(a2v v)
		{
			v2f i;
			float4 pos = float4(UnityObjectToViewPos(v.vertex),1);
			fixed3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			normal.z = -0.5;
			pos += float4(normalize(normal),0) * _Outline;
			i.pos = mul(UNITY_MATRIX_P, pos);
			return i;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			return fixed4(_OutlineColor.rgb,1);
		}

		ENDCG
}
	}
		FallBack "Diffuse"
}