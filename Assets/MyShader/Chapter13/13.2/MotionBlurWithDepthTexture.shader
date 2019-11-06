Shader "Custom/My/13/MotionBlurWithDepthTexture"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BlurSize("Blur Size", Float) = 1.0
	}
		SubShader
		{
			CGINCLUDE
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			half4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;
			float4x4 _CurrentViewProjectionInverseMatrix;
			float4x4 _PreviousViewProjectionMatrix;
			half _BlurSize;

			struct v2f {
				float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0;
				half2 uv_depth : TEXCOORD1;
		  };
			v2f vert(appdata_img v)
			{
				v2f i;
				i.pos = UnityObjectToClipPos(v.vertex);
				i.uv = v.texcoord;
				i.uv_depth = v.texcoord;
	#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					i.uv_depth.y = 1 - i.uv_depth.y;
	#endif
				return i;
			}

			fixed4 frag(v2f i) :SV_Target
			{
				//获得当前像素的深度缓存值
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth);
			//H是该像素处的视口坐标位置，范围在-1到1
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);

			//_CurrentViewProjectionInverseMatrix : Camera.projectionMatrix * Camera.worldToCameraMatrix 裁剪空间->观察空间->世界空间
			//_PreviousViewProjectionMatrix : Camera.worldToCameraMatrix * Camera.projectionMatrix 世界空间->观察空间->裁剪空间
			//currentViewProjectionMatrix : Camera.projectionMatrix * Camera.worldToCameraMatrix 世界空间->观察空间->裁剪空间

			//通过视角*投影矩阵的逆矩阵进行变换
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			//除以w来获得世界位置
			float4 worldPos = D / D.w;

			//当前视口坐标
			float4 currentPos = H;
			//通过前一个视图投影矩阵对世界坐标进行变换
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			//通过除以w转换为非齐次坐标点，范围在-1到1
			previousPos /= previousPos.w;

			//利用当前帧和上一帧的坐标计算该像素的速度，因为currentPos.xy、previousPos.xy的取值范围都是-1到1，所以这里需要除以2
			float2 velocity = (currentPos.xy - previousPos.xy) / 2;

			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);
			uv += velocity * _BlurSize;

			for (int j = 1; j < 3; j++, uv += velocity * _BlurSize)
			{
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			c /= 3;
			return fixed4(c.rgb, 1);
			}

				ENDCG

				Pass
			{
				ZTest Always Cull Off ZWrite Off
				CGPROGRAM
#pragma vertex vert
#pragma fragment frag
				ENDCG
			}
		}
			FallBack Off
}