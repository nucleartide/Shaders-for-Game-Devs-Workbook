Shader "Unlit/freya_lighting"
{
    Properties
    {
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

struct MeshData
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float2 uv : TEXCOORD0;
};

Interpolators vert (MeshData i)
{
    Interpolators o;
    o.uv = i.uv;
    return o;
}

fixed4 frag (Interpolators i) : SV_Target
{
    return float4(1, 0, 0, 1);
}
            ENDCG
        }
    }
}
