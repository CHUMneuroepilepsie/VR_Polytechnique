//  This is needed by the Meta pass
inline void InitializeStandardLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

//  Zero initialize outSurfaceData as URP 10+ might expect clear coat here.
    outSurfaceData = (SurfaceData)0;
    outSurfaceData.alpha = Alpha(albedoAlpha.a, 1, _Cutoff);

    outSurfaceData.albedo = albedoAlpha.rgb;
    outSurfaceData.metallic = 0;
    outSurfaceData.specular = _SpecColor.rgb;
    outSurfaceData.smoothness = 0.5;
    outSurfaceData.normalTS = half3(0,0,1);
    outSurfaceData.occlusion = 1;
    outSurfaceData.emission = 0;
}