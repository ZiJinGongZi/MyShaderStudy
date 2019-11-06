Shader "Custom/My/7/NormalMapTangentSpace"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map",2D) = "bump"{}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specualr",Color) = (1,1,1,1)
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
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _BumpScale;
				fixed4 _Specular;
				half _Gloss;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 texcoord:TEXCOORD0;
					float4 tangent:TANGENT;
				};
				struct v2f {
					float4 pos:SV_POSITION;
					float4 uv:TEXCOORD0;
					float3 lightDir:TEXCOORD1;
					float3 viewDir:TEXCOORD2;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

					/*float3  biNormal = cross(normalize(v.normal), normalize(v.tangent.xyz))*v.tangent.w;
					float3x3 rotation = float3x3(v.tangent.xyz, biNormal, v.normal);*/

					TANGENT_SPACE_ROTATION;

					o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
					o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
					return o;
				}
				fixed4 frag(v2f o) :SV_Target
				{
					float4 packedNormal = tex2D(_BumpMap,o.uv.zw);
					float3 tangentNormal;
					//tangentNormal.xy = (2 * packedNormal.xy - 1)*_BumpScale;
					tangentNormal.xy = UnpackNormal(packedNormal)*_BumpScale;
					tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

					float3 tangentLightDir = normalize(o.lightDir);
					float3 tangentViewDir = normalize(o.viewDir);

					float3 albedo = tex2D(_MainTex, o.uv.xy).rgb*_Color.rgb;
					float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

					float3 diffuse = _LightColor0.rgb*albedo*(dot(tangentNormal, tangentLightDir)*0.5 + 0.5);
					float3 halfDir = normalize(tangentLightDir + tangentViewDir);
					float3 specualr = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
					float3 color = ambient + diffuse + specualr;
					return fixed4(color, 1.0);
				}

				ENDCG
	}
		}
			FallBack "Specualr"
}