﻿/*
*	Copyright (c) 2017-2018. RainyRizzle. All rights reserved
*	contact to : https://www.rainyrizzle.com/ , contactrainyrizzle@gmail.com
*
*	This file is part of AnyPortrait.
*
*	AnyPortrait can not be copied and/or distributed without
*	the express perission of Seungjik Lee.
*/



Shader "AnyPortrait/Editor/Rig Circle (v2)"
{
	Properties
	{
		_MainTex("Albedo (RGBA)", 2D) = "white" {}						// Main Texture controlled by AnyPortrait
		_ScreenSize("Screen Size (xywh)", Vector) = (0, 0, 1, 1)		// ScreenSize for clipping in Editor
	}
		SubShader{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		
		//Cull Off

		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf SimpleColor alpha

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		half4 LightingSimpleColor(SurfaceOutput s, half3 lightDir, half atten)
		{
			half4 c;
			c.rgb = s.Albedo;
			c.a = s.Alpha;
			return c;

		}

		sampler2D _MainTex;
		float4 _ScreenSize;

		struct Input
		{
			float2 uv_MainTex;
			float4 color : COLOR;
			float4 screenPos;
		};


		void surf(Input IN, inout SurfaceOutput o)
		{
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			screenUV.y = 1.0f - screenUV.y;

			half4 c = tex2D(_MainTex, IN.uv_MainTex);
			//c = Red일때 > IN.color
			//c = Blue일 때 > 검은색
			//c = Green일때 > 하얀색 (살짝 반투명)
			//c = Black일때 > 투명색
			half4 redCh = IN.color;
			redCh.a = 1.0f;
			
			half4 greenCh = half4(1, 1, 1, 0.8f);
			half4 blueCh = half4(0, 0, 0, 0.8f);
			half4 blackCh = half4(0, 0, 0, 0);

			half4 result = (redCh * c.r) + (greenCh * c.g) + (blueCh * c.b) + (blackCh * (1.0f - saturate(c.r + c.g + c.b)));
			result.a *= IN.color.a;//전체 투명도

			o.Alpha = result.a;

			if (screenUV.x < _ScreenSize.x || screenUV.x > _ScreenSize.z)
			{
				o.Alpha = 0;
				discard;
			}
			if (screenUV.y < _ScreenSize.y || screenUV.y > _ScreenSize.w)
			{
				o.Alpha = 0;
				discard;
			}
			
			o.Albedo = result.rgb;
			//o.Albedo = mainColor;
		}
		ENDCG

	}
	FallBack "Diffuse"
}
