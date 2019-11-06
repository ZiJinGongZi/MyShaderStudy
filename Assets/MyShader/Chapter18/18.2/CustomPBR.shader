Shader "Custom/My/18/Custom PBR"
{
	Properties
	{
		//_MainTex 和 _Color 用于控制漫反射项中的材质纹理和颜色
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	//_SpecGlossMap 的 A 通道值和_Glossiness 用于共同控制材质的粗糙度
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		//_SpecColor 和_SpecGlossMap 的 RGB 通道值用于控制材质的高光反射颜色
		_SpecColor("Specular", Color) = (0.2,0.2,0.2)
		_SpecGlossMap("Specular (RGB) Smoothness (A)",2D) = "White"{}
	//_BumpMap 则是材质的法线纹理，它的凹凸程度可以依靠_BumpScale 属性来控制
	_BumpScale("Bump Scale", Float) = 1
	_BumpMap("Normal Map",2D) = "bump" {}
	//_EmissionColor 和_EmissionMap 用于控制材质的自发光颜色
	_EmissionColor("Emission Color",Color) = (0,0,0)
	_EmissionMap("Emission Map", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 300

		Pass
	{
		Tags{"LightMode" = "ForwardBase"}

		CGPROGRAM
#pragma target 3.0
#pragma multi_compile_fwdbase
#pragma multi_compile_fog
#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

			fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	half _Glossiness;

	sampler2D _SpecGlossMap;
	half _BumpScale;
		sampler2D _BumpMap;
		fixed4 _EmissionColor;
		sampler2D _EmissionMap;

		struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
		float4 tangent:TANGENT;
		float4 texcoord:TEXCOORD0;
};

		struct v2f {
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
		float4 TtoW0:TEXCOORD1;
		float4 TtoW1:TEXCOORD2;
		float4 TtoW2:TEXCOORD3;
		SHADOW_COORDS(4)    // Defined in AutoLight.cginc
		UNITY_FOG_COORDS(5) // Defined in UnityCG.cginc
};

	v2f vert(a2v v)
	{
		v2f i;
		UNITY_INITIALIZE_OUTPUT(v2f, i); // Defined in HLSLSupport.cginc

		i.pos = UnityObjectToClipPos(v.vertex); // Defined in UnityCG.cginc
		i.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // Defined in UnityCG.cginc

		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
		fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
		fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

		i.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
		i.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
		i.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

		TRANSFER_SHADOW(i); // Defined in AutoLight.cginc

		//We need this for fog rendering
		UNITY_TRANSFER_FOG(i, i.pos); // Defined in UnityCG.cginc

		return i;
	}

	//inline 的作用是告诉编译器应该尽可能使用内联调用的方式来调用函数，减少函数调用的开销。
	inline half3 CustomDisneyDiffuseTerm(half NdotV, half NdotL, half LdotH, half roughness, half3 baseColor)
	{
		half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;

		half lightScatter = (1 + (fd90 - 1) * pow(1 - NdotL, 5));
		half viewScatter = (1 + (fd90 - 1) * pow(1 - NdotV, 5));

		return baseColor * UNITY_INV_PI * lightScatter * viewScatter; //UNITY_INV_PI Defined in UnityCG.cginc 即圆周率的倒数
	}

	inline half CustomSmithJointGGXVisibilityTerm(half NdotL, half NdotV, half roughness)
	{
		//Original Formulation
		//lambda_v = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5;
		//lambda_l = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5;
		//G = 1 / (1 + lambda_v +lambda_l);

		//Approximation of the above formulation(simplify the sqrt,not mathematically correct but close enough)
		half a2 = roughness * roughness;
		half lambdaV = NdotL * (NdotV * (1 - a2) + a2);
		half lambdaL = NdotV * (NdotL * (1 - a2) + a2);

		return 0.5f / (lambdaV + lambdaL + 1e-5f);
	}

	//法线分布函数
	inline half CustomGGXTerm(half NdotH, half roughness)
	{
		half a2 = roughness * roughness;
		half d = (NdotH * a2 - NdotH) * NdotH + 1;
		return UNITY_INV_PI * a2 / (d * d + 1e-7f);
	}

	inline half3 CustomFresnelTerm(half3 c, half cosA)
	{
		half t = pow(1 - cosA, 5);
		return c + (1 - c) * t;
	}

	inline half3 CustomFresnelLerp(half3 c0, half3 c1, half cosA)
	{
		half t = pow(1 - cosA, 5);
		return lerp(c0, c1, t);
	}

	half4 frag(v2f i) :SV_Target
	{
		half4 specGloss = tex2D(_SpecGlossMap,i.uv);
		specGloss.a *= _Glossiness;
		half3 specColor = specGloss.rgb * _SpecColor.rgb;
		half roughness = 1 - specGloss.a;

		//为了计算掠射角的反射颜色，从而得到效果更好的菲涅耳反射效果。
		//因为大多数金属是单色或带有红/黄色调
		half oneMinusReflectivity = 1 - max(max(specColor.r, specColor.g), specColor.b);

		half3 diffColor = _Color.rgb * tex2D(_MainTex, i.uv).rgb * oneMinusReflectivity;

		half3 normalTangent = UnpackNormal(tex2D(_BumpMap, i.uv));
		normalTangent.xy *= _BumpScale;
		normalTangent.z = sqrt(1 - dot(normalTangent.xy, normalTangent.xy));
		half3 normalWorld = normalize(half3(dot(i.TtoW0.xyz, normalTangent), dot(i.TtoW1.xyz, normalTangent), dot(i.TtoW2.xyz, normalTangent)));

		float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
		half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos)); // Defined in UnityCG.cginc
		half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); // Defined in UnityCG.cginc

		half3 reflDir = reflect(-viewDir, normalWorld);

		UNITY_LIGHT_ATTENUATION(atten, i, worldPos); // Defined in AutoLight.cginc

		//计算BRDF部分
		half3 halfDir = normalize(lightDir + viewDir);
		//截取到[0, 1]之间，来避免背光面的光照。
		half nv = saturate(dot(normalWorld, viewDir));
		half nl = saturate(dot(normalWorld, lightDir));
		half nh = saturate(dot(normalWorld, halfDir));
		half lv = saturate(dot(lightDir, viewDir));
		half lh = saturate(dot(lightDir, halfDir));

		//漫反射部分
		half3 diffuseTerm = CustomDisneyDiffuseTerm(nv, nl, lh, roughness, diffColor);

		//高光部分
		//阴影-遮掩函数除以高光反射项的分母部分后的结果
		half V = CustomSmithJointGGXVisibilityTerm(nl, nv, roughness);
		half D = CustomGGXTerm(nh, roughness * roughness);
		half3 F = CustomFresnelTerm(specColor, lh);
		half3 specularTerm = F * V * D;

		//Emission term
		half3 emisstionTerm = tex2D(_EmissionMap, i.uv).rgb * _EmissionColor.rgb;

		//IBL
		//材质粗糙度
		/*
		第一行是采样用的粗糙度的计算，Unity的粗糙度和采样的mipmap等级关系不是线性的，
		Unity内使用的转换公式为mip = r(1.7 - 0.7r)，这是Unity shader的实现，只是个很接近实际值的拟合曲线，
		真正的计算方式如下：

			float m = roughness*roughness;
			const float fEps = 1.192092896e-07F;
			float n =  (2.0 / max(fEps, m * m)) - 2.0;
			n /= 4;
			roughness = pow( 2 / (n + 2), 0.25);

			你理解为 为了速度 凑了2个数值 做了个拟合曲线
		*/
		half perceptualRoughness = roughness * (1.7 - 0.7 * roughness);
		half mip = perceptualRoughness * 6;
		half4 envMap = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflDir, mip);// HLSLSupport.cginc
		//掠射颜色
		half grazingTerm = saturate((1 - roughness) + (1 - oneMinusReflectivity));
		//
		half surfaceReduction = 1 / (roughness * roughness + 1);
		//尽管grazingTerm被声明为单一维数的half变量，在传递给CustomFresnelLerp时它会自动被转换成half3类型的变量
		//对高光颜色 specColor 和 掠射颜色 grazingTerm 进行菲涅尔差值
		half3 indirectSpecular = surfaceReduction * envMap.rgb * CustomFresnelLerp(specColor, grazingTerm, nv);

		//Combine all togather
		//环境光 + 漫反射项 * 光照衰减
		half3 col = emisstionTerm + UNITY_PI * (diffuseTerm + specularTerm) * _LightColor0.rgb * nl * atten + indirectSpecular;

		UNITY_APPLY_FOG(i.fogCoord, col.rgb);//UnityCG.cginc

		return half4(col, 1);
	}

		ENDCG
}

