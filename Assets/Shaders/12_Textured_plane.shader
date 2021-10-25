Shader "Workbook/12 Textured plane"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
            float4 _MainTex_ST; // optional, tiling and offset of texture

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
                float2 uv : TEXCOORD1;
            };

            Interpolators vert(MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex); // get scaled UV coordinates
                return o;
            }

            // exercise: make textured plane using texture from opengameart
            fixed4 frag(Interpolators i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
