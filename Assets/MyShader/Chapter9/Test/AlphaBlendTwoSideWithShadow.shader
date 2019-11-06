Shader "Custom/My/9/AlphaBlendTwoSideWithShadow"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0,1)) = 0.5
	}
		SubShader
		{
				Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
				Pass
			{
				Tags { "LightMode" = "ForwardBase" }
				ZWrite Off
				Cull Front
				Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _AlphaScale;
			fixed4 _Color;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
			float4 texColor = tex2D(_MainTex, i.uv);
			fixed3 albedo = texColor.rgb * _Color.rgb;

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));
			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
			}

			ENDCG
	}

			Pass
			{
				Tags { "LightMode" = "ForwardBase" }
				ZWrite Off
				Cull Back
				Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _AlphaScale;
			fixed4 _Color;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
			float4 texColor = tex2D(_MainTex, i.uv);
			fixed3 albedo = texColor.rgb * _Color.rgb;

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));
			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + diffuse * atten, texColor.a * _AlphaScale);
			}

			ENDCG
	}
		}
			FallBack "VertexLit"
}