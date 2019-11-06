Shader "Custom/My/12/BrightnessSaturationAndContrastPrac"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Brightness("Brightness", Range(0,3)) = 1.0
		_Saturation("Saturation", Range(0,3)) = 1.0
		_Contrast("Contrast", Range(0,3)) = 1.0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }

			Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
	#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _Brightness;
			half _Saturation;
			half _Contrast;

			struct v2f {
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			v2f vert(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = v.texcoord;
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 texColor = tex2D(_MainTex,i.uv);
			fixed3 finalColor = texColor.rgb * _Brightness;

			float limimance = 0.2125 * texColor.r + 0.7154 * texColor.g + 0.0721 * texColor.b;
			fixed3 saturation = fixed3(limimance, limimance, limimance);
			finalColor = lerp(saturation, finalColor, _Saturation);

			fixed3 contrast = fixed3(0.5, 0.5, 0.5);
			finalColor = lerp(contrast, finalColor, _Contrast);

			return fixed4(finalColor,1.0);
			}

			ENDCG
}
		}
			FallBack Off
}