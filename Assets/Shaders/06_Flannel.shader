Shader "Workbook/06 Flannel"
{
    Properties
    {
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
            // Blend One One

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

            float4 frag (Interpolators i) : SV_Target
            {
                // Neat pulsating effect:
                float t = abs(frac(i.uv.x * 5) * 2 - 1);

                // Can also do:
                t = cos(i.uv.x * 25);

                // Or multiply by TAU for a seamless loop (starts and ends with the same value):
                t = cos(i.uv.x * TAU * 2);

                // Don't forget to shift the range to [0,1]:
                t = t * 0.5 + 0.5;

                // OR, visualize the y coordinate as well:
                float2 t2 = cos((i.uv) * TAU * 2) * 0.5 + 0.5;
                return float4(t2, 0, 1);
            }

/*

notes:

* cloud particle effects can tank framerate
    * rendering lots of transparent stuff executes the fragment shader a lot, known as fill rate

* order in which objects tend to render
    * skybox
    * opaque (called geometry in render queue)
    * transparent (all additively blended and transparent objects)
    * overlays (for example, lens flares)

*/
            ENDCG
        }
    }
}
