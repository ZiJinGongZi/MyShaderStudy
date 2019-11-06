Shader "Custom/My/9/MyTangentSpaceBumpDiffuse"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
	#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v {
				float4 vertex:POSITION;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				fixed3 tangentLightDir : TEXCOORD1;
				float3 worldPos:TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				TANGENT_SPACE_ROTATION;

				i.tangentLightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
				TRANSFER_SHADOW(i);

				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
			tangentNormal = tangentNormal * _BumpScale;
			/*tangentNormal.xy = tangentNormal.xy * _BumpScale;
			tangentNormal.z = sqrt(1 - dot(tangentNormal.xy, tangentNormal.xy));*/

			fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(tangentNormal, i.tangentLightDir));

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			return fixed4(ambient + diffuse * atten,1.0);
		}

		ENDCG
}

		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One

			CGPROGRAM
#pragma multi_compile_fwdadd
		#pragma vertex vert
		#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

		fixed4 _Color;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpMap;
		float4 _BumpMap_ST;
		float _BumpScale;

		struct a2v {
			float4 vertex:POSITION;
			float4 tangent:TANGENT;
			float3 normal:NORMAL;
			float4 texcoord:TEXCOORD0;
		};
		struct v2f {
			float4 pos:SV_POSITION;
			float4 uv:TEXCOORD0;
			fixed3 tangentLightDir : TEXCOORD1;
			float3 worldPos:TEXCOORD2;
			SHADOW_COORDS(3)
		};

		v2f vert(a2v v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
			i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			TANGENT_SPACE_ROTATION;

			i.tangentLightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));
			TRANSFER_SHADOW(i);

			return i;
		}
		fixed4 frag(v2f i) :SV_Target
		{
			fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
		tangentNormal = tangentNormal * _BumpScale;
		/*tangentNormal.xy = tangentNormal.xy * _BumpScale;
		tangentNormal.z = sqrt(1 - dot(tangentNormal.xy, tangentNormal.xy));*/

			fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(tangentNormal, i.tangentLightDir));

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			return fixed4(diffuse * atten,1.0);
		}

		ENDCG
}
		}
			FallBack "Diffuse"
}