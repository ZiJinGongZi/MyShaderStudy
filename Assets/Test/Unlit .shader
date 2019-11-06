Shader "Unlit" {
	Properties{
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
		SubShader{
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
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off//关掉光照，一般ui的shader为提高效率都会这样设置
		ZWrite Off
			//下面两句设置ZTest只根据ui节点的树层次（即在Hierarchy视图中的层次）作为依据进行测试，不根据z值
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha//最终颜色值 = 输出颜色值 * 输出颜色Alpha值a + 背景颜色值 * (1 - a)，即如果有透明物品挡在前面的话，类似隔着透明玻璃看东西那种效果
		ColorMask[_ColorMask]

			Pass {
			/*SetTexture[_MainTex] {
				constantColor [_Color]
				Combine texture * constant, texture * constant
			}*/

			CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"
#include "UnityUI.cginc"
			#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
			#pragma multi_compile_local _ UNITY_UI_ALPHACLIP

			sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		fixed4 _TextureSampleAdd;

		struct a2v {
			float4 vertex : POSITION;
			float2 texcoord:TEXCOORD0;
			fixed4 color : COLOR;
		};

		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
			fixed4 color : COLOR;
		};

		v2f vert(a2v v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			i.color = v.color * _Color;
			return i;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			fixed4 color = (tex2D(_MainTex,i.uv) + _TextureSampleAdd) * i.color;
		return color;
		}

			ENDCG
		}
		}
			FallBack Off
}