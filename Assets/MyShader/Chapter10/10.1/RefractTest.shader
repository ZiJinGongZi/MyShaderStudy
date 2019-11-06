Shader "Custom/My/10/RefractTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_RefractColor("Refract Color", Color) = (1,1,1,1)
		_Cubemap("Cube Map", Cube) = "_Skybox" {}
		_RefractColorRatio("Refract Ratio",Range(0.1,1)) = 0.1
		_RefractAmount("Refract Amount",Range(0,1)) = 1
	}

		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			samplerCUBE _Cubemap;
			half _RefractColorRatio;
			half _RefractAmount;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldPos : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				fixed3 refractionDir : TEXCOORD2;
				fixed3 worldLight : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				i.worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				i.refractionDir = refract(-worldViewDir, i.worldNormal, _RefractColorRatio);
				TRANSFER_SHADOW(i);
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			fixed3 diffuse = _Color.rgb *_LightColor0.rgb * saturate(dot(i.worldNormal, i.worldLight));

			fixed3 refraction = texCUBE(_Cubemap, i.refractionDir);

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return fixed4(ambient + lerp(diffuse, refraction, _RefractAmount) * atten, 1.0);
			}

			ENDCG
	}
		}
			FallBack "Reflective/VertexLit"
}