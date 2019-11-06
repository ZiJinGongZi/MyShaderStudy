Shader "Custom/My/10/Reflection"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_ReflectionColor("Reflection Color", Color) = (1,1,1,1)
		_ReflectionAmount("Reflection Amount", Range(0,1)) = 1
		_Cubemap("Reflection Cubemap", Cube) = "_Skybox" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
	   Pass{
		Tags{"LightMode" = "ForwardBase"}

		 CGPROGRAM
#pragma multi_compile_fwdbase
		#pragma vertex vert
		#pragma fragment frag
#include "Lighting.cginc"
#include "AutoLight.cginc"

		fixed4 _Color;
		fixed4 _ReflectionColor;
		half _ReflectionAmount;
		samplerCUBE _Cubemap;

		struct a2v {
			float4 vertex:POSITION;
			float3 normal:NORMAL;
		};

		struct v2f {
			float4 pos:SV_POSITION;
			fixed3 worldNormal : TEXCOORD0;
			float3 worldPos:TEXCOORD1;
			fixed3 worldViewDir : TEXCOORD2;
			float3 worldReflect : TEXCOORD3;
			SHADOW_COORDS(4)
		};

		v2f vert(a2v v)
		{
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.worldNormal = UnityObjectToWorldNormal(v.normal);
			i.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
			i.worldViewDir = UnityWorldSpaceViewDir(i.worldPos);
			i.worldReflect = reflect(-i.worldViewDir, i.worldNormal);
			TRANSFER_SHADOW(i);

			return i;
		}

		fixed4 frag(v2f i) :SV_Target
		{
			fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

		fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

		fixed3 diffuse = _Color.rgb * _LightColor0.rgb *(dot(i.worldNormal, worldLight)*0.5 + 0.5);

		fixed3 reflection = texCUBE(_Cubemap, i.worldReflect).rgb * _ReflectionColor.rgb;

		UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

		fixed3 color = ambient + lerp(diffuse, reflection, _ReflectionAmount) * atten;

		return fixed4(color, 1.0);
		}

		ENDCG
}
	}
		FallBack "Reflective/VertexLit"
}