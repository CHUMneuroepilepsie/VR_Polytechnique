#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

//  Structs

struct Attributes {
    float4  positionOS      : POSITION;
    float3  normalOS        : NORMAL;
    //float4  tangentOS     : TANGENT;
    float2  texcoord        : TEXCOORD0;
    float3  texcoord1       : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings {
    float4 positionCS       : SV_POSITION;
    float2 uv               : TEXCOORD0;
};

//  Shadow caster specific input
float3 _LightDirection;
float3 _LightPosition;

//--------------------------------------
//  Vertex shader

#include "Includes/CTI URP Billboard.hlsl"

Varyings ShadowPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);

    half4 color;
    CTIBillboardVert(input, _LightDirection, color);

    output.uv = input.texcoord.xy;

    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldDir(input.normalOS);

    #if _CASTING_PUNCTUAL_LIGHT_SHADOW
        float3 lightDirectionWS = normalize(_LightPosition - positionWS);
    #else
        float3 lightDirectionWS = _LightDirection;
    #endif

    output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));

    #if UNITY_REVERSED_Z
        output.positionCS.z = min(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #else
        output.positionCS.z = max(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
    #endif
    return output;
}

//--------------------------------------
//  Fragment shader

half4 ShadowPassFragment(Varyings input) : SV_Target
{
    #if defined(LOD_FADE_CROSSFADE) && !defined(SHADER_API_GLES)
        LODDitheringTransition(input.positionCS.xyz, unity_LODFade.x);
    #endif
    half alpha = SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a;
    clip(alpha - _Cutoff);
    return 0;
}