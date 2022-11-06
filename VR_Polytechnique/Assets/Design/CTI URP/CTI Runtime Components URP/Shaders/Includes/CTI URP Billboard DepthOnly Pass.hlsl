//  Structs

struct Attributes {
    float4  positionOS : POSITION;
    float3  normalOS : NORMAL;
    float4  tangentOS : TANGENT;
    float2  texcoord : TEXCOORD0;
    float3  texcoord1 : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                           : TEXCOORD0;
    float4 positionCS                   : SV_POSITION;

    //UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

//--------------------------------------
//  Vertex shader

#include "Includes/CTI URP Billboard.hlsl"

Varyings DepthOnlyVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    half4 color;
    CTIBillboardVert(input, 0, color);

    output.uv = input.texcoord;
    VertexPositionInputs vertexPosition = GetVertexPositionInputs(input.positionOS.xyz);
    output.positionCS = vertexPosition.positionCS;

    return output;
}

//--------------------------------------
//  Fragment shader

half4 DepthOnlyFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
    #if defined(LOD_FADE_CROSSFADE) && !defined(SHADER_API_GLES)
        LODDitheringTransition(input.positionCS.xyz, unity_LODFade.x);
    #endif
    half alpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a;
    clip(alpha - _Cutoff);
    return 0;
}