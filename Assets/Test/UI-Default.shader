// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "UI/Default"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

			//����ui�ϵ�shaderһ�㶼��Ҫ�������ģ������߼������ⱻ��mask����ĸ��ڵ�����ʱû����Ч��
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
				"Queue" = "Transparent"//һ��ui����������Ⱦ���У���Զ������Ⱦ
				"IgnoreProjector" = "True"//����ͶӰ��һ��ui��shaderΪ���Ч�ʶ�������Ϊtrue
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"//������Ԥ��ģʽΪ��Ƭ
				"CanUseSpriteAtlas" = "True"//����_MainTex����ʹ��Sprite(2D and UI)���͵���ͼ
			}

			//����ui�ϵ�shaderһ�㶼��Ҫ�������ģ������߼������ⱻ��mask����ĸ��ڵ�����ʱû����Ч��
		Stencil
		{
			/*
			Stencil ��ģ�����/�ɰ���ԣ�:			����Ȳ��ԣ�͸���Ȳ������ƣ�����һ��ƬԪ�Ƿ��ӵ�����Ȳ��ԵıȽ���������Ȼ����У�͸���Ȳ��ԵıȽ϶�������ɫ�����е�ֵ��			��ģ����ԵıȽ�������Stencil�У�����ģ�����Ҫ������Ȳ�����͸���Ȳ��ԣ���fragment����֮ǰ�ͻ�ִ��ģ����ԡ�			Fail ��ģ����Ժ���Ȳ��Զ�ʧ��ʱ�����д���			ZFail ��ģ�����ͨ������Ȳ���ʧ��ʱ�����д���
			*/

			//Ref ���ǲο�ֵ������������ֵʱ����Ѳο�ֵ������ǰ����
			Ref[_Stencil]
			//Comp �ȽϷ���������Ref�ο�ֵ�͵�ǰ���ػ����ϵ�ֵ���бȽϡ�Ĭ��ֵAlways
			Comp[_StencilComp]
			//Pass ��ģ����Ժ���Ȳ��Զ�ͨ��ʱ�����д���
			Pass[_StencilOp]
			//ReadMask �Ե�ǰ�ο�ֵ������ֵ����mask������Ĭ��ֵ255��һ�㲻��
			ReadMask[_StencilReadMask]
			//WriteMask д��Mask������Ĭ��ֵ255��һ�㲻��
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off//�ص����գ�һ��ui��shaderΪ���Ч�ʶ�����������
		ZWrite Off
			//������������ZTestֻ����ui�ڵ������Σ�����Hierarchy��ͼ�еĲ�Σ���Ϊ���ݽ��в��ԣ�������zֵ
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha//������ɫֵ = �����ɫֵ * �����ɫAlphaֵa + ������ɫֵ * (1 - a)���������͸����Ʒ����ǰ��Ļ������Ƹ���͸����������������Ч��

		/*
		ColorMask��ö�ٶ��壺
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

			//��������Ŀ���Ƕ�unity��rect mask 2d �ü���Ч
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
				//	// �жϵ�ǰ���Ƿ��ھ����У�����inside.x * inside.y ���������һ�㲻����ô����ֵΪ0
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