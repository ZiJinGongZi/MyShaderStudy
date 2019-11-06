// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/My/9/ForwardRendering"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8.0,256)) = 20
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
	   Pass{
			Tags{"LightMode" = "ForwardBase"}
		CGPROGRAM
		#pragma multi_compile_fwdbase
		#pragma vertex vert
		#pragma fragment frag
		#include "Lighting.cginc"

		fixed4 _Specular;
	fixed4 _Diffuse;
	float _Gloss;

	struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
	};
	struct v2f {
		float4 pos:SV_POSITION;
		fixed3 worldPos : TEXCOORD0;
		fixed3 worldNormal : TEXCOORD1;
	};

	v2f vert(a2v v)
	{
		v2f o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.worldNormal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
		return o;
	}
	fixed4 frag(v2f o) :SV_Target{
		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(o.worldNormal, worldLight));

	//fixed3 viewDir = normalize(UnityObjectToViewPos(o.worldPos));
	fixed3 viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);
	fixed3 halfDir = normalize(viewDir + worldLight);
	fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(o.worldNormal, halfDir)), _Gloss);

	fixed atten = 1.0;
	return fixed4(ambient + (diffuse + specular) * atten, 1.0);
	}

		ENDCG
		}

			Pass{
				Tags{"LightMode" = "ForwardAdd"}
				Blend One One

			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
	#include "AutoLight.cginc"

			fixed4 _Specular;
		fixed4 _Diffuse;
		float _Gloss;

		struct a2v {
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};
		struct v2f {
			float4 pos:SV_POSITION;
			fixed3 worldPos : TEXCOORD0;
			fixed3 worldNormal : TEXCOORD1;
		};

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.worldNormal = UnityObjectToWorldNormal(v.normal);
			o.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
			return o;
		}
		fixed4 frag(v2f o) :SV_Target{
	#ifdef USING_DIRECTIONAL_LIGHT
		fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
	#else
			fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - o.worldPos);
	#endif

		fixed3 diffuse = _Diffuse.rgb * _LightColor0.rgb * saturate(dot(o.worldNormal, worldLight));

		fixed3 viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);
		fixed3 halfDir = normalize(viewDir + worldLight);
		fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(o.worldNormal, halfDir)), _Gloss);

	#ifdef USING_DIRECTIONAL_LIGHT
		fixed atten = 1.0;
	#else
		float3 lightCoord = mul(unity_WorldToLight, float4(o.worldPos, 1));
		fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
	#endif
		return fixed4((diffuse + specular) * atten, 1.0);
		}

			ENDCG
	}
	}
		FallBack "Diffuse"
}