﻿Shader "Custom/My/9/MyAlphaBlend"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump Map",2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_Gloss("Gloss", Range(8.0,256)) = 20
		_AlphaScale("Alpha Scale",Range(0,1.0)) = 1.0
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

			Pass
			{
				Tags{ "LightMode" = "ForwardBase"}
				Cull Front
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

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
		float _Gloss;
		fixed _AlphaScale;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 binormal = cross(worldTangent, worldNormal) * v.tangent.w;

				i.T2W0 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLight + viewDir);

				fixed3 bumpNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
				fixed3 bump = mul(rotation, bumpNormal);
				bump *= _BumpScale;

				float4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, worldLight));

				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				return fixed4(ambient + (diffuse + specular) * atten, texColor.a * _AlphaScale);
			}

			ENDCG
	}

			Pass
			{
				Tags{ "LightMode" = "ForwardBase"}
				Cull Back
				ZWrite Off
				Blend SrcAlpha OneMinusSrcAlpha

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
		float _Gloss;
		fixed _AlphaScale;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 binormal = cross(worldTangent, worldNormal) * v.tangent.w;

				i.T2W0 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLight + viewDir);

				fixed3 bumpNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
				fixed3 bump = mul(rotation, bumpNormal);
				bump *= _BumpScale;

				float4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, worldLight));

				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				return fixed4(ambient + (diffuse + specular) * atten, texColor.a * _AlphaScale);
			}

			ENDCG
	}

				Pass
			{
				Tags{ "LightMode" = "ForwardAdd"}
				Cull Front
				ZWrite Off
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
		float _Gloss;
		fixed _AlphaScale;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 binormal = cross(worldTangent, worldNormal) * v.tangent.w;

				i.T2W0 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLight + viewDir);

				fixed3 bumpNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
				fixed3 bump = mul(rotation, bumpNormal);
				bump *= _BumpScale;

				float4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, worldLight));

				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				return fixed4((diffuse + specular) * atten, texColor.a * _AlphaScale);
			}

			ENDCG
			}

				Pass
			{
				Tags{ "LightMode" = "ForwardAdd"}
				Cull Back
				ZWrite Off
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
		float _Gloss;
		fixed _AlphaScale;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 binormal = cross(worldTangent, worldNormal) * v.tangent.w;

				i.T2W0 = float4(worldTangent.x, binormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, binormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, binormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(i);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 halfDir = normalize(worldLight + viewDir);

				fixed3 bumpNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
				fixed3 bump = mul(rotation, bumpNormal);
				bump *= _BumpScale;

				float4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, worldLight));

				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				return fixed4((diffuse + specular) * atten, texColor.a * _AlphaScale);
			}

			ENDCG
			}
		}
			FallBack "Specular"
}