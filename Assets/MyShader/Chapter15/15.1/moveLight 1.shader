Shader "Custom/moveLight 1" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
			//流光图
			_LightTex("Light Texture",2D) = "white"{}
		//遮罩图
		_MaskTex("Mask Texture",2D) = "white"{}
		//流光颜色
		_MoveLightColor("MoveLightColor", Color) = (1,1,1,1)
			//流光uv x轴速度
			_SpeedX("SpeedX", Range(-1,1)) = 0.0
			//流光uv y轴速度
			_SpeedY("SpeedY", Range(-1,1)) = 0.0
			//流光宽度
			_LightWidth("LightWidth",Range(1,20)) = 1
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard fullforwardshadows

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _LightTex;
			sampler2D _MaskTex;
			float4 _MoveLightColor;
			float _SpeedY;
			float _SpeedX;
			float _LightWidth;

			struct Input
			{
				float2 uv_MainTex;
			};

			half _Glossiness;
			half _Metallic;
			fixed4 _Color;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				//计算流光宽度uv坐标越少，则获取白色流光图白色区域越大，就等于流光长度
				float2 uv = IN.uv_MainTex / _LightWidth;
				//流光图y轴偏移
				uv.y += _Time.y * _SpeedY;
				//流光图x轴偏移
				uv.x += _Time.y * _SpeedX;
				//获取流光图的蓝色通道，因为流光图都是黑白，获取红色绿色通道都可以
				fixed light = tex2D(_LightTex, uv).b;
				//获取要显示流光的位置，我这里使用蓝色通道来处理，我这边不用alpha来处理，因为透明图占内存
				fixed maskb = tex2D(_MaskTex, IN.uv_MainTex).b;
				//这里算出要流光的地方叠加颜色
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color + light * _MoveLightColor * maskb;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
————————————————
版权声明：本文为CSDN博主「红叶920」的原创文章，遵循 CC 4.0 BY - SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https ://blog.csdn.net/qq_42987283/article/details/90039420