Shader "Custom/My/12/BrightnessSaturationAndContrast"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			Pass{
				ZTest Always Cull Off ZWrite Off

				CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			float _Brightness;
			float _Saturation;
			float _Contrast;

			struct a2v {
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = v.texcoord;
				return i;
			}
			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 renderTex = tex2D(_MainTex,i.uv);
			//设置亮度
			fixed3 finalColor = renderTex.rgb * _Brightness;
			//设置饱和度
			fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
			fixed3 luminanceColor = fixed3(luminance, luminance,luminance);
			finalColor = lerp(luminanceColor, finalColor, _Saturation);
			//设置对比度
			fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
			finalColor = lerp(avgColor, finalColor, _Contrast);

			return fixed4(finalColor, renderTex.a);
			}

			ENDCG
	}
		}
			FallBack Off
}