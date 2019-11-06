Shader "Custom/My/8/AlphaTestBothSide"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Cutoff("Cut Off", Range(0,1)) = 1
	}
		SubShader
		{
			Tags{"Quene" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
		Pass{
			Tags { "LightMode" = "ForwardBase" }
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include"Lighting.cginc"

			sampler2D _MainTex;
			fixed4 _Color;
			float4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 worldLight:TEXCOORD1;
				float3 worldNormal:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldLight = normalize(UnityWorldSpaceLightDir(v.vertex));
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				return o;
			}

			fixed4 frag(v2f o) :SV_Target
			{
				float4 texColor = tex2D(_MainTex,o.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;
				clip(texColor.a - _Cutoff);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = albedo * _LightColor0.rgb * (dot(o.worldNormal, o.worldLight) * 0.5 + 0.5);

				return fixed4(ambient + diffuse, 1.0);
			}

			ENDCG
	}
		}
			FallBack "Tranparent/Cutout/VertexLit"
}