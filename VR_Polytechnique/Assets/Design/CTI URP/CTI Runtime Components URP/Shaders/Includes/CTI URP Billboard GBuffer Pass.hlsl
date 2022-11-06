#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
    #define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

//  Structs
struct Attributes {
    float4  positionOS                  : POSITION;
    float3  normalOS                    : NORMAL;
    float4  tangentOS                   : TANGENT;
    float2  texcoord                    : TEXCOORD0;
    float3  texcoord1                   : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings {
    float4 positionCS   : SV_POSITION;
    float2 uv           : TEXCOORD0;

    //DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
    half3 vertexSH                      : TEXCOORD1;
    //#ifdef _ADDITIONAL_LIGHTS
    float3 positionWS                   : TEXCOORD2;
    //#endif
    half3 normalWS                      : TEXCOORD3;
    #if defined(_NORMALMAP) || defined(DEPTHNORMALPASS)
        half4 tangentWS                 : TEXCOORD4;
    #endif
    
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half4 fogFactorAndVertexLight   : TEXCOORD5;
    #else
        half  fogFactor                 : TEXCOORD5;
    #endif

//  Due to the order of our includes we have to check for both defines 
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) || !defined(_MAIN_LIGHT_SHADOWS_CASCADE)
        float4 shadowCoord              : TEXCOORD7;
    #endif
    half colorVariation                 : TEXCOORD8;

    //UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

//--------------------------------------
//  Include the surface function
#include "Includes/CTI URP Billboard SurfaceData.hlsl"

//--------------------------------------
//  Vertex shader

#include "Includes/CTI URP Billboard.hlsl"

Varyings LitGBufferPassVertex (Attributes input)
{
    Varyings output = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(input);
    //UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    half4 color;
    CTIBillboardVert(input, 0, color);

//  Set color variation
    output.colorVariation = color.r;

    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    
    output.uv = input.texcoord; //TRANSFORM_TEX(input.texcoord, _BaseMap);

    //  Already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;

    #ifdef _NORMALMAP
        real sign = input.tangentOS.w * GetOddNegativeScale();
        output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
    #endif

    //OUTPUT_LIGHTMAP_UV(input.staticLightmapUV, unity_LightmapST, output.staticLightmapUV);
    //#ifdef DYNAMICLIGHTMAP_ON
    //    output.dynamicLightmapUV = input.dynamicLightmapUV.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    //#endif
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
        output.vertexLighting = vertexLight;
    #endif

    //#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
        output.positionWS = vertexInput.positionWS;
    //#endif

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        output.shadowCoord = GetShadowCoord(vertexInput);
    #endif

    output.positionCS = vertexInput.positionCS;

    return output;
}

FragmentOutput LitGBufferPassFragment(Varyings input)
{
    //UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    #if defined(LOD_FADE_CROSSFADE) && !defined(SHADER_API_GLES)
        LODDitheringTransition(input.positionCS.xyz, unity_LODFade.x);
    #endif

    SurfaceData surfaceData;
    AdditionalSurfaceData additionalSurfaceData;
//  Get the surface description
    InitializeBillboardLitSurfaceData(input.colorVariation, input.uv.xy, surfaceData, additionalSurfaceData);

//  Transfer all to world space 
    InputData inputData = (InputData)0;
    inputData.positionWS = input.positionWS;

    half3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS);

    #ifdef _NORMALMAP
        float sgn = input.tangentWS.w;
        float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
        inputData.normalWS = TransformTangentToWorld(surfaceData.normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
    #else
        inputData.normalWS = input.normalWS;
    #endif

    #if defined (_GBUFFERLIGHTING_VSNORMALS)
        // From world to view space
        half3 normalVS = TransformWorldToViewDir(inputData.normalWS, true);
        // Now "flip" the normal
        normalVS.z = abs(normalVS.z);
        // From view to world space again
        inputData.normalWS = normalize( mul((float3x3)UNITY_MATRIX_I_V, normalVS) );
    #endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif

    inputData.fogCoord = 0.0; // we don't apply fog in the guffer pass
    
    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        inputData.vertexLighting = input.vertexLighting.xyz;
    #else
        inputData.vertexLighting = half3(0, 0, 0);
    #endif
    
    #if defined(DYNAMICLIGHTMAP_ON)
        inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV, input.vertexSH, inputData.normalWS);
    #else
        inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.vertexSH, inputData.normalWS);
    #endif

    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

// TODO: Lightlayers(Done) Cookies(Done)

    #if defined(_GBUFFERLIGHTING_TRANSMISSION)
        uint meshRenderingLayers = GetMeshRenderingLightLayer();
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        half4 shadowMask = CalculateShadowMask(inputData);
        AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
        Light mainLight1 = GetMainLight(inputData, shadowMask, aoFactor);

        #if defined(_LIGHT_LAYERS)
            UNITY_BRANCH if (IsMatchingLightLayer(mainLight1.layerMask, meshRenderingLayers))
            {
        #endif
                half transPower = _Translucency.y;
                half3 transLightDir = mainLight1.direction + inputData.normalWS * _Translucency.w;
                half transDot = dot( transLightDir, -inputData.viewDirectionWS );
                transDot = exp2(saturate(transDot) * transPower - transPower);

                #if defined(_SAMPLE_LIGHT_COOKIES)
                    real3 cookieColor = SampleMainLightCookie(inputData.positionWS);
                    mainLight1.color *= float4(cookieColor, 1);
                #endif

                surfaceData.emission +=
                    transDot 
                  * (1.0h - saturate(dot(mainLight1.direction, -inputData.normalWS)))
                  * mainLight1.color * lerp(1, mainLight1.shadowAttenuation, _Translucency.z)
                  * additionalSurfaceData.translucency * _Translucency.x
                  * surfaceData.albedo;

                // Light unityLight;
                // unityLight = GetMainLight();
                // unityLight.distanceAttenuation = 1.0; //?

                // #if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && Donedefined(_SURFACE_TYPE_TRANSPARENT)
                //     float4 shadowCoord = float4(screen_uv, 0.0, 1.0);
                // #else
                //     float4 shadowCoord = TransformWorldToShadowCoord(posWS.xyz);
                // #endif
                // unityLight.shadowAttenuation = MainLightShadow(shadowCoord, posWS.xyz, shadowMask, _MainLightOcclusionProbes);
        #if defined(_LIGHT_LAYERS)
            }
        #endif
    #endif

    BRDFData brdfData;
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, inputData.shadowMask);
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, inputData.shadowMask);
    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, surfaceData.occlusion, inputData.positionWS, inputData.normalWS, inputData.viewDirectionWS);
    return BRDFDataToGbuffer(brdfData, inputData, surfaceData.smoothness, surfaceData.emission + color, surfaceData.occlusion);
}