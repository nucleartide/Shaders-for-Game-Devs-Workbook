Shader "Workbook/03 UV Visualization"
{
    Properties
    {
        _Offset ("UV Offset", Float) = 0
        _Scale ("UV Scale", Float) = 1
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

            float _Offset;
            float _Scale;

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
                o.uv = (v.uv0 + _Offset) * _Scale; // Apply offset and scale to UVs.
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                // Visualize UV coordinates using the red and green channels.
                return float4(i.uv, 1.0, 1.0);
            }
            ENDCG
        }
    }
}
