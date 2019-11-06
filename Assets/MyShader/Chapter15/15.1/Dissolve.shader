Shader "Custom/My/15/Dissolve"
{
	Properties
	{
		//用于控制消融程度
		_BurnAmount("Burn Amount", Range(0,1)) = 0.0
		//用于控制烧焦效果时的线宽
		_LineWidth("Burn Line Width", Range(0,1)) = 0.0
		//物体原本的漫反射纹理
		_MainTex("Base (RGB)", 2D) = "white" {}
	//物体原本的法线纹理
	_BumpMap("Normal Map", 2D) = "bump" {}
	//火焰边缘颜色
	_BurnFirstColor("Brun First Color", Color) = (1,0,0,1)
		//火焰边缘颜色
		_BurnSecondColor("Burn Second Color", Color) = (1,0,0,1)
		//噪声纹理
		_BurnMap("Burn Map", 2D) = "white" {}
	//模拟烧焦效果相似程度
	_As("As",Float) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Pass
	{
		Tags{"LightMode" = "ForwardBase"}
		Cull Off

		CGPROGRAM

#include "Lighting.cginc"
#include "AutoLight.cginc"
#pragma multi_compile_fwdbase
#pragma vertex vert
#pragma fragment frag

		sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _BumpMap;
	float4 _BumpMap_ST;
	sampler2D _BurnMap;
	float4 _BurnMap_ST;
	half _BurnAmount;
	half _LineWidth;
	fixed4 _BurnFirstColor;
	fixed4 _BurnSecondColor;
	float _As;

		struct a2v {
		float4 vertex:POSITION;
		float4 texcoord:TEXCOORD0;
		float3 normal:NORMAL;
		float4 tangent : TANGENT;
};
	struct v2f {
		float4 pos:SV_POSITION;
		float2 uvMainTex:TEXCOORD0;
		float2 uvBumpMap:TEXCOORD1;
		float2 uvBurnMap:TEXCOORD2;
		float3 lightDir:TEXCOORD3;
		float3 worldPos:TEXCOORD4;
		SHADOW_COORDS(5)
	};

	v2f vert(a2v v)
	{
		v2f i;
		i.pos = UnityObjectToClipPos(v.vertex);

		i.uvMainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
		i.uvBumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
		i.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);

		TANGENT_SPACE_ROTATION;
		i.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

		i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);

		TRANSFER_SHADOW(i);
		return i;
	}

	fixed4 frag(v2f i) :SV_Target
	{
		//对噪声纹理采样
		fixed3 burn = tex2D(_BurnMap,i.uvBurnMap).rgb;
	//返回值范围是0~1，小于消融阈值的像素被剔除
	clip(burn.r - _BurnAmount);

	float3 tangentLightDir = normalize(i.lightDir);
	fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uvBumpMap));

	fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;

	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

	fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

	/* smoothstep( float _Min, float _Max, float _X )  实现平滑过渡，让烧焦区域颜色混合渐变
	若_X 比 _Min，小于返回 0; 若_X 比 _Max 大则返回 1; 在范围 [_Min， _Max]内返回介于 0 和 1 之间的值
	smoothstep 函数用于在一段时间范围内逐渐但非线性地增加属性，如“不透明度”(Opacity)从 0 增加到 1。*/
	//混合系数t，值为0不需要混合，像素为正常模型颜色；值为1表示像素位于消融边界处
	fixed t = 1 - smoothstep(0, _LineWidth, burn.r - _BurnAmount);
	/*插值函数lerp实现颜色渐变过渡  lerp(a, b, w)：a与b为floatX或fixedX等同种类型，返回值是对应同种类型
	当w为0时返回a，为1时返回b，0~1之间，以比重w将a b进行线性插值计算。*/
	fixed3 burnColor = lerp(_BurnFirstColor, _BurnSecondColor, t);
	burnColor = pow(burnColor, _As);

	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
	//Mark！ step(a, x)：Returns (x >= a) ? 1 : 0
	fixed3 finalColor = lerp(ambient + diffuse * atten, burnColor, t*step(0.0001, _BurnAmount));
	return fixed4(finalColor, 1);
	}

		ENDCG
}

//透明度处理的物体的阴影做同样处理，以免被剔除的区域仍会向其他物体投射阴影从而“穿帮”
Pass{
		Tags{"LightMode" = "ShadowCaster"}

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
#pragma multi_compile_shadowcaster
#include "UnityCG.cginc"

		sampler2D _BurnMap;
	float4 _BurnMap_ST;
	float _BurnAmount;

		struct v2f {
			V2F_SHADOW_CASTER;
			float2 uvBurnMap:TEXCOORD1;
		};

		v2f vert(appdata_base v)
		{
			v2f i;
			TRANSFER_SHADOW_CASTER_NORMALOFFSET(i);
			i.uvBurnMap = TRANSFORM_TEX(v.texcoord, _BurnMap);
			return i;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			fixed3 burn = tex2D(_BurnMap,i.uvBurnMap).rgb;
		clip(burn.r - _BurnAmount);
		SHADOW_CASTER_FRAGMENT(i)
		}

		ENDCG
}
	}
		FallBack "Diffuse"
}