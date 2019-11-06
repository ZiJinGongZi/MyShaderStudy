Shader "Custom/My/6/SpecularVertexLevel"
{
	Properties
	{
		_Diffuse("Color", Color) = (1,1,1,1)
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
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};
		struct v2f {
			float4 pos:SV_POSITION;
			float3 color:CORLOR;
		};

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 worldNormal = normalize(UnityObjectToWorldDir(v.normal));
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

			fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb*(dot(worldNormal,worldLight)*0.5 + 0.5);
			fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
			fixed3 viewDir = normalize(_WorldSpaceCameraPos - UnityObjectToWorldDir(v.vertex).xyz);
			fixed3 specular = _Specular.rgb*_LightColor0.rgb*pow(saturate(dot(reflectDir, viewDir)), _Gloss);
			o.color = ambient + diffuse + specular;
			return o;
		}
		float4 frag(v2f o) :SV_Target
		{
			return fixed4(o.color,1.0);
		}
		ENDCG
	}
	}
		FallBack "Specular"
}