Shader "Workbook/05 Gradient with Start and End Positions"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 0, 1)
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _Scale ("UV Scale", Float) = 1
        _Offset ("UV Offset", Float) = 0
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color; // 1
            float4 _ColorA; // 2
            float4 _ColorB;
            float _ColorStart; // 3
            float _ColorEnd;
            float _Scale; // 4
            float _Offset; // 5

            // Per-vertex mesh data:
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;

                // Other possible data we can capture:
                // float4 tangent : TANGENT;
                // float4 color : COLOR;
                // float2 uv1 : TEXCOORD1;
            };

            // Per-fragment interpolated data:
            struct Interpolated
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            // Data type precision:
            // * float (32 bit float)
            // * half (16 bit float)
            // * fixed (lower precision, accurate for -1 to 1)

            // InverseLerp takes a start value `a`, an end value `b`, and a value `v`,
            // and returns the ratio of `v`'s covered distance between `a` and `b`.
            //
            // This is not built into Unity, so we need to define ourselves.
            float InverseLerp(float a, float b, float v)
            {
                return (v-a) / (b-a);
            }

            Interpolated vert (MeshData v)
            {
                Interpolated o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                o.normal = UnityObjectToWorldNormal(v.normal); // Transforms normal from object space to world space.
                o.uv = (v.uv0 + _Offset) * _Scale; // Passthrough.
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                // Return a passed-in color.
                // return _Color;

                // Gives a "mango sphere" effect.
                // return float4(i.normal, 1.0); // outputs mango spheres

                // Blend between 2 colors based on the x UV coordinate.
                // float4 outColor = lerp(_ColorA, _ColorB, i.uv.x);
                // return outColor;

                // Visualize UV coordinates.
                // return float4(i.uv, 1.0, 1.0);

                // Change where gradient starts and ends. Note that _ColorStart and _ColorEnd are values between [0,1].
                // float t = InverseLerp(_ColorStart, _ColorEnd, i.uv.x); // i.uv.x isn't clamped to [0,1], need to clamp.
                // if <0, make it 0. if >1, make it 1. same as Clamp01 in Unity
                float t = saturate(InverseLerp(_ColorStart, _ColorEnd, i.uv.x)); // i.uv.x isn't clamped to [0,1], need to clamp.
                // t = frac(t);
                return t;
                // float4 outColor = lerp(_ColorA, _ColorB, t);
                // return outColor;
            }
            ENDCG
        }
    }
}
