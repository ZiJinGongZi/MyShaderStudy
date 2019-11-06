Shader "Custom/My/8/AlphaBlendBothSide"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0,1)) = 0.5
	}
		SubShader
		{
			Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

			Pass
			{
				Tags { "LightMode" = "ForwardBase" }
				Cull Front
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
	#include "Lighting.cginc"

				sampler2D _MainTex;
			float4 _MainTex_ST;
				half _AlphaScale;
				fixed4 _Color;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float3 texcoord:TEXCOORD0;
				};
				struct v2f {
					float4 pos:SV_POSITION;
					float2 uv:TEXCOORD0;
					float3 worldNormal:TEXCOORD1;
					float3 worldLight:TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.worldLight = normalize(WorldSpaceLightDir(v.vertex));
					o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					return o;
				}
				fixed4 frag(v2f o) :SV_Target
				{
					float4 texColor = tex2D(_MainTex,o.uv);
					fixed3 albedo = texColor.rgb * _Color.rgb;

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = albedo * _LightColor0.rgb * (dot(o.worldNormal, o.worldLight)*0.5 + 0.5);
					return fixed4(ambient + diffuse, texColor.a*_AlphaScale);
				}

				ENDCG
			}
			Pass
			{
				Tags { "LightMode" = "ForwardBase" }
				Cull Back
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
	#include "Lighting.cginc"

				sampler2D _MainTex;
			float4 _MainTex_ST;
				half _AlphaScale;
				fixed4 _Color;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float3 texcoord:TEXCOORD0;
				};
				struct v2f {
					float4 pos:SV_POSITION;
					float2 uv:TEXCOORD0;
					float3 worldNormal:TEXCOORD1;
					float3 worldLight:TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.worldLight = normalize(WorldSpaceLightDir(v.vertex));
					o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					return o;
				}
				fixed4 frag(v2f o) :SV_Target
				{
					float4 texColor = tex2D(_MainTex,o.uv);
					fixed3 albedo = texColor.rgb * _Color.rgb;

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = albedo * _LightColor0.rgb * (dot(o.worldNormal, o.worldLight)*0.5 + 0.5);
					return fixed4(ambient + diffuse, texColor.a*_AlphaScale);
				}

				ENDCG
			}
		}
			FallBack "Transparent/VertexLit"
}