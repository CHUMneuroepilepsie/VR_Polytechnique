#ifndef URP_TRANSLUCENTLIGHTING_INCLUDED
#define URP_TRANSLUCENTLIGHTING_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


half3 CTI_GlobalIllumination(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS, 
    half specOccluison)
{
    half3 reflectVector = reflect(-viewDirectionWS, normalWS);
    half NoV = saturate(dot(normalWS, viewDirectionWS));
    half fresnelTerm = Pow4(1.0 - NoV);

    half3 indirectDiffuse = bakedGI * occlusion;
    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, brdfData.perceptualRoughness, occlusion)        * specOccluison;

    return EnvironmentBRDF(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
}


half3 LightingPhysicallyBasedWrapped(BRDFData brdfData, half3 lightColor, half3 lightDirectionWS, half lightAttenuation, half3 normalWS, half3 viewDirectionWS, half NdotL)
{
//NdotL is wrapped... not correct for specular
    half3 radiance = lightColor * (lightAttenuation * NdotL);
    return DirectBDRF(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radiance;
}

half3 LightingPhysicallyBasedWrapped(BRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS, half NdotL)
{
    return LightingPhysicallyBasedWrapped(brdfData, light.color, light.direction, light.distanceAttenuation * light.shadowAttenuation, normalWS, viewDirectionWS, NdotL);
}

half4 CTIURPFragmentPBR(InputData inputData, SurfaceData surfaceData,
    half4 translucency, half AmbientReflection, half Wrap)
{
    BRDFData brdfData;
    InitializeBRDFData(surfaceData, brdfData);

//  Debugging
    #if defined(DEBUG_DISPLAY)
        half4 debugColor;
        if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
        {
            return debugColor;
        }
    #endif

    half4 shadowMask = CalculateShadowMask(inputData);
    AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
    uint meshRenderingLayers = GetMeshRenderingLightLayer();

    Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
    half3 mainLightColor = mainLight.color;
    
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

    LightingData lightingData = CreateLightingData(inputData, surfaceData);

//half3 color = CTI_GlobalIllumination(brdfData, inputData.bakedGI, occlusion, inputData.normalWS, inputData.viewDirectionWS,     AmbientReflection);
//  In order to use probe blending and proper AO we have to use the new GlobalIllumination function
    lightingData.giColor = GlobalIllumination(
        brdfData,
        brdfData,   // brdfDataClearCoat,
        0,          // surfaceData.clearCoatMask
        inputData.bakedGI,
        aoFactor.indirectAmbientOcclusion,
        inputData.positionWS,
        inputData.normalWS,
        inputData.viewDirectionWS
    );

    half w = Wrap;
//  TODO: Move to inspector
    half WrappedNormalization = rcp((1.0h + w) * (1.0h + w));
    half NdotL;

#if defined(_LIGHT_LAYERS)
    UNITY_BRANCH if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
    {
#endif
    //  Wrapped Diffuse   
        // NdotL = saturate((dot(inputData.normalWS, mainLight.direction) + w) / ((1.0h + w) * (1.0h + w)) );
        NdotL = saturate((dot(inputData.normalWS, mainLight.direction) + w) * WrappedNormalization );
        lightingData.mainLightColor = LightingPhysicallyBasedWrapped(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS, NdotL);
    //  Translucency
        half transPower = translucency.y;
        half3 transLightDir = mainLight.direction + inputData.normalWS * translucency.w;
        half transDot = dot( transLightDir, -inputData.viewDirectionWS );
        transDot = exp2(saturate(transDot) * transPower - transPower);
        lightingData.mainLightColor += transDot * (1.0 - NdotL) * mainLight.color * lerp(1.0h, mainLight.shadowAttenuation, translucency.z) * brdfData.diffuse * translucency.x;
#if defined(_LIGHT_LAYERS)
    }
#endif

    #ifdef _ADDITIONAL_LIGHTS
        uint pixelLightCount = GetAdditionalLightsCount();

//  Clustered Lighting

        LIGHT_LOOP_BEGIN(pixelLightCount)    
            //  URP 12
                Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
            #if defined(_LIGHT_LAYERS)
                UNITY_BRANCH if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
                {
            #endif
            //  Wrapped Diffuse
                NdotL = saturate((dot(inputData.normalWS, light.direction) + w) * WrappedNormalization );
                lightingData.additionalLightsColor += LightingPhysicallyBasedWrapped(
                    brdfData, light, inputData.normalWS, inputData.viewDirectionWS, NdotL);
            //  Translucency
                half transPower = translucency.y;
                half3 transLightDir = light.direction + inputData.normalWS * translucency.w;
                half transDot = dot( transLightDir, -inputData.viewDirectionWS );
                transDot = exp2(saturate(transDot) * transPower - transPower);
                lightingData.additionalLightsColor += brdfData.diffuse * transDot * (1.0h - NdotL) * light.color * lerp(1.0h, light.shadowAttenuation, translucency.z) * light.distanceAttenuation  * translucency.x;
                
            #if defined(_LIGHT_LAYERS)
                }
            #endif
        LIGHT_LOOP_END
    #endif

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
        lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
    #endif
    return CalculateFinalColor(lightingData, surfaceData.alpha);
}

#endif