Shader "Workbook/04 Gradient"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
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

            Interpolated vert (MeshData v)
            {
                Interpolated o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                o.uv = v.uv0;
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                // Blend between 2 colors based on the x UV coordinate.
                float4 outColor = lerp(_ColorA, _ColorB, i.uv.x);
                return outColor;
            }
            ENDCG
        }
    }
}
