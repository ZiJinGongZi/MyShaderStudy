Shader "Custom/Specular"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_SpecularColor("Specular Color" ,Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_BumpTex("Normal Texture", 2D) = "bump" {}
	_BumpScale("Normal Scale" , Range(0,1)) = 1
		_Glossiness("Glossiness", Range(1,256)) = 20
		_GlossinessIntensity("Glossiness Intensity",Float) = 1
		_Fresnel("Fresnel",Float) = 0
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fwdbase
		#include "AutoLight.cginc"
		#include "Lighting.cginc"

				half _Metallic;
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpTex;
				float4 _BumpTex_ST;
				half _BumpScale;
				fixed4 _SpecularColor;
				half _Glossiness;
				half _GlossinessIntensity;
				half _Fresnel;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;
				};
				struct v2f {
					float4 pos : SV_POSITION;
					float4 uv:TEXCOORD0;
					float4 T2W0:TEXCOORD1;
					float4 T2W1:TEXCOORD2;
					float4 T2W2:TEXCOORD3;
					SHADOW_COORDS(4)
					UNITY_FOG_COORDS(5)
				};

				v2f vert(a2v v)
				{
					v2f i;
					i.pos = UnityObjectToClipPos(v.vertex);
					i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					float3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
					float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

					i.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
					i.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
					i.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

					TRANSFER_SHADOW(i);
					UNITY_TRANSFER_FOG(i, i.pos);
					return i;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
					fixed3 worldNormal = fixed3(i.T2W0.z, i.T2W1.z, i.T2W2.z);

					fixed3 bump = UnpackNormalWithScale(tex2D(_BumpTex, i.uv.zw),_BumpScale);
					//bump *= _BumpScale;
					bump = normalize(float3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));

					UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

					fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, worldLightDir));

					fixed3 halfDir = normalize(worldViewDir + worldLightDir);
					fixed3 specular = _SpecularColor.rgb * _LightColor0.rgb *pow(saturate(dot(bump, halfDir)), _Glossiness);

					half fresnel = _Fresnel + (1 + _Fresnel)*(1 - dot(worldViewDir, bump));

					fixed3 finalColor = ambient + (diffuse + specular * saturate(fresnel)*_GlossinessIntensity)*atten;
					//return fixed4(ambient + (diffuse + specular)*atten, 1);
					return fixed4(finalColor, 1);
				}

				ENDCG
		}
			Pass
		{
			Tags{"LightMode" = "ForwardAdd"}

			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fwdadd
		#include "AutoLight.cginc"
		#include "Lighting.cginc"

				half _Metallic;
				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpTex;
				float4 _BumpTex_ST;
				half _BumpScale;
				fixed4 _SpecularColor;
				half _Glossiness;
				half _GlossinessIntensity;
				half _Fresnel;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;
				};
				struct v2f {
					float4 pos : SV_POSITION;
					float4 uv:TEXCOORD0;
					float4 T2W0:TEXCOORD1;
					float4 T2W1:TEXCOORD2;
					float4 T2W2:TEXCOORD3;
				};

				v2f vert(a2v v)
				{
					v2f i;
					i.pos = UnityObjectToClipPos(v.vertex);
					i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					float3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
					float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
					float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

					i.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
					i.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
					i.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

					return i;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
					fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
					fixed3 worldNormal = fixed3(i.T2W0.z, i.T2W1.z, i.T2W2.z);

					fixed3 bump = UnpackNormalWithScale(tex2D(_BumpTex, i.uv.zw),_BumpScale);
					bump = normalize(float3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));

					UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

					fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

					fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, worldLightDir));

					fixed3 halfDir = normalize(worldViewDir + worldLightDir);
					fixed3 specular = _SpecularColor.rgb * _LightColor0.rgb *pow(saturate(dot(bump, halfDir)), _Glossiness);

					half fresnel = _Fresnel + (1 + _Fresnel)*(1 - dot(worldViewDir, bump));

					fixed3 finalColor = (diffuse + specular * saturate(fresnel)*_GlossinessIntensity)*atten;
					return fixed4(finalColor, 1);
				}

				ENDCG
		}
	}
		FallBack "Diffuse"
}