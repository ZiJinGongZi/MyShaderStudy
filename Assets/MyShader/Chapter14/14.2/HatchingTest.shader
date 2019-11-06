Shader "Custom/My/14/HatchingTest"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		_Outline("Outline", Float) = 0.5
		_TileFactor("Tile Factor", Float) = 0.0
		_Hatch0("Hatch 0", 2D) = "white" {}
		_Hatch1("Hatch 1", 2D) = "white" {}
		_Hatch2("Hatch 2", 2D) = "white" {}
		_Hatch3("Hatch 3", 2D) = "white" {}
		_Hatch4("Hatch 4", 2D) = "white" {}
		_Hatch5("Hatch 5", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }

		UsePass "Custom/My/ToonShading/OUTLINE"

		Pass
	{
		Tags{"LightMode" = "ForwardBase"}
		Cull Back

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
#include "AutoLight.cginc"
#include "UnityCG.cginc"
#pragma multi_compile_fwdbase

		fixed4 _Color;
		half _TileFactor;
		sampler2D _Hatch0;
		sampler2D _Hatch1;
		sampler2D _Hatch2;
		sampler2D _Hatch3;
		sampler2D _Hatch4;
		sampler2D _Hatch5;

		struct a2v {
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD0;
			float3 normal:NORMAL;
		};
		struct v2f {
			float4 pos:SV_POSITION;
			float2 uv:TEXCOORD0;
			float3 hatchWeight0:TEXCOORD1;
			float3 hatchWeight1:TEXCOORD2;
			float3 worldPos:TEXCOORD3;
			SHADOW_COORDS(4)
		};
		v2f vert(a2v v) {
			v2f i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv = v.texcoord.xy * _TileFactor;

			fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			fixed3 worldLightDir = normalize(WorldSpaceLightDir(v.vertex));
			float diff = dot(worldLightDir, worldNormal);
			float hatchFactor = diff * 7;

			i.hatchWeight0 = float3(0, 0, 0);
			i.hatchWeight1 = float3(0, 0, 0);

			if (hatchFactor > 6)
			{
}
else if (hatchFactor > 5) {
	i.hatchWeight0.x = hatchFactor - 5;
}
else if (hatchFactor > 4) {
	i.hatchWeight0.x = hatchFactor - 4;
	i.hatchWeight0.y = 1 - i.hatchWeight0.x;
}
else if (hatchFactor > 3) {
	i.hatchWeight0.y = hatchFactor - 3;
	i.hatchWeight0.z = 1 - i.hatchWeight0.y;
}
else if (hatchFactor > 2) {
	i.hatchWeight0.z = hatchFactor - 2;
	i.hatchWeight1.x = 1 - i.hatchWeight0.z;
}
else if (hatchFactor > 1)
{
	i.hatchWeight1.x = hatchFactor - 1;
	i.hatchWeight1.y = 1 - i.hatchWeight1.x;
}
else {
	i.hatchWeight1.y = hatchFactor;
	i.hatchWeight1.z = 1 - i.hatchWeight1.y;
}

			TRANSFER_SHADOW(i);
			i.worldPos = UnityObjectToWorldDir(v.vertex.xyz);

return i;
}
fixed4 frag(v2f i) :SV_Target
{
	fixed4 hatchColor0 = tex2D(_Hatch0, i.uv) * i.hatchWeight0.x;
	fixed4 hatchColor1 = tex2D(_Hatch1, i.uv) * i.hatchWeight0.y;
	fixed4 hatchColor2 = tex2D(_Hatch2, i.uv) * i.hatchWeight0.z;
	fixed4 hatchColor3 = tex2D(_Hatch3, i.uv) * i.hatchWeight1.x;
	fixed4 hatchColor4 = tex2D(_Hatch4, i.uv) * i.hatchWeight1.y;
	fixed4 hatchColor5 = tex2D(_Hatch5, i.uv) * i.hatchWeight1.z;

	fixed4 whiteColor = fixed4(1, 1, 1, 1) * (1 - i.hatchWeight0.x - i.hatchWeight0.y
		- i.hatchWeight0.z - i.hatchWeight1.x - i.hatchWeight1.y - i.hatchWeight1.z);

	fixed4 fatchColor = whiteColor + hatchColor0 + hatchColor1 + hatchColor2 + hatchColor3
		+ hatchColor4 + hatchColor5;
	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

	return fixed4(fatchColor.rgb * _Color.rgb * atten, 1.0);
}

		ENDCG
}
	}
		FallBack "Diffuse"
}