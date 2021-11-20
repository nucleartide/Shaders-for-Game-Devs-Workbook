Shader "Workbook/14 blah"
{
    // TODO(jason): might be good to capture notes in a comment block so i don't lose them
    // initialize with low level of detail mipmaps, and stream in more detailed textures later
    // how unreal engine 3 works ^^
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        // "white" | "black" | "gray" | "bump"
        _Pattern("Pattern", 2D) = "white" {} // texture mask
        _Rock("Rock", 2D) = "white" {}
        _MipSampleLevel ("MIP", Float) = 0 // 0 is highest level of detail, higher numbers step into lower levels of detail
        // mip levels are useful for showing the right amount of detail depending on distance
        // at highest level of detail, texture can be noisy at a distance,
        // at low level of detail, texture can be blurry, but look fine at a distance
        // mip levels: sometimes used in image-based lighting
        // vertex shader cannot figure out mip levels
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

            sampler2D _MainTex;
            sampler2D _Pattern;
            sampler2D _Rock;
            float _MipSampleLevel;
            // float4 _MainTex_ST; // optional, tiling and offset of texture

            // Per-vertex mesh data, auto-filled by Unity
            struct MeshData
            {
                float4 vertex : POSITION; // local space vertex position
                float3 normal : NORMAL; // local space normal direction
                float4 tangent : TANGENT; // tangent direction (xyz), tangent sign (w)
                float4 color : COLOR; // vertex color
                float4 uv0 : TEXCOORD0; // UV coordinates aren't limited to texture applications; textures don't have to use UV coords'
            };

            // Per-fragment interpolated data:
            struct Interpolators
            {
                float4 vertex : SV_POSITION; // clip space position, sole required field
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                // o.worldPos = mul(unity_ObjectToWorld, v.vertex); // world space coords
                o.worldPos = mul(UNITY_MATRIX_M, float4(v.vertex.xyz, 1)); // world space coords, different matrix variable but same effect
                // float4(xyz, 1) is used to ensure a 1 is in the final slot
                // 1 takes offset into account, 0 makes it a direction or orientation
                // buuut v.vertex.w == 1 already, so this is actually unneeded
                o.vertex = UnityObjectToClipPos(v.vertex); // clip space coords
                // o.uv = TRANSFORM_TEX(v.uv0, _MainTex); // get scaled UV coordinates // don't want scaling anymore
                o.uv = v.uv0;
                // o.uv.x += _Time.y * 0.2; // flowing river example
                return o;
            }

// given a single variable 'coord', return a wave value
           float GetWave(float coord)
            {
                float wave = cos((coord - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                wave *= coord;
                return wave;
            }

            // exercise: make textured plane using texture from opengameart
            float4 frag(Interpolators i) : SV_TARGET
            {
                // return float4(i.worldPos.xyz, 1);

                float2 topDownProjection = i.worldPos.xz;
                // return float4(topDownProjection, 0, 1);

                // float4 col = tex2D(_MainTex, i.uv); // instead of using UVs, use world space coords
                // sample from the texture using world space coordinates instead of vertex UV coordinates.
                // easier to do for terrain, where you aren't doing detailed texture mapping, and you simply want a texture to repeat.
                float4 cobble = tex2D(_MainTex, topDownProjection); // instead of using UVs, use world space coords
                float4 cobble2 = tex2Dlod(_MainTex, float4(topDownProjection, _MipSampleLevel.xx) );
                // for lod to work, you must have generated mipmaps for the texture
                // inspect your texture in Unity to confirm that mipmaps are generated
                float4 rock = tex2Dlod(_Rock, float4(topDownProjection, _MipSampleLevel.xx));
                // float4 col2 = tex2D(_Pattern, i.uv); // instead of using UVs, use world space coords
                // return col2;

/*
                return pattern;
                return GetWave(pattern); // convert to flaot4
                */

float pattern = tex2D(_Pattern, i.uv).x; // instead of using UVs, use world space coords
float4 finalColor = lerp(float4(1,0,0,1), cobble, pattern);
// note that pattern is sampled in UV space, but cobble pattern is sampled in world space
// return finalColor;

// blend between 2 textures.
finalColor = lerp(rock, cobble2, pattern);
return finalColor;

// turn off compression for crisper quality
            }
            ENDCG
        }
    }

// exercise: texture map based on world space coords, not UV coords
// exercise: return the value of GetWave()
// exercise: lerp between 2 patterns: cobblestone, and red color
// exercise: lerp between 2 patterns based on a pattern
}

/*

mip maps
    copies of a texture downsampled to different sizes (powers of 2)

anisotropic vs isotropic
    different or same properties in all directions
    example: wood grain vs... tiling kitchen floor

set Aniso Level to 0 in texture
    uncheck generate mipmaps

anisotropic filtering vs isotropic filtering – sample
    samples from different textures depending on distance, angle, etc.
    can store textures in a scaled way

bilinear vs trilinear vs point filtering
    point filtering - minecraft look
    trilinear: blend between different mip levels

*/
