Shader "Custom/My/6/BlinnPhongUseBuildInFunction"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader
	{
		Pass{
		Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
		#pragma vertex vert

		#pragma fragment frag
#include "Lighting.cginc"

		fixed4 _Diffuse;
	fixed4 _Specular;
	float _Gloss;

	struct a2v {
		float4 vertex :POSITION;
		float3 normal:NORMAL;
	};
	struct v2f {
		float4 pos:SV_POSITION;
		fixed3 worldNormal : TEXCOORD0;
		fixed3 worldPos : TEXCOORD1;
	};

	v2f vert(a2v v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
		o.worldPos = UnityObjectToWorldDir(v.vertex);
		return o;
	}
	fixed4 frag(v2f o) :SV_Target
	{
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
		fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
		fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * (dot(o.worldNormal , worldLightDir) * 0.5 + 0.5);

		fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
		fixed3 halfDir = normalize(worldLightDir + viewDir);
		fixed3 specular = _Specular.rgb* _LightColor0.rgb*pow(saturate(dot(o.worldNormal, halfDir)), _Gloss);

		fixed3 color = ambient + diffuse + specular;
		return fixed4(color, 1.0);
	}

		ENDCG
	}
	}
		FallBack "Specular"
}