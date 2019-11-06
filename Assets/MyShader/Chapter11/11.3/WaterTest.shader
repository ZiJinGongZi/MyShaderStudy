Shader "Custom/WaterTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Magnitude("Magnitude", Float) = 1
		_Frequence("Frequence",Float) = 1
		_WaveLength("Wave Length",Float) = 1
		_Speed("Speed", Float) = 1.0
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass
			{
				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Magnitude;
			float _Frequence;
			float _WaveLength;
			fixed4 _Color;
			float _Speed;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				float4 offset;
				offset.yzw = float3(0, 0, 0);
				offset.x = sin(_Magnitude * _Time.y + v.vertex.z * _Frequence) * _WaveLength;
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex + offset);

				i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				i.uv += float2(0, _Time.y * _Speed);
				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				float4 color = tex2D(_MainTex,i.uv);
				color.rgb *= _Color.rgb;
				return color;
			}

			ENDCG
	}
		}
			FallBack "Transparent/VertexLit"
}