Shader "Unlit/NewUnlitShader"
{
    Properties
    {
		_Value ("Value", Float) = 1.0
		_ColorA ("Color A", Color) = (1, 1, 1, 1)
		_ColorB ("Color B", Color) = (1, 1, 1, 1)
        _Scale ("UV Scale", Float) = 1
        _Offset ("UV Offset", Float) = 0
		_ColorStart ("Color Start", Range(0,1)) = 0
		_ColorEnd ("Color End", Range(0,1)) = 1
    }

// red material
// green material
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Value;
			float4 _ColorA;
			float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
			// float _Scale;
            // float _Offset;

			// Per-vertex mesh data.
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                // float4 tangent : TANGENT;
                // float4 color : COLOR;
                float2 uv0 : TEXCOORD0;
                // float2 uv1 : TEXCOORD1;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            // float (32 bit float)
            // half (16 bit float)
            // fixed (lower precision), -1 to 1

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                /* o.normal = v.normal; */
                o.normal = UnityObjectToWorldNormal(v.normal); // Could do this in fragment shader, but runs less frequently in vertex shader.
                // o.uv = (v.uv0 + _Offset) * _Scale; // passthrough
                o.uv = v.uv0;
                return o;
            }
            float InverseLerp(float a, float b, float v)
            {
            return (v-a) / (b-a);
			}


            float4 frag (Interpolators i) : SV_Target
            {
				// return float4(1, 0, 0, 1); // red
				// return _Color;
            // return float4(i.normal, 1.0); // outputs mango spheres
            // lerp

// blend between 2 colors based on the X UV coordinate
            // float4 outColor = lerp(_ColorA, _ColorB, i.uv.x);
			// return outColor;

// return i.uv.x;

            /* change where gradient starts and ends. */
			float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x); // i.uv.x isn't clamped to [0,1], need to clamp
            float4 outColor = lerp(_ColorA, _ColorB, t);
			return outColor;

			// map the UVs to red and green
            // return float4(i.uv, 1.0, 1.0);
            }

/* not built into Unity, so we need to define ourselves */
            ENDCG
        }
    }
}
