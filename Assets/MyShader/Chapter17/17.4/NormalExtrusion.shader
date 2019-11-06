Shader "Custom/My/17/NormalExtrusion"
{
	Properties
	{
		_ColorTint("Color Tint", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump"{}
		_Amount("Extrusion Amount", Range(-0.5,0.5)) = 0.1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 300

			CGPROGRAM
			// surf : 表面函数
			// CustomLambert ： 使用的光照模型
			// vertex:myvert ： 使用通用顶点修改函数
			// finalcolor:mycolor ： 使用通用最终颜色修改函数
			// addshadow ： 生成阴影投射pass。因为我们修改了顶点坐标，shader需要特殊的阴影处理
			// exclude_path : deferred exclude_path : prepass ： 不为deferred/legacy deferred rendering path生成pass
			// nometa ： 不生成一个LightMode为“meta”的pass（为了给光照映射和动态全局光照提取表面信息）
			#pragma surface surf CustomLambert vertex:myvert finalcolor:mycolor addshadow\
			exclude_path : deferred exclude_path : prepass nometa
			#pragma target 3.0

			//Unity会为所有支持的渲染路径生成相应的Pass，为了缩小自动生成的代码量，我们使用exclude_path : deferred 和 exclude_path : prepass
			//来告诉Unity不要为延迟渲染路径生成相应的Pass
			//使用nometa取消对提取元数据的Pass的生成

			sampler2D _MainTex;
			sampler2D _BumpMap;
			half _Amount;
			fixed4 _ColorTint;

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_BumpMap;
			};

			//顶点修改函数，使用顶点法线对顶点位置进行膨胀
			void myvert(inout appdata_full v) {
				v.vertex.xyz += v.normal * _Amount;
			}

			//表面函数，使用主纹理设置了表面属性中的反射率，并使用法线纹理设置了表面法线方向
			void surf(Input IN, inout SurfaceOutput o)
			{
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
				o.Albedo = c.rgb;
				o.Alpha = c.a;
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			}

			//光照函数，实现了简单的兰伯特漫反射光照模型
			half4 LightingCustomLambert(SurfaceOutput s, half3 lightDir, half atten) {
				half NdotL = dot(s.Normal, lightDir);
				half4 c;
				c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten);
				c.a = s.Alpha;
				return c;
			}

			//颜色修改函数 ，使用颜色参数对输出颜色进行调整
			void mycolor(Input IN, SurfaceOutput o, inout fixed4 color) {
				color *= _ColorTint;
			}
			ENDCG
		}
			FallBack "Lengacy Shaders/Diffuse"
}