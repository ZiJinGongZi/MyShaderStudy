Shader "Custom/My/9/MyTangentSpaceSpecular"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_Gloss("Gloss", Range(8.0,256)) = 20
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
			fixed4 _Specular;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			half _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float4 tangent:TANGENT;
				float3 normal :NORMAL;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv : TEXCOORD0;
				fixed3 tangentLight : TEXCOORD1;
				fixed3 tangentViewDir : TEXCOORD2;
				float3 worldPos: TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));

				TANGENT_SPACE_ROTATION;
				i.tangentLight = normalize(mul(rotation, UnityWorldSpaceLightDir(i.worldPos)));
				i.tangentViewDir = normalize(mul(rotation, UnityWorldToViewPos(i.worldPos)));

				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 halfDir = normalize(i.tangentViewDir + i.tangentLight);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				tangentNormal *= _BumpScale;

				float4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(tangentNormal, i.tangentLight));

			fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}

			ENDCG
	}

			/*Pass
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
			fixed4 _Specular;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			half _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float4 tangent:TANGENT;
				float3 normal :NORMAL;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv : TEXCOORD0;
				fixed3 tangentLight : TEXCOORD1;
				fixed3 tangentViewDir : TEXCOORD2;
				float3 worldPos: TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));

				TANGENT_SPACE_ROTATION;
				i.tangentLight = normalize(mul(rotation, UnityWorldSpaceLightDir(i.worldPos)));
				i.tangentViewDir = normalize(mul(rotation, UnityWorldToViewPos(i.worldPos)));

				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 halfDir = normalize(i.tangentViewDir + i.tangentLight);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				tangentNormal *= _BumpScale;

				float4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(tangentNormal, i.tangentLight));

			fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}

			ENDCG
	}*/
		}
			FallBack "Specular"
}