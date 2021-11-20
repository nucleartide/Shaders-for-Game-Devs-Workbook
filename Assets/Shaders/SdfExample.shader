Shader "Unlit/SdfExample"
{
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
    float4 vertex : SV_POSITION;
};

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv *2 - 1;
    return o;
}

/**
 * signed distance fields example
  */
fixed4 frag (Interpolators i) : SV_Target
{
    // float len = length(i.uv) - 0.3;
    // float len = i.uv.x - 0.3;
    // return float4(len.xxx, 0);
    // return step(0, len);

    return float4(i.uv, 0, 0);
}
            ENDCG
        }
    }
}

// easy way to add rounded borders: apply a texture

/*
how to get the distance to a line segment (in order to get the rounded corners distance field)
*/
