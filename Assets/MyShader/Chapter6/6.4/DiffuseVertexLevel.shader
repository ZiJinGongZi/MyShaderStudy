// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/My/6/DiffuseVertexLevel"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
	}
		SubShader
	{
			Pass{
			Tags { "LightMode" = "ForwardBase" }

		CGPROGRAM

		#pragma vertex vert

		#pragma fragment frag
#include "Lighting.cginc"
#include "UnityCG.cginc"

			fixed4 _Color;

			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(UnityObjectToWorldDir(v.normal));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb*_Color.rgb*saturate(dot(worldNormal, worldLight));
				o.color = ambient + diffuse;
				return o;
			}

			float4 frag(v2f o) :SV_Target
			{
				return fixed4(o.color, 1.0);
			}
			ENDCG
	}
	}
		FallBack "Diffuse"
}