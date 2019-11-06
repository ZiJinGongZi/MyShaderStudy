// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/My/9/AttenuationAndShadowUseBuildInFunctions"
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

		Pass
		{
	Tags{"LightMode" = "ForwardBase"}

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
		SHADOW_COORDS(2)
		};

	v2f vert(a2v v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
		i.worldNormal = UnityObjectToWorldNormal(v.normal);
		TRANSFER_SHADOW(i);
		return i;
	}
	fixed4 frag(v2f i) :SV_Target
	{
		fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

		fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));

		fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		fixed halfDir = normalize(worldLight + viewDir);
		fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);

		/*float shadow = SHADOW_ATTENUATION(i);
		fixed atten = 1.0;*/
		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

		return fixed4(ambient + (diffuse + specular) * atten, 1.0);
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
		SHADOW_COORDS(2)
		};

	v2f vert(a2v v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
		i.worldNormal = UnityObjectToWorldNormal(v.normal);
		TRANSFER_SHADOW(i);
		return i;
	}
	fixed4 frag(v2f i) :SV_Target
	{
#ifdef USING_DIRECTIONAL_LIGHT
		fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
#else
		fixed3 worldLight = normalize(_WorldSpaceCameraPos.xyz - _WorldSpaceLightPos0.xyz);
#endif

		fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));

		fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		fixed halfDir = normalize(worldLight + viewDir);
		fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(i.worldNormal, halfDir)), _Gloss);

		/*float shadow = SHADOW_ATTENUATION(i);

		#ifdef USING_DIRECTIONAL_LIGHT
		fixed atten = 1.0;
		#else
				float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos,1.0)).xyz;
				fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
		#endif*/

		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

						return fixed4((diffuse + specular) * atten, 1.0);
					}

							ENDCG
					}
	}
		FallBack "Specular"
}