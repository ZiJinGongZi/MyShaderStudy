Shader "Custom/My/14/ToonShadingTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_Outline("Outline", Float) = 0
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_RampTex("Ramp Texture", 2D) = "white" {}
		_Specular("Specular", Color) = (1,1,1,1)
		_SpecularScale("Specular Scale", Float) = 0.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass{
				Cull Front
				CGPROGRAM

	#pragma vertex vert
	#pragma fragment frag
#include "UnityCG.cginc"

				fixed4 _OutlineColor;
		float _Outline;

		struct a2v {
			float4 vertex:POSITION;
			float3 normal : NORMAL;
			float4 texcoord:TEXCOORD0;
		};

		struct v2f {
			float4 pos:SV_POSITION;
		};

		v2f  vert(a2v v)
		{
			v2f i;
			float4 pos = float4 (UnityObjectToViewPos(v.vertex),1);
			float3 normal = mul(UNITY_MATRIX_IT_MV, v.normal);
			normal.z = -0.5;
			pos += float4(normalize(normal),0) * _Outline;
			i.pos = mul(UNITY_MATRIX_P, pos);
			return i;
		}

		fixed4 frag(v2f i) :SV_Target{
			return fixed4(_OutlineColor.rgb,1);
		}

			ENDCG
}

Pass{
			Tags{"LightMode" = "ForwardBase"}
			Cull Back

		CGPROGRAM
#pragma multi_compile_fwdbase
		#pragma vertex vert
		#pragma fragment frag
#include "AutoLight.cginc"
#include "Lighting.cginc"

		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _RampTex;
		fixed4 _Specular;
		float _SpecularScale;
		fixed4 _Color;

		struct a2v {
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD0;
			float3 normal:NORMAL;
		};

		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
			float3 worldPos:TEXCOORD1;
			fixed3 worldNormal : TEXCOORD2;
			SHADOW_COORDS(3)
		};

		v2f vert(a2v v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

			i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
			i.worldNormal = UnityObjectToWorldNormal(v.normal);

			TRANSFER_SHADOW(i);

			return i;
		}

		fixed4 frag(v2f i) :SV_Target{
			fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		fixed3 halfDir = normalize(worldLightDir + worldViewDir);

		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
		float3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

		float diff = saturate(dot(i.worldNormal, worldLightDir)) * atten;
		fixed3 diffuse = albedo * _LightColor0.rgb * tex2D(_RampTex, float2(diff, diff)).rgb;

		float spec = dot(i.worldNormal, halfDir);
		half w = fwidth(spec) * 2;
		fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1))*step(0.0001, _SpecularScale);

			return fixed4((ambient + diffuse + specular),1.0);
		}

		ENDCG
}
		}
			FallBack "Diffuse"
}