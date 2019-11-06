Shader "Custom/My/11/NewSurfaceShader"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_HorizontalAmount("Horizontal Amount", Float) = 8
		_VerticalAmount("Vertical Amount", Float) = 8
		_Speed("Speed",Float) = 1
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "IgnorProjector" = "True" "RenderType" = "Transparent" }
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
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;
			fixed4 _Color;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				float time = floor(_Time.y * _Speed);
			float horizontal = floor(time / _HorizontalAmount);
			float vertical = time - horizontal * _VerticalAmount;

			half2 uv = i.uv + half2(horizontal, -vertical);
			uv.x /= _HorizontalAmount;
			uv.y /= _VerticalAmount;

			fixed4 color = tex2D(_MainTex, uv);
			color.rgb *= _Color.rgb;
			return color;
			}

					ENDCG
			}
		}
			FallBack "Transparent/VertexLit"
}