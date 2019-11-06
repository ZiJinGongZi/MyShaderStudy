// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
//在Unity 2018版本，_MainTex 或 _Ramp 必须其中一个在Unity面板中赋值，否则显示结果不是预期效果，Unity2017中不会出现这个问题，即可以保持为空

Shader "Custom/My/14/ToonShading"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	//用于控制漫反射色调的渐变纹理
	_Ramp("Ramp Texture", 2D) = "white" {}
	//用于控制轮廓线宽度
	_Outline("Outline", Range(0,1)) = 0.1
		//轮廓线颜色
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		//用于控制计算高光反射时使用的阈值
		_SpecularScale("Specular Scale", Range(0,0.1)) = 0.01
	}
		SubShader
	{
		Pass
	{
		NAME "OUTLINE"

		Cull Front
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
		#include "UnityCG.cginc"

		half _Outline;
	fixed4 _OutlineColor;

		struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
};

	struct v2f {
		float4 pos:SV_POSITION;
	};

		v2f vert(a2v v)
	{
		v2f i;

		float4 pos = float4(UnityObjectToViewPos(v.vertex),1);
		float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
		normal.z = -0.5;
		pos = pos + float4(normalize(normal), 0) * _Outline;
		i.pos = mul(UNITY_MATRIX_P, pos);

		return i;
}

		fixed4 frag(v2f i) :SV_Target{
			return float4(_OutlineColor.rgb,1);
		}

			ENDCG
	}

		Pass{
					Tags{"LightMode" = "Forwardbase"}

					Cull Back

					CGPROGRAM

			#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_fwdbase
#include "Lighting.cginc"
#include "AutoLight.cginc"

					sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		sampler2D _Ramp;
		fixed4 _Specular;
		float _SpecularScale;

			struct a2v {
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD0;
			float3 normal:NORMAL;
};

			struct v2f {
			float4 pos:SV_POSITION;
			float2 uv : TEXCOORD0;
			float3 worldNormal : TEXCOORD1;
			float3 worldPos  :TEXCOORD2;
			SHADOW_COORDS(3)
};

		v2f vert(a2v v)
		{
			v2f i;

			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			i.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
			i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

			TRANSFER_SHADOW(i);

			return i;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			fixed3 worldNormal = normalize(i.worldNormal);
		fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);

		fixed4 c = tex2D(_MainTex, i.uv);
		fixed3 albedo = c.rgb * _Color.rgb;

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz *albedo;

		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

		fixed diff = dot(worldNormal, worldLightDir);
		//(diff * 0.5 + 0.5)：半兰伯特反射系数  (diff * 0.5 + 0.5) * atten：最终的反射系数
		diff = (diff * 0.5 + 0.5) * atten;

		//基于色调的着色技术中，基于色调的光照模型在实现中，往往使用漫反射系数对一张一维纹理进行采样，以控制漫反射的色调
		fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;

		fixed spec = dot(worldNormal, worldHalfDir);
		//相邻像素之间的近似导数值
		fixed w = fwidth(spec) * 2.0;
		//step：第一个参数是参考值，第二个参数是待比较的值，如果第二个参数大于第一个参数，则返回1，否则返回0
		//smoothstep：w是一个很小的值，当spec-threshod小于-w时，返回0，大于w时，返回1，否则在0到1之间进行差值
		fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1))*step(0.0001, _SpecularScale);

		return fixed4(ambient + diffuse + specular, 1.0);
		}

			ENDCG
}
	}
		FallBack "Diffuse"
}