
//  Surface function

inline void InitializeLeavesLitSurfaceData(half colorVariation, float2 uv, out SurfaceData outSurfaceData, out AdditionalSurfaceData outAdditionalSurfaceData)
{
    outSurfaceData = (SurfaceData)0;

    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    outSurfaceData.alpha = Alpha(albedoAlpha.a, 1, _Cutoff);

//  Add Color Variation
    albedoAlpha.rgb = lerp(albedoAlpha.rgb, (albedoAlpha.rgb + _HueVariation.rgb) * 0.5, colorVariation * _HueVariation.a);
    
    outSurfaceData.albedo = albedoAlpha.rgb;
    outSurfaceData.metallic = 0;
    outSurfaceData.specular = _SpecColor.rgb;
    #if defined (_NORMALMAP)
        half4 sampleNormal = SAMPLE_TEXTURE2D(_BumpSpecMap, sampler_BumpSpecMap, uv);
        half3 normalTS;
        normalTS.xy = sampleNormal.ag * 2 - 1;
        normalTS.z = max(1.0e-16, sqrt(1.0h - saturate(dot(normalTS.xy, normalTS.xy)))); 
        outSurfaceData.normalTS = normalTS;
        outSurfaceData.smoothness = sampleNormal.b * _Smoothness;
        outAdditionalSurfaceData.translucency = sampleNormal.r;
    #else
        outSurfaceData.normalTS = half3(0, 0, 1);
        outSurfaceData.smoothness = _Smoothness;
        outAdditionalSurfaceData.translucency = 1;
    #endif
    outSurfaceData.occlusion = 1;
    outSurfaceData.emission = 0;
}