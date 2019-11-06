Shader "Custom/My/7/NormalMapWorldSpace"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Mian Tex", 2D) = "white" {}
		_BumpMap("Bump Map",2D) = "bump"{}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader
		{
			Pass{
				Tags { "RenderType" = "Opaque" }
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
	#include "Lighting.cginc"

			fixed4	_Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				float3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				float3 worldPos = UnityObjectToWorldDir(v.vertex.xyz);

				o.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}

			fixed4 frag(v2f o) :SV_Target
			{
				float3 worldPos = float3(o.T2W0.w,o.T2W1.w,o.T2W2.w);
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				float3 worldView = normalize(UnityWorldSpaceViewDir(worldPos));

				float4 unpacked = tex2D(_BumpMap, o.uv.zw);
				float3 tangentNormal;
				//tangentNormal.xy = (unpacked.xy * 2 - 1)*_BumpScale;
				tangentNormal.xy = UnpackNormal(unpacked)*_BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				float3 worldNormal = normalize(float3(dot(o.T2W0.xyz, tangentNormal), dot(o.T2W1.xyz, tangentNormal),dot(o.T2W2.xyz, tangentNormal)));
				//float3 worldNormal = normalize(mul(float3x3(o.T2W0.xyz, o.T2W1.xyz, o.T2W2.xyz), tangentNormal));

				float3 albedo = tex2D(_MainTex, o.uv.xy).xyz * _Color.rgb;

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				float3 diffuse = _Color.rgb * albedo* (dot(worldNormal, worldLightDir)*0.5 + 0.5);

				float3 halfDir = normalize(worldLightDir + worldView);
				float3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				float3 color = ambient + diffuse + specular;
				return fixed4(color, 1.0);
			}

			ENDCG
		}
		}
			FallBack "Specular"
}