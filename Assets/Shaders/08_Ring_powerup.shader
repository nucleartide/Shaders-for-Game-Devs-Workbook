Shader "Workbook/08 Ring powerup"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (1, 1, 1, 1)
        _ColorStart ("Color Start", Range(0,1)) = 0
        _ColorEnd ("Color End", Range(0,1)) = 1
    }

    SubShader
    {
        Tags
        {
            // RenderType informs the render pipeline of type.
            // It's mostly for tagging purposes for info in post-process FX.
            "RenderType" = "Transparent"

            // Mark this object as "Transparent" in order to render after opaque objects have rendered.
            // This is appropriate for objects that are additively blended.
            "Queue" = "Transparent"
        }

        Pass
        {
            Cull Back // Back is default value.
            ZWrite Off // Do not write to depth buffer, so as not to mess up the depth buffer for objects behind this one. (This object is supposed to be transparent.)

            /*
                general blend equation:
                    src*a +/- dst*b

                where you choose the constants a and b, as well as +/-

                src color - the computed color of your fragment shader
                dst color - the current color of the screen at a pixel location

                example: additive blending (Blend One One)
                    makes things brighter
                    basically adds colors together
                    useful for fire effects
                    is just src*1 + dst*1

                multiplicative blending (Blend DstColor Zero)
                    is just src*dst + dst*0
            */
            Blend One One

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
            struct Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position, sole required field
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Converts local space to clip space.
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv0;
                return o;
            }

            // Create a ring powerup VFX like in Dragonball Z.
            float4 frag (Interpolators i) : SV_Target
            {
                float xOffset = cos(i.uv.x * TAU * 8) * .01; // wobbly x-offset

                float t = cos((i.uv.y + xOffset - _Time.y * .2) * TAU * 5) * 0.5 + 0.5; // trippy
                t *= 1 - i.uv.y; // have it fade out toward black

                float hackAwayCaps = abs(i.normal.y) < 0.99;
                return float4(t * hackAwayCaps, 0, 0, 1);
            }
            ENDCG
        }
    }
}
