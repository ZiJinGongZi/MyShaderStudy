Shader "Custom/My/11/VertexAnimationWithShadow"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Frequency("Frequency", Float) = 1
		_Magnitude("Magnitude",Float) = 1
		_InvWaveLength("Wave Length", Float) = 1.0
		_Speed("Speed",Float) = 1
	}
		SubShader
		{
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }

			Pass
			{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "Lighting.cginc"

			sampler2D _MainTex;
		float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v {
				float4 vertex : POSITION;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f i;
				float4 offset;
				offset.yzw = float3(0, 0, 0);
				offset.x = sin(_Frequency * _Time.y + _InvWaveLength * v.vertex.z) * _Magnitude;
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

				Pass{
					Tags{"LightMode" = "ShadowCaster"}
					CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
				#include "UnityCG.cginc"

			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
			};
			struct v2f {
				//V2F_SHADOW_CASTER;
				V2F_SHADOW_CASTER;
			};

			v2f vert(a2v v)
			{
				v2f o;
				float4 offset;
				offset.yzw = float3(0, 0, 0);
				offset.x = sin(_Frequency * _Time.y + v.vertex.z * _InvWaveLength) * _Magnitude;
				v.vertex += offset;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}
			fixed4 frag(v2f i) :SV_Target{
				SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}
		}
			FallBack "VertexLit"
}