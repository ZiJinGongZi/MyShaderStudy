Shader "Custom/My/9/MyAlphaTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Specular("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump Map",2D) = "bump"{}
		_Gloss("Gloss", Range(8.0,256)) = 20
		_Cutoff("Alpha Cutoff", Range(0,1.0)) = 1.0
	}
		SubShader
		{
			Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}
				Cull Off
			/*ZWrite Off
		Cull Front
			Blend SrcAlpha OnMinusSrcAlpha*/

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
	float _Gloss;
	fixed _Cutoff;

	struct a2v {
		float4 vertex:POSITION;
		float4 tangent:TANGENT;
		float3 normal:NORMAL;
		float2 texcoord:TEXCOORD0;
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
		float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
		fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
		fixed3 viewDir = normalize(UnityWorldToViewPos(worldPos));
		fixed3 halfDir = normalize(worldLight + viewDir);

		fixed3 worldNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
		float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
		worldNormal = mul(rotation, worldNormal);

		fixed4 texColor = tex2D(_MainTex, i.uv.xy);
		fixed3 albedo = texColor.rgb * _Color.rgb;
		clip(texColor.a - _Cutoff);

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

	fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(worldNormal, worldLight));

	fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

	UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

	return fixed4(ambient + (diffuse + specular) * atten, 1.0);
	}

	ENDCG
}
Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Cull Off
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
	float _Gloss;
	fixed _Cutoff;

	struct a2v {
		float4 vertex:POSITION;
		float4 tangent:TANGENT;
		float3 normal:NORMAL;
		float2 texcoord:TEXCOORD0;
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
		float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);
		fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldPos));
		fixed3 viewDir = normalize(UnityWorldToViewPos(worldPos));
		fixed3 halfDir = normalize(worldLight + viewDir);

		fixed3 worldNormal = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
		float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
		worldNormal = mul(rotation, worldNormal);

		fixed4 texColor = tex2D(_MainTex, i.uv.xy);
		fixed3 albedo = texColor.rgb * _Color.rgb;
		clip(texColor.a - _Cutoff);

	fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(worldNormal, worldLight));

	fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

	UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

	return fixed4((diffuse + specular) * atten, 1.0);
	}

ENDCG
		}
		}

			FallBack "Transparent/Cutout/VertexLit"
}