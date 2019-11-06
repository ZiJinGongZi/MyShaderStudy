Shader "Custom/My/15/WaterWave"
{
	Properties
	{
		_Color("Color", Color) = (1,0.15,0.115,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_WaveMap("Wave Map", 2D) = "bump" {}
		_CubeMap("Enviroment Cubemap", Cube) = "_Skybox" {}
		_WaveXSpeed("Wave Horizontal Speed", Range(-0.1,0.1)) = 0.01
		_WaveYSpeed("Wave Vertical Speed", Range(-0.1,0.1)) = 0.01
			//模拟折射时图像的扭曲程度，_Distortion值越大，偏移量越大，水面背后的物体看起来变形程度越大。
			_Distortion("Distortion", Range(0,100)) = 10
	}
		SubShader
		{
			Tags {"Queue" = "Transparent" "RenderType" = "Opaque" }

			GrabPass {"_ReflectionTex"}

			Pass
			{
			Tags{"LightMode" = "ForwardBase"}

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
#pragma multi_compile_fwdbase

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _WaveMap;
				float4 _WaveMap_ST;
				samplerCUBE _CubeMap;
				fixed _WaveXSpeed;
				fixed _WaveYSpeed;
				float _Distortion;
				sampler2D _ReflectionTex;
				float4 _ReflectionTex_TexelSize;

				struct a2v {
					float4 vertex:POSITION;
					float4 texcoord:TEXCOORD0;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
				};
				struct v2f {
					float4 pos:SV_POSITION;
					float4 scrPos:TEXCOORD0;
					float4 uv :TEXCOORD1;
					float4 TtoW0:TEXCOORD2;
					float4 TtoW1:TEXCOORD3;
					float4 TtoW2:TEXCOORD4;
				};
				v2f vert(a2v v)
				{
					v2f i;
					i.pos = UnityObjectToClipPos(v.vertex);
					i.scrPos = ComputeGrabScreenPos(i.pos);
					i.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
					i.uv.zw = TRANSFORM_TEX(v.texcoord, _WaveMap);

					//这个是正确的写法，专门处理点的转换方式
					float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					//这个是错误的写法，这个是专门用于处理方向向量的写法，用于处理点的转换会得到错误的结果
					//这个相对于 mul(unity_ObjectToWorld, v.vertex).xyz 多做了一个normalize的操作
					//float3 worldPos = UnityObjectToWorldDir(v.vertex.xyz);
					fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
					fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
					fixed3 worldBinormal = cross(worldNormal, worldTangent)* v.tangent.w;

					i.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
					i.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
					i.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
					return i;
				}

				fixed4 frag(v2f i) :SV_Target
				{
					float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
					float2 speed = _Time.y * float2 (_WaveXSpeed, _WaveYSpeed);

					//这是为了模拟两层交叉的水面波动的效果
					fixed3 bump1 = UnpackNormal(tex2D(_WaveMap, i.uv.zw + speed)).rgb;
					fixed3 bump2 = UnpackNormal(tex2D(_WaveMap, i.uv.zw - speed)).rgb;
					fixed3 bump = normalize(bump1 + bump2);
					//fixed3 bump = normalize(bump2);

					//这里选择使用切线空间下的法线方向来进行偏移是因为该空间下的法线可以反映顶点局部空间下的法线方向
					float2 offset = bump.xy * _Distortion * _ReflectionTex_TexelSize.xy;
					//乘以屏幕坐标的z分量是为了模拟深度越大、折射程度越大的效果
					i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
					fixed3 refrCol = tex2D(_ReflectionTex, i.scrPos.xy / i.scrPos.w).rgb;

					bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
					fixed4 texColor = tex2D(_MainTex, i.uv.xy + speed);
					fixed3 reflDir = reflect(-viewDir, bump);
					fixed3 reflCol = texCUBE(_CubeMap, reflDir).rgb * texColor.rgb * _Color.rgb;

					fixed fresnel = pow(1 - saturate(dot(viewDir, bump)), 4);
					fixed3 finalColor = reflCol * fresnel + refrCol * (1 - fresnel);
					return fixed4(finalColor, 1);
				}

				ENDCG
	}
		}
			FallBack Off
}