struct Attributes
{
    float3 positionOS                   : POSITION;
    float3 normalOS                     : NORMAL;    // Bending also
    #if defined (_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        float4 tangentOS                : TANGENT;
        float2 uv                       : TEXCOORD0;
    #endif

    float2 texcoord1                    : TEXCOORD1; // Bending
    half4 color                         : COLOR;     // Bending    

    float3 texcoord2                    : TEXCOORD2; // Leaves only: Pivot

    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS                   : SV_POSITION;
    #if defined (_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        float2 uv                       : TEXCOORD0;
    #endif
    float3 normalWS                     : TEXCOORD4;
    #if defined (_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        half4 tangentWS                 : TEXCOORD5;
    #endif

    //  CTI specific
    #if defined(CTIBARKARRAY)
        half layer                      : TEXCOORD6;
    #endif

    //UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


//--------------------------------------
//  Vertex shader

#include "Includes/CTI URP Bending.hlsl"

Varyings DepthNormalsVertex(Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    CTI_AnimateVertex(
        input,
        #if defined (_BENDINGCOLRSONLY)
            float4(input.color.rg, input.color.ab), // animParams,
        #else
            float4(input.color.rg, input.texcoord1.xy), // animParams,
        #endif
        _BaseWindMultipliers
    );

    //  CTI special
    #if defined(CTIBARKARRAY)
        output.layer = input.color.b;
    #endif

    #if defined (_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        output.uv = input.uv;
    #endif

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

    #if defined (_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    #else
        VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, float4(1,1,1,1));
    #endif 
    output.normalWS = normalInput.normalWS;
    #if defined (_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        real sign = input.tangentOS.w * GetOddNegativeScale();
        output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif
    
    output.positionCS = vertexInput.positionCS;

    return output;
}

half4 DepthNormalsFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if defined(LOD_FADE_CROSSFADE) && !defined(SHADER_API_GLES)
        LODDitheringTransition(input.positionCS.xyz, unity_LODFade.x);
    #endif

    //  URP 12
    #if defined(_NORMALMAP) && defined(_NORMALINDEPTHNORMALPASS)
        half3 normalTS;
        #if defined(CTIBARKARRAY)
            half4 sampleNormal = SAMPLE_TEXTURE2D_ARRAY(_BumpOcclusionMapArray, sampler_BumpOcclusionMapArray, input.uv, input.layer); 
        #else
            half4 sampleNormal = SAMPLE_TEXTURE2D(_BumpOcclusionMap, sampler_BumpOcclusionMap, input.uv);
        #endif
        half3 tangentNormal;
        normalTS.xy = sampleNormal.ag * 2 - 1;
        normalTS.z = max(1.0e-16, sqrt(1.0h - saturate(dot(normalTS.xy, normalTS.xy)))); 

        float sgn = input.tangentWS.w; // should be either +1 or -1
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        input.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent, input.normalWS.xyz));
    #endif

    #if defined(_GBUFFER_NORMALS_OCT)
        float3 normalWS = normalize(input.normalWS);
        float2 octNormalWS = PackNormalOctQuadEncode(normalWS);           // values between [-1, +1], must use fp32 on some platforms.
        float2 remappedOctNormalWS = saturate(octNormalWS * 0.5 + 0.5);   // values between [ 0,  1]
        half3 packedNormalWS = PackFloat2To888(remappedOctNormalWS);      // values between [ 0,  1]
        return half4(packedNormalWS, 0.0);
    #else
        float3 normalWS = NormalizeNormalPerPixel(input.normalWS);
        return half4(normalWS, 0.0);
    #endif
}