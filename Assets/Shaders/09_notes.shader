Shader "Workbook/09 blah"
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
    // subshader tags
        Tags {
        // tag to inform render pipeline of type
		"RenderType" = "Transparent" // set this to transparent, mostly for tagging purposes for postprocess FX

        // changes the render order. transparent must be the default
        // we want this object to render after everything opaque has rendered, because we don't want to destroy our additive effects by messing up the depth buffer
        "Queue" = "Transparent" // set this to transparent too
		}

		// pass tags
        Pass
        {
			Cull Back // back is default value, off for both sides
            Blend One One // additive
			// Blend DstColor Zero // multiplicative
            ZWrite Off // turn off writing to depth buffer for transparent objects
			ZTest LEqual // if depth of this object is <= depth in buffer, show it. otherwise, don't
// ZTest Always
// ZTest GEqual // really useful for "ghost" shaders that render occluded things, like mario in super mario sunshine

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;

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
                // float2 tangent : TEXCOORD2;
                // float2 justSomeValues : TEXCOORD3;
            };

            // InverseLerp takes a start value `a`, an end value `b`, and a value `v`,
            // and returns the ratio of `v`'s covered distance between `a` and `b`.
            //
            // This is not built into GLSL, so we need to define the function ourselves.
            float InverseLerp(float a, float b, float v)
            {
                return (v-a) / (b-a);
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
				// Neat pulsating effect:
				float t = abs(frac(i.uv.x * 5) * 2 - 1);

				// Can also do:
				t = cos(i.uv.x * 25);

				// Or multiply by TAU for a seamless loop (starts and ends with the same value):
				t = cos(i.uv.x * TAU * 2);

				// Don't forget to shift the range to [0,1]:
				t = t * 0.5 + 0.5;

				// OR, visualize the y coordinate as well:
				// float2 t2 = cos((i.uv) * TAU * 2) * 0.5 + 0.5;
				// return float4(t2, 0, 1);

// nice barber shop swirly effect
                /*
                float xOffset = i.uv.y;
                xOffset = cos(i.uv.y * TAU * 8) * .01; // add some wobble instead
				t = cos((i.uv.x + xOffset) * TAU * 5) * 0.5 + 0.5;
				t = cos((i.uv.x + xOffset + _Time.y * .1) * TAU * 5) * 0.5 + 0.5; // trippy
				return float4(t, 0, 0, 1);
                */

// create a ring powerup VFX like in dragonball z
                float xOffset = cos(i.uv.x * TAU * 8) * .01; // add some wobble instead
				t = cos((i.uv.y + xOffset - _Time.y * .2) * TAU * 5) * 0.5 + 0.5; // trippy
                t *= 1 - i.uv.y; // have it fade out toward black


                float hackAwayCaps = abs(i.normal.y) < 0.99;
				float waves = t * hackAwayCaps;

float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
return gradient * waves; // adds some colors to waves

				return float4(t * hackAwayCaps, 0, 0, 1);

// blending
/*
src color - the color you computed
dst color - the screen
src * a +/- dst * b // you can choose a, b, and the +/-

additive blending, makes things brighter
    basically adding colors together
    useful for fire effects
    is just src * 1 + dst * 1

multiplicative blending
    is just src * dst

define these in Pass {}, but before CGPROGRAM - you are defining a and b

there is a depth buffer that fragment shaders can read/write to, to determine whether to render

transparent objects don't write to depth buffer, so as not to occlude things behind it when viewed by camera

cloud particle effects can tank framerate -> rendering lots of transparent stuff, executing fragment shader a lot
    known as fill rate

order in which objects tend to render
    skybox
    opaque (called geometry in render queue)
    transparent (all additive and transparent)
    overlays (like lens flares )

transparent shaders still read from depth buffer
*/

				// return float4(t, 0, 0, 1);
            }

            ENDCG
        }
    }
}
