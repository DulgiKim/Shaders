// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/CurvedDiffuse" 
{
    Properties 
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert 
        #pragma target 3.0

        ///Vertex
		half _CurvatureX;
		half _CurvatureY;

        struct Input 
        {
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

        ///Surface
        sampler2D _MainTex;
        fixed4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
}
