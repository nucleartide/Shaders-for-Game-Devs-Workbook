Shader "freya shader course health bar"
{
    Properties
    {
        _Health ("Health", Range(0,1)) = 0
        _StartColor ("Start Color", Color) = (1, 1, 1, 1)
        _EndColor ("End Color", Color) = (1, 1, 1, 1)
        _CriticalThreshold ("Critical Threshold", Range(0,1)) = 0.2
        // assume that _HealthyThreshold is > _CriticalThreshold
        _HealthyThreshold ("Healthy Threshold", Range(0,1)) = 0.8
        [NoScaleOffset] _HealthBarTexture("Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            // "RenderType"="Opaque"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            ZWrite Off // don't want transparent shaders to write to depth buffer
            Blend SrcAlpha OneMinusSrcAlpha // alpha blending, this is basically a lerp

            CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

float _Health;
float4 _StartColor;
float4 _EndColor;
float _CriticalThreshold;
float _HealthyThreshold;
sampler2D _HealthBarTexture;
float4 _HealthBarTexture_ST; // optional, tiling and offset of texture

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
    o.uv = TRANSFORM_TEX(v.uv, _HealthBarTexture);
    return o;
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

float when_le(float x, float y) {
  return 1.0 - when_gt(x, y);
}

// InverseLerp takes a start value `a`, an end value `b`, and a value `v`,
// and returns the ratio of `v`'s covered distance between `a` and `b`.
//
// This is not built into GLSL, so we need to define the function ourselves.
float InverseLerp(float a, float b, float v)
{
    return (v-a) / (b-a);
}

/// freya's solution, which has a stronger grasp of the transformations involved
float4 solution1(float2 uv)
{
    float health = floor(_Health*8)/8;
    float healthBarMask = health > uv.x;
    clip(healthBarMask - 0.5); // as early as possible fo roptimization

    float tHealthColor = saturate(InverseLerp(0.2, 0.8, _Health));
    float3 healthBarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);

    float3 bgColor = float3(0,0,0);
    float3 outColor = lerp(bgColor, healthBarColor, healthBarMask);

    return float4(outColor, 1);
}

float4 solution2(float2 uv)
{
    float health = floor(_Health*8)/8;
    float healthBarMask = health > uv.x;

    float tHealthColor = saturate(InverseLerp(0.2, 0.8, _Health));
    float3 healthBarColor = lerp(float3(1,0,0), float3(0,1,0), tHealthColor);

    float3 bgColor = float3(0,0,0);
    float3 outColor = lerp(bgColor, healthBarColor, healthBarMask);

    return float4(healthBarColor * healthBarMask, 1);
}

// texture setting clamp mode should not be "wrapped" (which gives you the colors at the end)
// but instead be "clamp", to eliminate the ending colors
float4 solution3(float2 uv)
{
    float healthBarMask = _Health > uv.x;
    float3 healthBarColor = tex2D(_HealthBarTexture, float2(_Health, uv.y));
    return float4(healthBarColor * healthBarMask, 1);
}

// flash when health is less than 20%
float4 solution4(float2 uv)
{
    float healthBarMask = _Health > uv.x;
    float3 healthBarColor = tex2D(_HealthBarTexture, float2(_Health, uv.y));

    if (_Health < 0.2) {
        float flash = cos(_Time.y * 4) * .4 + 1;
        healthBarColor *= flash;
    }

    // multiply to scale the color, instead of potentially changing the hue by adding with +
    return float4(healthBarColor * healthBarMask, 1);
}

float4 solution5(float2 uv)
{
    // rounded cornesr clipping
    float2 coords = uv;
    coords.x *= 8; // make coordinate space uniform, instead of non-uniform (because the mesh is scaled)
    float2 pointOnLineSegment = float2( clamp(coords.x, 0.5, 7.5) , 0.5);
    float sdf = distance(coords, pointOnLineSegment) * 2 - 1;
    clip(-sdf);

    // old stuff
    return solution4(uv);

// for custom radius, you need to find the distance to a rectangle, not just a line segment

}

// https://theorangeduck.com/page/avoiding-shader-conditionals
float4 frag (Interpolators i) : SV_Target
{
    return solution5(i.uv);

    // return solution2(i.uv);
    // if below critical threshold, all red
    // if below healthy threshold, normal formula
    // else, all green

    float t = InverseLerp(_CriticalThreshold, _HealthyThreshold, _Health);
    float amountOfRed = 1 - t;
    float amountOfGreen = t;
    // float minT = max(t, 0);

    // if _Health<=uv.x -> return custom formula
    // else, return black
    float isFill = when_le(i.uv.x, _Health);
    amountOfRed = isFill * (1 - t);
    amountOfGreen = isFill * t;

    // if (!isFill) discard; // alt way using if statement

    // tex2D(_HealthBarTexture, float2(_Health, i.uv.y));
    float3 col = isFill * tex2D(_HealthBarTexture, float2(_Health * .99, i.uv.y));
    float isCritical = when_le(_Health, _CriticalThreshold);
    float alpha = 1-isCritical * sin(_Time.y * 12);
    return float4(col, isFill * alpha);

    float4 finalColor = float4(amountOfRed, amountOfGreen, 0, isFill);
    return finalColor;
}
            ENDCG
        }
    }
}

/*

concept of "mask" in shaders
    single float value changes across pixels

tired, 6:00 in

horizontal space vs linear space
    choose function depending on your mask (linear/horizontal, distance from center (radial gradient), angular gradient)

relatively easy to swap out the input mask, to make a radial health bar, or angular health bar

for a healthbar that increases in chunks, posterize coordintate values - step function?

*/
