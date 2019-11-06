﻿Shader "Custom/My/7/SingleTexture"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader
		{
				Pass
			{
				 Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

			fixed4 _Color;
			fixed4 _Specular;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord : TEXCOORD0;
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
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = UnityObjectToWorldDir(v.vertex);
				o.uv = v.texcoord.xy*_MainTex_ST.xy + _MainTex_ST.zw;
				//  ==  o.uv = TRANSFORM_TEX(V.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f o) :SV_Target
			{
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));
				fixed3 albedo = tex2D(_MainTex, o.uv).rgb*_Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo* (dot(o.worldNormal, worldLightDir)*0.5 + 0.5);

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(o.worldNormal, halfDir)), _Gloss);

				fixed3 color = ambient + diffuse + specular;
				return fixed4(color, 1.0);
			}

			ENDCG
}
		}
			FallBack "Specular"
}