Shader "Unlit/freya_lighting"
{
    Properties
    {
        _Gloss ("Gloss", Float) = 1
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
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct MeshData
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct Interpolators
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float _Gloss;

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    return o;
}

fixed4 frag (Interpolators i) : SV_Target
{
    // diffuse lighting
    float3 N = normalize(i.normal); // because the normal is not necessarily normalized when interpolated
    float3 L = _WorldSpaceLightPos0.xyz; // actually a direction
    // float diffuseLight = max(0, dot(N, L)); // saturate() does the same as max(0, ...)
    float3 diffuseLight = saturate(dot(N, L)) * _LightColor0.xyz;

    // specular lighting
    float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
    float3 R = reflect(-L, N);
    float3 specularLight = saturate(dot(V, R));

    specularLight = pow(specularLight, _Gloss); // sometimes called the specular exponent

    return float4(specularLight.xxx, 1);

    return float4(diffuseLight, 1);
}
            ENDCG
        }
    }
}

/*

specular lighting, two types before physically based era

Phong specular highlights
    dot(R,V)

Blinn-Phong

*/
