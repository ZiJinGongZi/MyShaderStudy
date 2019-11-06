// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/Default"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

			//用在ui上的shader一般都需要加下面的模板测试逻辑，避免被有mask组件的父节点遮罩时没遮罩效果
		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"//一般ui都用这种渲染队列，从远到近渲染
				"IgnoreProjector" = "True"//忽略投影，一般ui的shader为提高效率都会设置为true
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"//材质球预览模式为面片
				"CanUseSpriteAtlas" = "True"//设置_MainTex可以使用Sprite(2D and UI)类型的贴图
			}

			//用在ui上的shader一般都需要加下面的模板测试逻辑，避免被有mask组件的父节点遮罩时没遮罩效果
		Stencil
		{
			/*
			Stencil （模板测试/蒙版测试）:			与深度测试，透明度测试类似，决定一个片元是否被扔掉。深度测试的比较数据在深度缓冲中，透明度测试的比较对象是颜色缓冲中的值，			而模版测试的比较数据在Stencil中，并且模板测试要先于深度测试与透明度测试，在fragment函数之前就会执行模板测试。			Fail 当模版测试和深度测试都失败时，进行处理			ZFail 当模版测试通过而深度测试失败时，进行处理
			*/

			//Ref 就是参考值，当参数允许赋值时，会把参考值赋给当前像素
			Ref[_Stencil]
			//Comp 比较方法。是拿Ref参考值和当前像素缓存上的值进行比较。默认值Always
			Comp[_StencilComp]
			//Pass 当模版测试和深度测试都通过时，进行处理
			Pass[_StencilOp]
			//ReadMask 对当前参考值和已有值进行mask操作，默认值255，一般不用
			ReadMask[_StencilReadMask]
			//WriteMask 写入Mask操作，默认值255，一般不用
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off//关掉光照，一般ui的shader为提高效率都会这样设置
		ZWrite Off
			//下面两句设置ZTest只根据ui节点的树层次（即在Hierarchy视图中的层次）作为依据进行测试，不根据z值
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha//最终颜色值 = 输出颜色值 * 输出颜色Alpha值a + 背景颜色值 * (1 - a)，即如果有透明物品挡在前面的话，类似隔着透明玻璃看东西那种效果

		/*
		ColorMask的枚举定义：
		namespace UnityEngine.Rendering
		{
			[Flags]
			public enum ColorWriteMask
			{
				Alpha = 1,
				Blue = 2,
				Green = 4,
				Red = 8,
				All = 15
			}
		}
		*/
		ColorMask[_ColorMask]

		Pass
		{
			Name "Default"
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			#include "UnityUI.cginc"

			//这两个宏目的是对unity的rect mask 2d 裁剪生效
			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			fixed4 _Color;
			fixed4 _TextureSampleAdd;
			float4 _ClipRect;
			float4 _MainTex_ST;

			v2f vert(appdata_t v)
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				OUT.worldPosition = v.vertex;
				OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

				OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

				OUT.color = v.color * _Color;
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;

				#ifdef UNITY_UI_CLIP_RECT

				//inline float UnityGet2DClipping(in float2 position, in float4 clipRect)
				//{
				//	// 判断当前点是否在矩形中，返回inside.x * inside.y 如果有任意一点不在那么返回值为0
				//	float2 inside = step(clipRect.xy, position.xy) * step(position.xy, clipRect.zw);
				//	return inside.x * inside.y;
				//}

				color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
				#endif

				#ifdef UNITY_UI_ALPHACLIP
				clip(color.a - 0.001);
				#endif

				return color;
			}
		ENDCG
		}
		}
}