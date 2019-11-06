Shader "Custom/My/9/MyBumpDiffuse"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
			Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
	#pragma multi_compile_fwdbase
				#pragma vertex vert
				#pragma fragment frag
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				//cross内的参数位置不同会导致贴图细节上上下颠倒
				//float3 worldBinormal = cross(worldTangent,worldNormal) * v.tangent.w;
				float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
				//float3 worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				i.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(i);
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
				bump = normalize(mul(rotation, bump));
				//bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));

				bump *= _BumpScale;

				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + diffuse * atten, 1.0);
			}

				ENDCG
			}

				Pass
			{
				Tags{"LightMode" = "ForwardAdd"}
				Blend One One

				CGPROGRAM
	#pragma multi_compile_fwdadd
	#pragma vertex vert
	#pragma fragment frag
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

				fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
				//float3 worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				i.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				TRANSFER_SHADOW(i);
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				float3x3 rotation = float3x3(i.T2W0.xyz, i.T2W1.xyz, i.T2W2.xyz);
				bump = normalize(mul(rotation, bump));
				//bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));

				bump *= _BumpScale;

				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(diffuse * atten, 1.0);
			}

				ENDCG
	}
		}
			FallBack "Diffuse"
}