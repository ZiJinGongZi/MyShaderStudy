Shader "Custom/Superimposed" {
	Properties{
		_Color("Color", Color) = (1, 1, 1, 1)
		_MainTex("Base (RGB)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_MoveTex("Move Texture", 2D) = "white"{}
		_MoveTexScaleX("Move Texture Horizontal Scale", Range(0,1)) = 1
		_MoveTexScaleY("Move Texture Vertical Scale", Range(0,1)) = 1
	}
		SubShader{
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

			Pass {
				Tags { "LightMode" = "ForwardBase" }

				CGPROGRAM

				#include "Lighting.cginc"
				#include "AutoLight.cginc"

				#pragma multi_compile_fwdbase

				#pragma vertex vert
				#pragma fragment frag

				fixed4 _Color;
				sampler2D _MainTex;
				sampler2D _BumpMap;
				sampler2D _MoveTex;
				float _MoveTexScaleX;
				float _MoveTexScaleY;

				float4 _MainTex_ST;
				float4 _BumpMap_ST;
				float4 _MoveTex_ST;

				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
					float4 texcoord2 : TEXCOORD1;
				};

				struct v2f {
					float4 pos : SV_POSITION;
					float2 uvMainTex : TEXCOORD0;
					float2 uvBumpMap : TEXCOORD1;
					float2 uvMoveMap : TEXCOORD2;
					float3 lightDir : TEXCOORD3;
					float3 worldPos : TEXCOORD4;
					SHADOW_COORDS(5)
				};

				v2f vert(a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					o.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);

					o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
if (o.uvMainTex.x < _MoveTexScaleX*o.uvMainTex.x && o.uvMainTex.y < _MoveTexScaleY*o.uvMainTex.y)
					o.uvMainTex = TRANSFORM_TEX(v.texcoord, _MoveTex);

TANGENT_SPACE_ROTATION;
o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

TRANSFER_SHADOW(o);

return o;
}

fixed4 frag(v2f i) : SV_Target {
	fixed4 moveColor = tex2D(_MoveTex,i.uvMainTex);

	float3 tangentLightDir = normalize(i.lightDir);
	fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

	fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb + moveColor.rgb;

	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	//fixed3 finalColor = lerp(ambient + diffuse * atten, moveColor.rgb,1);

	return fixed4(ambient + diffuse * atten, 1);
}

ENDCG
}

// Pass to render object as a shadow caster
		}
			FallBack "Diffuse"
}