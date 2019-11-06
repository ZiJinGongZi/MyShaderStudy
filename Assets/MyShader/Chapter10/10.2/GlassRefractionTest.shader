Shader "Custom/My/10/GlassRefractionTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bump Map", 2D) = "bump" {}
		_Cubemap("Cube Map",Cube) = "_Skybox" {}
		_Distortion("Distorstion", Range(0,100)) = 100
		_ReflectAmount("Metallic", Range(0,1)) = 0.0
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "RenderType" = "Opaque" }
			GrabPass{"_RefractionTex"}

			Pass{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			half _Distortion;
			half _ReflectAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
				float4 T2W0:TEXCOORD1;
				float4 T2W1:TEXCOORD2;
				float4 T2W2:TEXCOORD3;
				float4 scrPos:TEXCOORD4;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				i.scrPos = ComputeGrabScreenPos(i.pos);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent)* v.tangent.w;

				i.T2W0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				i.T2W1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				i.T2W2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				float3 worldPos = float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));

				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.scrPos.xy += offset;
				fixed3 refracColor = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

				bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));
				fixed3 reflectDir = reflect(-worldViewDir, bump);
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				fixed3 reflecColor = texCUBE(_Cubemap, reflectDir) *albedo;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 finalColor = ambient + reflecColor * (1 - _ReflectAmount) + refracColor * _ReflectAmount;

				return fixed4(finalColor, 1.0);
			}

			ENDCG
	}
		}
			FallBack "Diffuse"
}