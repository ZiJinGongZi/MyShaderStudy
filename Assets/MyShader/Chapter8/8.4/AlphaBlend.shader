Shader "Custom/My/8/AlphaBlend"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
	}
		SubShader
		{
			Tags { "Quene" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			Pass{
			Tags{"LightMode" = "ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _AlphaScale;

			struct a2v {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float3 worldPos:TEXCOORD0;
				float3 worldNormal:TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = UnityObjectToWorldDir(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			fixed4 frag(v2f o) :SV_Target
			{
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));

			fixed4 texColor = tex2D(_MainTex, o.uv);

			fixed3 albedo = texColor.rgb * _Color.rgb;
			fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			fixed3 diffuse = albedo * _LightColor0.rgb * (dot(o.worldNormal, worldLightDir) * 0.5 + 0.5);
			return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
			}

			ENDCG
	}
		}
			FallBack "Transparent/VertexLit"
}