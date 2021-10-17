Shader "Workbook/02 Mango"
{
    Properties
    {
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

            // Per-vertex mesh data:
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            // Per-fragment interpolated data:
            struct Interpolated
            {
                float4 vertex : POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolated vert (MeshData v)
            {
                Interpolated o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                o.normal = UnityObjectToWorldNormal(v.normal); // Transforms normal from object space to world space.
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                return float4(i.normal, 1.0);
            }
            ENDCG
        }
    }
}
