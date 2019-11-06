Shader "Unlit" {
	Properties{
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
		SubShader{
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
			Ref[_Stencil]
			Comp[_StencilComp]
			Pass[_StencilOp]
			ReadMask[_StencilReadMask]
			WriteMask[_StencilWriteMask]
		}

		Cull Off
		Lighting Off//�ص����գ�һ��ui��shaderΪ���Ч�ʶ�����������
		ZWrite Off
			//������������ZTestֻ����ui�ڵ������Σ�����Hierarchy��ͼ�еĲ�Σ���Ϊ���ݽ��в��ԣ�������zֵ
		ZTest[unity_GUIZTestMode]
		Blend SrcAlpha OneMinusSrcAlpha//������ɫֵ = �����ɫֵ * �����ɫAlphaֵa + ������ɫֵ * (1 - a)���������͸����Ʒ����ǰ��Ļ������Ƹ���͸����������������Ч��
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