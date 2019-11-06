Shader "Custom/My/11/ScrollingBackgroundTest"
{
	Properties
	{
		_BackTex("Background Texture", 2D) = "white" {}
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BackSpeed("Back Speed", Float) = 1
		_MainSpeed("Main Speed", Float) = 1
		_Multiplier("Layer MultiPlier", Float) = 1
	}
		SubShader
		{
			Tags {  "RenderType" = "Opaque" }

			Pass{
				Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BackTex;
			float4 _BackTex_ST;
			float _BackSpeed;
			float _MainSpeed;
			float _Multiplier;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv.zw = TRANSFORM_TEX(v.texcoord, _BackTex);
				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				float4 backColor = tex2D(_BackTex,i.uv.zw + fixed2(frac(_Time.y* _BackSpeed),0));
				float4 mainColor = tex2D(_MainTex, i.uv.xy + fixed2(frac(_Time.y * _MainSpeed), 0));

				fixed4 color = lerp(backColor, mainColor, mainColor.a);
				return color;
			}

			ENDCG
	}
		}
			FallBack "Diffuse"
}