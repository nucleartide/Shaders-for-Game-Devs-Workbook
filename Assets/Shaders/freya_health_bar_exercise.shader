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
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float _Health;
            float4 _StartColor;
            float4 _EndColor;
            float _CriticalThreshold;
            float _HealthyThreshold;

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
                o.uv = v.uv;
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



// https://theorangeduck.com/page/avoiding-shader-conditionals
            float4 frag (Interpolators i) : SV_Target
            {
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
                float4 finalColor = float4(amountOfRed, amountOfGreen, 0, 1);
                return finalColor;
            }
            ENDCG
        }
    }
}
