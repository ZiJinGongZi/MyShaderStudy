Shader "Custom/My/10/Fresnel"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_FresnelScale("Fresnel Scale" ,Range(0,1)) = 0.5
		_Cubemap("Reflection Cubemap" ,Cube) = "_Skybox"{}
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
#include "Lighting.cginc"
#include "AutoLight.cginc"

		fixed4 _Color;
	fixed _FresnelScale;
	samplerCUBE _Cubemap;

	struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
	};
	struct v2f {
		float4 pos:SV_POSITION;
		fixed3 worldNormal : TEXCOORD0;
		float3 worldReflection:TEXCOORD1;
		float3 worldPos:TEXCOORD2;
		SHADOW_COORDS(3)
		fixed3 worldViewDir : TEXCOORD4;
	};

	v2f vert(a2v v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);
		i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		i.worldNormal = UnityObjectToWorldNormal(v.normal);
		i.worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		i.worldReflection = reflect(-i.worldViewDir, i.worldNormal);
		TRANSFER_SHADOW(i);
		return i;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
	fixed3 diffuse = _Color.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLightDir));
	fixed3 reflection = texCUBE(_Cubemap, i.worldReflection).rgb;
	fixed fresnel = _FresnelScale + (1 - _FresnelScale)* pow(1 - dot(i.worldViewDir, i.worldNormal), 5);
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;
	return fixed4(color, 1.0);
	}

		ENDCG
}
	}
		FallBack "Reflective/VertexLit"
}