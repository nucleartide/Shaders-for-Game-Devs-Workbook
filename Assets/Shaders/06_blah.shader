Shader "Workbook/05 Gradient with start and end positions"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1
    }

    SubShader
    {
    // subshader tags
        Tags { "RenderType" = "Opaque" }

		// pass tags
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            // Per-vertex mesh data, auto-filled by Unity
            struct MeshData
            {
                float4 vertex : POSITION; // local space vertex position
                float3 normal : NORMAL; // local space normal direction
                float4 tangent : TANGENT; // tangent direction (xyz), tangent sign (w)
                float4 color : COLOR; // vertex color
                float4 uv0 : TEXCOORD0; // uv0 diffuse/normal map textures
                float4 uv1 : TEXCOORD1; // uv1 coordinates lightmap coordinates
                float4 uv2 : TEXCOORD2; // uv2 coordinates lightmap coordinates
                float4 uv3 : TEXCOORD3; // uv3 coordinates lightmap coordinates
            };

            // Per-fragment interpolated data:
            struct Interpolated
            {
                float4 vertex : SV_POSITION; // clip space position, sole required field
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                // float2 tangent : TEXCOORD2;
                // float2 justSomeValues : TEXCOORD3;
            };

            // InverseLerp takes a start value `a`, an end value `b`, and a value `v`,
            // and returns the ratio of `v`'s covered distance between `a` and `b`.
            //
            // This is not built into GLSL, so we need to define the function ourselves.
            float InverseLerp(float a, float b, float v)
            {
                return (v-a) / (b-a);
            }

            Interpolated vert (MeshData v)
            {
                Interpolated o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                o.uv = v.uv0;
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x);

/*
float t = abs(frac(i.uv.x * 5) * 2 - 1);

can also do:
float t = cos(i.uv.x * 25);

#define TAU

float t = cos(i.uv.x * TAU * 25);

cos(tau * x) -> ensures that something starts and ends with the same value
cos(tau * x) * 0.5 + 0.5 -> shift the range

float2 t = cos(i.uv.xy * TAU * 25) -> experiment with 2 UVs
return float4(t.xy, 0, 1) -> visualizes with red and green
            */
            }
            ENDCG
        }
    }
}
