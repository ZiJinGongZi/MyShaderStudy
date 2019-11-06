// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/My/9/ShaDow"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		Pass{
		Tags{ "LightMode" = "ForwardBase"}

		 CGPROGRAM
#pragma multi_compile_fwdbase
		#pragma vertex vert
		#pragma fragment frag
#include "Lighting.cginc"
		#include "AutoLight.cginc"

		fixed4 _Diffuse;
	fixed4 _Specular;
	float _Gloss;

	struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
		};
	struct v2f {
		float4 pos:SV_POSITION;
		fixed3 worldNormal : TEXCOORD0;
		float3 worldPos:TEXCOORD1;
		fixed3 worldView : TEXCOORD2;
		SHADOW_COORDS(3)
	};

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
		o.worldView = normalize(WorldSpaceViewDir(v.vertex));
		TRANSFER_SHADOW(o);
		return o;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed shadow = SHADOW_ATTENUATION(i);
		fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

	fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));

	fixed3 halfDir = normalize(i.worldView + worldLight);
	fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);

	fixed atten = 1.0;
	return fixed4(ambient + (diffuse + specular) * atten * shadow, 1.0);
	}

		ENDCG
}
	   Pass{
				Tags{ "LightMode" = "ForwardAdd"}
				Blend One One

		 CGPROGRAM
#pragma multi_compile_fwdadd
		#pragma vertex vert
		#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

		fixed4 _Diffuse;
	fixed4 _Specular;
	float _Gloss;

	struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
		};
	struct v2f {
		float4 pos:SV_POSITION;
		fixed3 worldNormal : TEXCOORD0;
		float3 worldPos:TEXCOORD1;
		fixed3 worldView : TEXCOORD2;
		SHADOW_COORDS(3)
	};

	v2f vert(a2v v) {
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
		o.worldView = normalize(WorldSpaceViewDir(v.vertex));
		TRANSFER_SHADOW(o);
		return o;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed shadow = SHADOW_ATTENUATION(i);
#ifdef USING_DIRECTIONAL_LIGHT
		fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
#else
		fixed3 worldLight = normalize(_WorldSpaceCameraPos.xyz - _WorldSpaceLightPos0.xyz);
#endif

		fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));

		fixed3 halfDir = normalize(i.worldView + worldLight);
		fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);

#ifdef USING_DIRECTIONAL_LIGHT
		fixed atten = 1.0;
#else
		float3 lightCoord = mul(unity_WorldToLight, i.worldPos);
		fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#endif
		return fixed4((diffuse + specular) * atten * shadow, 1.0);
	}
		ENDCG
}
	}
		FallBack "Specular"
}