Pass
{
	Tags{"LightMode" = "ForwardAdd"}

	CGPROGRAM
#pragma target 3.0
#pragma multi_compile_fwdadd
#pragma multi_compile_fog
#pragma vertex vert
#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

			fixed4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	half _Glossiness;

	sampler2D _SpecGlossMap;
	half _BumpScale;
		sampler2D _BumpMap;
		fixed4 _EmissionColor;
		sampler2D _EmissionMap;

		struct a2v {
		float4 vertex:POSITION;
		float3 normal:NORMAL;
		float4 tangent:TANGENT;
		float4 texcoord:TEXCOORD0;
};

		struct v2f {
		float4 pos:SV_POSITION;
		float2 uv:TEXCOORD0;
		float4 TtoW0:TEXCOORD1;
		float4 TtoW1:TEXCOORD2;
		float4 TtoW2:TEXCOORD3;
		SHADOW_COORDS(4)    // Defined in AutoLight.cginc
		UNITY_FOG_COORDS(5) // Defined in UnityCG.cginc
};

	v2f vert(a2v v)
	{
		v2f i;
		UNITY_INITIALIZE_OUTPUT(v2f, i); // Defined in HLSLSupport.cginc

		i.pos = UnityObjectToClipPos(v.vertex); // Defined in UnityCG.cginc
		i.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // Defined in UnityCG.cginc

		float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
		fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
		fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

		i.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
		i.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
		i.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

		TRANSFER_SHADOW(i); // Defined in AutoLight.cginc

		//We need this for fog rendering
		UNITY_TRANSFER_FOG(i, i.pos); // Defined in UnityCG.cginc

		return i;
	}

	//inline 的作用是告诉编译器应该尽可能使用内联调用的方式来调用函数，减少函数调用的开销。
	inline half3 CustomDisneyDiffuseTerm(half NdotV, half NdotL, half LdotH, half roughness, half3 baseColor)
	{
		half fd90 = 0.5 + 2 * LdotH * LdotH * roughness;

		half lightScatter = (1 + (fd90 - 1) * pow(1 - NdotL, 5));
		half viewScatter = (1 + (fd90 - 1) * pow(1 - NdotV, 5));

		return baseColor * UNITY_INV_PI * lightScatter * viewScatter; //UNITY_INV_PI Defined in UnityCG.cginc 即圆周率的倒数
	}

	inline half CustomSmithJointGGXVisibilityTerm(half NdotL, half NdotV, half roughness)
	{
		//Original Formulation
		//lambda_v = (-1 + sqrt(a2 * (1 - NdotL2) / NdotL2 + 1)) * 0.5;
		//lambda_l = (-1 + sqrt(a2 * (1 - NdotV2) / NdotV2 + 1)) * 0.5;
		//G = 1 / (1 + lambda_v +lambda_l);

		//Approximation of the above formulation(simplify the sqrt,not mathematically correct but close enough)
		half a2 = roughness * roughness;
		half lambdaV = NdotL * (NdotV * (1 - a2) + a2);
		half lambdaL = NdotV * (NdotL * (1 - a2) + a2);

		return 0.5f / (lambdaV + lambdaL + 1e-5f);
	}

	//法线分布函数
	inline half CustomGGXTerm(half NdotH, half roughness)
	{
		half a2 = roughness * roughness;
		half d = (NdotH * a2 - NdotH) * NdotH + 1;
		return UNITY_INV_PI * a2 / (d * d + 1e-7f);
	}

	inline half3 CustomFresnelTerm(half3 c, half cosA)
	{
		half t = pow(1 - cosA, 5);
		return c + (1 - c) * t;
	}

	inline half3 CustomFresnelLerp(half3 c0, half3 c1, half cosA)
	{
		half t = pow(1 - cosA, 5);
		return lerp(c0, c1, t);
	}

	half4 frag(v2f i) :SV_Target
	{
		half4 specGloss = tex2D(_SpecGlossMap,i.uv);
		specGloss.a *= _Glossiness;
		half3 specColor = specGloss.rgb * _SpecColor.rgb;
		half roughness = 1 - specGloss.a;

		//为了计算掠射角的反射颜色，从而得到效果更好的菲涅耳反射效果。
		//因为大多数金属是单色或带有红/黄色调
		half oneMinusReflectivity = 1 - max(max(specColor.r, specColor.g), specColor.b);

		half3 diffColor = _Color.rgb * tex2D(_MainTex, i.uv).rgb * oneMinusReflectivity;

		half3 normalTangent = UnpackNormal(tex2D(_BumpMap, i.uv));
		normalTangent.xy *= _BumpScale;
		normalTangent.z = sqrt(1 - dot(normalTangent.xy, normalTangent.xy));
		half3 normalWorld = normalize(half3(dot(i.TtoW0.xyz, normalTangent), dot(i.TtoW1.xyz, normalTangent), dot(i.TtoW2.xyz, normalTangent)));

		float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
		half3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos)); // Defined in UnityCG.cginc
		half3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); // Defined in UnityCG.cginc

		half3 reflDir = reflect(-viewDir, normalWorld);

		UNITY_LIGHT_ATTENUATION(atten, i, worldPos); // Defined in AutoLight.cginc

		//计算BRDF部分
		half3 halfDir = normalize(lightDir + viewDir);
		//截取到[0, 1]之间，来避免背光面的光照。
		half nv = saturate(dot(normalWorld, viewDir));
		half nl = saturate(dot(normalWorld, lightDir));
		half nh = saturate(dot(normalWorld, halfDir));
		half lv = saturate(dot(lightDir, viewDir));
		half lh = saturate(dot(lightDir, halfDir));

		//漫反射部分
		half3 diffuseTerm = CustomDisneyDiffuseTerm(nv, nl, lh, roughness, diffColor);

		//高光部分
		//阴影-遮掩函数除以高光反射项的分母部分后的结果
		half V = CustomSmithJointGGXVisibilityTerm(nl, nv, roughness);
		half D = CustomGGXTerm(nh, roughness * roughness);
		half3 F = CustomFresnelTerm(specColor, lh);
		half3 specularTerm = F * V * D;

		//Combine all togather
		//环境光 + 漫反射项 * 光照衰减
		half3 col = UNITY_PI * (diffuseTerm + specularTerm) * _LightColor0.rgb * nl * atten;

		return half4(col, 1);
	}

		ENDCG
}
	}
		FallBack "Diffuse"
}