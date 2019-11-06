Shader "Custom/My/9/AlphaTwoSideWithShadow"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Cutoff("Alpha Cutoff", Range(0,1)) = 1.0
	}
		SubShader
		{
			Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
			Pass{
				Tags{"LightMode" = "ForwardBase"}
				Cull Front

				  CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"
#include "AutoLight.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			float4 _MainTex_ST;
			half _Cutoff;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				i.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);

			float4 texColor = tex2D(_MainTex, i.uv);
			fixed3 albedo = texColor.rgb * _Color.rgb;
			clip(texColor.a - _Cutoff);

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + diffuse * atten, 1.0);
			}

			ENDCG
	}

			Pass{
				Tags{"LightMode" = "ForwardBase"}
				Cull Back

				  CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"
#include "AutoLight.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			float4 _MainTex_ST;
			half _Cutoff;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				i.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);

			float4 texColor = tex2D(_MainTex, i.uv);
			fixed3 albedo = texColor.rgb * _Color.rgb;
			clip(texColor.a - _Cutoff);

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + diffuse * atten, 1.0);
			}

			ENDCG
	}
		}
			FallBack "Transparent/Cutout/VertexLit"
}