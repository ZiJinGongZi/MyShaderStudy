Shader "Custom/My/11/BillboardTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Restraints("Restraints", Range(0,1)) = 1
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			Pass{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
			#pragma vertex vert
				#pragma fragment frag
	#include "Lighting.cginc"

				sampler2D _MainTex;
			float4 _MainTex_ST;
				fixed _Restraints;
				fixed4 _Color;

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
					i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					float3 center = float3(0, 0, 0);
					float3 normal = UnityWorldToObjectDir(_WorldSpaceCameraPos) - center;
					normal.y *= _Restraints;
					normal = normalize(normal);
					float3 upDir = abs(normal.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
					fixed3 rightDir = normalize(cross(normal, upDir));
					upDir = normalize(cross(normal, rightDir));

					float3 offset = v.vertex.xyz - center;
					float3 pos = center + offset.x * rightDir + offset.y * upDir + offset.z * normal;
					i.pos = UnityObjectToClipPos(float4(pos, 1));
					return i;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					float4 color = tex2D(_MainTex,i.uv);
					color.rgb *= _Color.rgb;
					return color;
				}

				ENDCG
	}
		}
			FallBack "Transparent/VertexLit"
}