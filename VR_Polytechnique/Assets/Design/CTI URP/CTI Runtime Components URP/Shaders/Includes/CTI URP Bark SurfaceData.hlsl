
//  Surface function

inline void InitializeStandardLitSurfaceData(
    #if !defined(BARKMETA)
        #if defined(CTIBARKARRAY)
            half2 colorVariation,
        #else
            half colorVariation,
        #endif
    #endif
    float2 uv, out SurfaceData outSurfaceData)
{
    
    #if defined(CTIBARKARRAY)
        half4 albedoAlpha = SAMPLE_TEXTURE2D_ARRAY(_BaseMapArray, sampler_BaseMapArray, uv, colorVariation.y); 
    #else
        half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    #endif
    outSurfaceData.alpha = 1;

//  Add Color Variation
    #if !defined(BARKMETA)
        albedoAlpha.rgb = lerp(albedoAlpha.rgb, (albedoAlpha.rgb + _HueVariation.rgb) * 0.5h, colorVariation.x * _HueVariation.a);
    #endif

//  Zero initialize outSurfaceData as URP 12 might expect clear coat here.
    outSurfaceData = (SurfaceData)0;

    outSurfaceData.albedo = albedoAlpha.rgb;
    outSurfaceData.metallic = 0;
    outSurfaceData.specular = _SpecColor.rgb;
    outSurfaceData.smoothness = albedoAlpha.a * _Smoothness;
    //outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
    #if defined (_NORMALMAP)
        #if defined(CTIBARKARRAY)
            half4 sampleNormal = SAMPLE_TEXTURE2D_ARRAY(_BumpOcclusionMapArray, sampler_BumpOcclusionMapArray, uv, colorVariation.y); 
        #else
            half4 sampleNormal = SAMPLE_TEXTURE2D(_BumpOcclusionMap, sampler_BumpOcclusionMap, uv);
        #endif
        
        half3 normalTS;
        normalTS.xy = sampleNormal.ag * 2.0h - 1.0h;
        normalTS.z = max(1.0e-16, sqrt(1.0h - saturate(dot(normalTS.xy, normalTS.xy)))); 
        outSurfaceData.normalTS = normalTS;
        outSurfaceData.occlusion = sampleNormal.b;
    #else
        outSurfaceData.normalTS = half3(0, 0, 1);
        outSurfaceData.occlusion = 1;
    #endif
    outSurfaceData.emission = 0;
}