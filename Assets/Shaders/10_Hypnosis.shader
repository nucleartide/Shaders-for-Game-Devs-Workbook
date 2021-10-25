Shader "Workbook/10 Hypnosis"
{
    Properties
    {
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #define TAU 6.28318530718

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
            };

            float GetWave(float2 uv)
            {
                float2 distFromCenter = length(uv * 2 - 1);
                float wave = cos((distFromCenter - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                wave *= 1-distFromCenter;
                return wave;
            }

            Interpolated vert (MeshData v)
            {
                Interpolated o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv0;
                return o;
            }

            float4 frag (Interpolated i) : SV_Target
            {
                return GetWave(i.uv);
            }

            ENDCG
        }
    }
}
