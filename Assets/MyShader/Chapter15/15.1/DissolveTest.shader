Shader "Custom/My/15/DissolveTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpTex("Bump Texture", 2D) = "bump" {}
		_RampTex("Ramp Texture", 2D) = "white" {}
		_BurnFirstColor("Burn First Color", Color) = (1,1,1,1)
		_BurnSecondColor("Burn Second Color", Color) = (1,1,1,1)
		_BurnAmount("Burn Amount", Range(0,1)) = 0
		_BurnWidth("Burn Width", Float) = 0.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
			{
				Tags { "LightMode" = "ForwardBase" }
				Cull Off

				 CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "UnityCG.cginc"
	#include "Lighting.cginc"
	#include "AutoLight.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			fixed4 _BurnFirstColor;
			fixed4 _BurnSecondColor;
			fixed _BurnAmount;
			half _BurnWidth;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uvBumpTex:TEXCOORD0;
				float2 uvBurnTex:TEXCOORD1;
				float2 uvMianTex:TEXCOORD2;
				float3 worldPos:TEXCOORD3;
				float3 tangentLightDir:TEXCOORD4;
				SHADOW_COORDS(5)
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uvBumpTex = TRANSFORM_TEX(v.texcoord, _BumpTex);
				i.uvBurnTex = TRANSFORM_TEX(v.texcoord, _RampTex);
				i.uvMianTex = TRANSFORM_TEX(v.texcoord, _MainTex);

				TANGENT_SPACE_ROTATION;
				i.tangentLightDir = mul(rotation, WorldSpaceLightDir(v.vertex));
				i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);
				TRANSFER_SHADOW(i);

				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				fixed3 tangentLightDir = normalize(i.tangentLightDir);

			fixed4 burn = tex2D(_RampTex, i.uvBurnTex);
			clip(burn.r - _BurnAmount);

			fixed3 bump = normalize(UnpackNormal(tex2D(_BumpTex, i.uvBumpTex)));

			float diff = 1 - smoothstep(0, _BurnWidth, burn.r - _BurnAmount);
			fixed4 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, diff);
			burnColor = pow(burnColor, 5);

			UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			float3 albedo = tex2D(_MainTex, i.uvMianTex).rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

			fixed3 diffuse = albedo * _LightColor0.rgb * saturate(dot(bump, tangentLightDir));
			fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor.rgb, diff * step(0.001, burn.r - _BurnAmount));
			return fixed4(finalColor, 1);
			}

			ENDCG
	}

			Pass
			{
				Tags{"LightMode" = "ShadowCaster"}

				 CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
#pragma multi_compile_shadowcaster
#include "UnityCG.cginc"

			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed _BurnAmount;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f {
				float2 uv:TEXCOORD0;
				V2F_SHADOW_CASTER;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = TRANSFORM_TEX(v.texcoord, _RampTex);

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(i);
				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 burn = tex2D(_RampTex,i.uv);
			clip(burn.r - _BurnAmount);
			SHADOW_CASTER_FRAGMENT(i);
			}

			ENDCG
	}
		}
			FallBack "Diffuse"
}