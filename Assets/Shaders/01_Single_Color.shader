Shader "Workbook/01 Single Color"
{
    Properties
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
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

            // Inputs:
            float4 _Color;

            // Per-vertex mesh data:
            struct MeshData
            {
                float4 vertex : POSITION;
            };

            // Per-fragment interpolated data:
            struct Interpolated
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolated vert (MeshData v)
            {
                Interpolated o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
