Shader "Custom/My/10/ReflectionTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_ReflectColor("Reflect Color", Color) = (1,1,1,1)
		_Cubemap("Cube Map",Cube) = "_Skybox"{}
		_ReflectAmount("Reflection Amount" ,Range(0,1)) = 1
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
			fixed _ReflectAmount;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 reflectionDir : TEXCOORD1;
				fixed3 worldLight : TEXCOORD2;
				float3 worldPos:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);

				i.worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				i.worldLight = normalize(UnityWorldSpaceLightDir(worldPos));

				i.reflectionDir = reflect(-worldViewDir, i.worldNormal);
				TRANSFER_SHADOW(i);
				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			fixed3 diffuse = _Color.rgb * _LightColor0.rgb* saturate(dot(i.worldNormal, i.worldLight));

			fixed3 reflection = texCUBE(_Cubemap, i.reflectionDir)*_ReflectColor.rgb;

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

			return  fixed4(ambient + lerp(diffuse, reflection, _ReflectAmount) * atten, 1.0);
			}

			ENDCG
	}
		}
			FallBack "Reflective/VertexLit"
}