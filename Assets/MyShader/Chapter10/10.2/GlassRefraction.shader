Shader "Custom/My/10/GlassRefraction"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_BumpMap("Normal Map", 2D) = "bump" {}
	_Cubemap("Enviroment Cube", Cube) = "_Skybox"{}
		_Distortion("Distortion", Range(0,100)) = 10
		_RefractAmount("Refract Amount", Range(0,1)) = 1.0
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
			GrabPass
			{
				"_RefractionTex"
	}

			Pass{
				 CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			half _Distortion;
			half _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct a2v {
				float4 vertex:POSITION;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
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
				i.scrPos = ComputeGrabScreenPos(i.pos);

				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = normalize(UnityObjectToWorldDir(v.tangent.xyz));
				fixed3 worldBinormal = cross(worldNormal, worldTangent)*v.tangent.w;

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
				i.scrPos.xy = offset + i.scrPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex, i.scrPos.xy / i.scrPos.w).rgb;

				bump = normalize(half3(dot(i.T2W0.xyz, bump), dot(i.T2W1.xyz, bump), dot(i.T2W2.xyz, bump)));
				fixed3 reflDir = reflect(-worldViewDir, bump);
				fixed4 texColor = tex2D(_MainTex, i.uv.xy);
				fixed3 reflCol = texCUBE(_Cubemap, reflDir).rgb * texColor.rgb;

				fixed3 finalColor = reflCol * (1 - _RefractAmount) + refrCol * _RefractAmount;

				return fixed4(finalColor, 1);
			}

			ENDCG
	}
		}
			FallBack "Diffuse"
}