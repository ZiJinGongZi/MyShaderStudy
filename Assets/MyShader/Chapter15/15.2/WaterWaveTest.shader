Shader "Custom/My/15/WaterWaveTest"
{
	Properties
	{
		_Color("Color", Color) = (1,0.15,0.115,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Wavemap("Wavemap", 2D) = "bump" {}
		_Cubemap("Enviroment Cubemap", Cube) = "_Skybox" {}
		_HorizontalSpeed("Horizontal Speed",Float) = 1
		_VerticalSpeed("Vertical Speed",Float) = 1
		_Distortion("Distortion", Range(0,100)) = 20
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "RenderType" = "Opaque" }
			//这里抓取背景然后混合达到透明效果
				GrabPass {
				"_ReflectionTex"
			}
			CGINCLUDE
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

						fixed4 _Color;
					sampler2D _MainTex;
					float4 _MainTex_ST;
					sampler2D _Wavemap;
					float4 _Wavemap_ST;
					samplerCUBE _Cubemap;
					float _HorizontalSpeed;
					float _VerticalSpeed;
					float _Distortion;
					sampler2D _ReflectionTex;
					float4 _ReflectionTex_TexelSize;

						struct v2f {
							float4 pos:SV_POSITION;
							float4 uv:TEXCOORD0;
							float4 scrPos:TEXCOORD1;
							float3 worldPos:TEXCOORD2;
							float3x3 rotation :TEXCOORD3;
						};

						v2f vert(appdata_tan v)
						{
							v2f i;
							i.pos = UnityObjectToClipPos(v.vertex);
							i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
							i.uv.zw = TRANSFORM_TEX(v.texcoord, _Wavemap);
							TANGENT_SPACE_ROTATION;
							i.worldPos = mul(unity_ObjectToWorld, v.vertex.xyz);
							i.rotation = rotation;
							i.scrPos = ComputeGrabScreenPos(i.pos);

							return i;
						}

						fixed4 frag(v2f i) :SV_Target
						{
							fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
						float2 speed = float2(_HorizontalSpeed, _VerticalSpeed) * _Time.y;

						fixed3 bump1 = UnpackNormal(tex2D(_Wavemap, i.uv.zw + speed));
						fixed3 bump2 = UnpackNormal(tex2D(_Wavemap, i.uv.zw - speed));
						fixed3 bump = normalize(bump1 + bump2);

						float2 offset = bump.xy * _Distortion * _ReflectionTex_TexelSize.xy;
						i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
						fixed3 refrColor = tex2D(_ReflectionTex, i.scrPos.xy / i.scrPos.w).rgb;

						bump = mul(bump,i.rotation);
						fixed3 mainColor = tex2D(_MainTex, i.uv.xy + speed).rgb;
						fixed3 reflectDir = reflect(-viewDir,bump);
						fixed3 reflColor = texCUBE(_Cubemap, reflectDir).rgb * _Color.rgb* mainColor;

						float fresnel = pow(1 - saturate(dot(viewDir , bump)), 4);
						return float4(reflColor* fresnel + refrColor * (1 - fresnel), 1);
						}

						ENDCG

					Pass
					{
						Tags{"LightMode" = "ForwardBase"}
						CGPROGRAM
						#pragma vertex vert
						#pragma fragment frag
			#pragma multi_compile_fwdbase

						ENDCG
					}
		}
			FallBack Off
}