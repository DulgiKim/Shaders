// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Custom/CurvedParticleAdditive" 
{
    Properties 
    {
        _MainTex ("Particle Texture", 2D) = "white" {}
    }
    SubShader 
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
           
        CGPROGRAM
        #pragma exclude_renderers flash
        #pragma surface surf Lambert vertex:vert noforwardadd
                      
        ///Vertex
		half _CurvatureX;
		half _CurvatureY;

        struct Input {
            float2 uv_MainTex;
            float4 color : Color;
        };

        void vert (inout appdata_full v, out Input o) 
        {
            UNITY_INITIALIZE_OUTPUT(Input,o);
			float4 worldPosition = mul(unity_ObjectToWorld, v.vertex); // get world space position of vertex
			half2 wpToCam = _WorldSpaceCameraPos.z - worldPosition.z; // get vector to camera and dismiss vertical component
			half distance = dot(wpToCam, wpToCam); // distance squared from vertex to the camera, this power gives the curvature
			worldPosition.x -= distance * _CurvatureX; // offset horizontal position by factor and square of distance.
			worldPosition.y -= distance * _CurvatureY; // offset vertical position by factor and square of distance.
			// the default 0.01 would lower the position by 1cm at 1m distance, 1m at 10m and 100m at 100m
			v.vertex = mul(unity_WorldToObject, worldPosition); // reproject position into object space

            o.color = v.color;
        }
       
        ///Surface
        sampler2D _MainTex;

        void surf (Input IN, inout SurfaceOutput o) {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * IN.color.rgb;
            o.Alpha = c.a * IN.color.a;
        }
           
        ENDCG
    }
}
