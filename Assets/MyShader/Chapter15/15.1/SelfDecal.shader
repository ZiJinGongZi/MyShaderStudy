Shader "Decal/SelfDecal"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_DecalTex("Decal", 2D) = "black" {}
	}

		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_decal : TEXCOORD1;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _DecalTex;
			float4 _DecalTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv;
				//offset,tiling二套uv调整不同的decal
				o.uv.zw = TRANSFORM_TEX(v.uv_decal, _DecalTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed4 decal = tex2D(_DecalTex, i.uv.zw);

				col.rgb = lerp(col.rgb, decal.rgb, decal.a);

				return col;
			}
			ENDCG
		}
	}
}
————————————————
版权声明：本文为CSDN博主「puppet_master」的原创文章，遵循 CC 4.0 BY - SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https ://blog.csdn.net/puppet_master/article/details/84310361