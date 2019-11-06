Shader "Custom/My/10/Refraction"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_RefractColor("Refraction Color" ,Color) = (1,1,1,1)
		_RefractAmount("Refraction Amount" ,Range(0,1)) = 1
		_RefractRatio("Refraction Retio" ,Range(0.1,1)) = 0.5
		_Cubemap("Refraction Cubemap" ,Cube) = "_Skybox"{}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass{
		Tags{ "LightMode" = "ForwardBase"}

			CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

		fixed4 _Color;
	fixed4 _RefractColor;
	fixed _RefractAmount;
	fixed _RefractRatio;
	samplerCUBE _Cubemap;

	struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
	};
	struct v2f {
		float4 pos:SV_POSITION;
		fixed3 worldNormal : TEXCOORD0;
		fixed3 worldRefraction : TEXCOORD1;
		float3 worldPos:TEXCOORD2;
		SHADOW_COORDS(3)
	};

	v2f vert(a2v v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.worldNormal = UnityObjectToWorldNormal(v.normal);
		i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		float3 viewDir = UnityWorldSpaceViewDir(i.worldPos);
		i.worldRefraction = refract(-normalize(viewDir), i.worldNormal, _RefractRatio);
		TRANSFER_SHADOW(i);
		return i;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed3 diffuse = _Color.rgb * _LightColor0.rgb *saturate(dot(i.worldNormal, worldLightDir));
		fixed3 refract = texCUBE(_Cubemap, i.worldRefraction);
		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
		fixed3 color = ambient + lerp(diffuse, refract, _RefractAmount) *atten;
		return fixed4(color, 1.0);
	}

		ENDCG
}
	}
		FallBack "Refrective/VertexLit"
}