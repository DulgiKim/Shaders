Shader "Custom/CurvedSpecular" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// extra vertex shader, notice "addshadow" force the shadow pass to use the same curvature effect as the color pass
		#pragma surface surf Standard vertex:vert fullforwardshadows addshadow 
		#pragma target 3.0

		half _CurvatureX;
		half _CurvatureY;

		struct Input {
			float2 uv_MainTex;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float4 worldPosition = mul(unity_ObjectToWorld, v.vertex); // get world space position of vertex
			half2 wpToCam = _WorldSpaceCameraPos.z - worldPosition.z; // get vector to camera and dismiss vertical component
			half distance = dot(wpToCam, wpToCam); // distance squared from vertex to the camera, this power gives the curvature
			worldPosition.x -= distance * _CurvatureX; // offset horizontal position by factor and square of distance.
			worldPosition.y -= distance * _CurvatureY; // offset vertical position by factor and square of distance.
			// the default 0.01 would lower the position by 1cm at 1m distance, 1m at 10m and 100m at 100m
			v.vertex = mul(unity_WorldToObject, worldPosition); // reproject position into object space
		}

		sampler2D _MainTex;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
}