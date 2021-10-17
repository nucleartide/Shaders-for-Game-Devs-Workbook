Shader "Workbook/05 Gradient with Start and End Positions"
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
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

            // Per-vertex mesh data:
            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            // Per-fragment interpolated data:
            struct Interpolated
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD1;
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

                // Because t isn't clamped to [0,1], clamp using saturate().
                t = saturate(t);

                // An alternative is to use frac(t), which gives a slightly different visualization.
                // t = frac(t);

                // Use the lerp parameter t to interpolate between 2 colors.
                float4 outColor = lerp(_ColorA, _ColorB, t);
                return outColor;
            }
            ENDCG
        }
    }
}
