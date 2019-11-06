Shader "Custom/My/7/MaskTextureTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Bump Map",2D) = "bump"{}
		_BumpScale("Bump Scale",Float) = 1.0
		_SpecularMask("Specular Mask",2D) = "white"{}
		_SpecularScale("Specular Scale",Float) = 1.0
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _SpecularMask;
			float _SpecularScale;
			fixed4 _Specular;
			half _Gloss;

			struct a2v {
				float4 vertex:POSITION;
				float4 tangent:TANGENT;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				TANGENT_SPACE_ROTATION;

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
				return o;
			}

			fixed4 frag(v2f o) :SV_Target
			{
				float3 tangentLightDir = normalize(o.lightDir);
				float3 tangentViewDir = normalize(o.viewDir);

				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, o.uv));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, o.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * (dot(tangentNormal, tangentLightDir)*0.5 + 0.5);

				fixed3 specularMask = tex2D(_SpecularMask, o.uv).r * _SpecularScale;
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss)*specularMask;

				fixed3 color = ambient + diffuse + specular;
				return fixed4(color, 1.0);
			}

			ENDCG
			}
		}
			FallBack "Specular"
}