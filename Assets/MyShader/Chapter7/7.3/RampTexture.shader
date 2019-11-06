Shader "Custom/My/7/RampTexture"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_RampTex("Ramp Tex", 2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
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

				fixed4 _Color;
				sampler2D _RampTex;
				float4 _RampTex_ST;
				fixed4 _Specular;
				half _Gloss;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
				};
				struct v2f {
					float4 pos:SV_POSITION;
					float3 worldNormal:TEXCOORD0;
					float3 worldPos:TEXCOORD1;
					float2 uv:TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
					o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

					return o;
				}

				fixed4 frag(v2f o) :SV_Target
				{
					float3 worldNormal = normalize(o.worldNormal);
					float3 worldLight = normalize(UnityWorldSpaceLightDir(o.worldPos));

					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed halfLambert = dot(worldNormal, worldLight)*0.5 + 0.5;
					fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb*_Color.rgb;
					fixed3 diffuse = _LightColor0.rgb*diffuseColor;

					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
					fixed3 halfDir = normalize(viewDir + worldLight);
					fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(worldNormal, halfDir)), _Gloss);

					fixed3 color = ambient + diffuse + specular;
					return fixed4(color, 1.0);
				}

				ENDCG
			}
		}
			FallBack "Specular"
}