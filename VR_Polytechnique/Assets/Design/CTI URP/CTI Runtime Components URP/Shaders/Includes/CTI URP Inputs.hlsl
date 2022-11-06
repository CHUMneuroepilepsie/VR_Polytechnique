#ifndef INPUT_SURFACE_CTI_INCLUDED
#define INPUT_SURFACE_CTI_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"


//  Must be declared before we can include Lighting.hlsl
    struct AdditionalSurfaceData
    {
        half translucency;
    };

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"

    CBUFFER_START(UnityPerMaterial)
        float4  _BaseMap_ST;
        half3   _BaseWindMultipliers;
        half    _WindVariation;
        half4   _SpecColor;
        half4   _HueVariation;
        half    _Smoothness;
        half    _BackfaceSmoothness;

    //  Leaf specific inputs
        half    _Cutoff;
        half4   _Translucency;
        half    _AmbientReflection;
        half    _TumbleStrength;                     
        half    _TumbleFrequency;                    
        half    _LeafTurbulence;                     
        half    _EdgeFlutterInfluence;
    
    //  Billboard specific inputs
        half    _AlphaLeak;
        half    _OcclusionStrength;
        half    _BumpScale;
        half    _WindStrength;

        half    _Wrap;

    //  Fix for old bug
        half _BillboardScale;

    CBUFFER_END

//  Custom packed Map for Leaf and Billboard shader
    #if !defined(CTIBARK)
        TEXTURE2D(_BumpSpecMap); SAMPLER(sampler_BumpSpecMap);
    #else
        TEXTURE2D(_BumpOcclusionMap); SAMPLER(sampler_BumpOcclusionMap);
    #endif

    #if defined(CTIBARKARRAY)
        TEXTURE2D_ARRAY(_BaseMapArray); SAMPLER(sampler_BaseMapArray);
        TEXTURE2D_ARRAY(_BumpOcclusionMapArray); SAMPLER(sampler_BumpOcclusionMapArray);
    #endif

#endif