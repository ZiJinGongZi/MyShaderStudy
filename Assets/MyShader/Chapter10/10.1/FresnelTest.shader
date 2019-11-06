Shader "Custom/My/10/FresnelTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_ReflectColor("Reflect Color",Color) = (1,1,1,1)
		_Cubemap("Cube Map", Cube) = "_Skybox" {}
		_ReflectAmount("Reflect Amount", Range(0,1)) = 1
		_FresnelScale("Fresnel Scale",Range(0,1)) = 0.5
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
			fixed4 _ReflectColor;
			samplerCUBE _Cubemap;
			half _ReflectAmount;
			half _FresnelScale;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal:NORMAL;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				float3 worldPos:TEXCOORD1;
				fixed3 worldViewDir : TEXCOORD2;
				SHADOW_COORDS(3)
				float3 reflectDir:TEXCOORD4;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				i.worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				i.reflectDir = reflect(-i.worldViewDir, i.worldNormal);
				TRANSFER_SHADOW(i);
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
			fixed3 diffuse = _Color.rgb * _LightColor0.rgb * saturate(dot(i.worldNormal, worldLight));
			fixed3 reflection = texCUBE(_Cubemap, i.reflectDir) * _ReflectColor;
			fixed3 fresnel = _FresnelScale + (1 - _FresnelScale)* pow(dot(i.worldViewDir, i.worldNormal), 5);
			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			return fixed4(ambient + lerp(diffuse, reflection, saturate(fresnel*_ReflectAmount)), 1.0);
			}

			ENDCG
	}
		}
			FallBack "Reflective/VertexLit"
}