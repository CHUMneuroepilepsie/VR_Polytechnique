Shader "CTI/URP Billboard"
{
    Properties
    {
        [Header(Surface Options)]
        [Space(8)]
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows                 ("Receive Shadows", Float) = 1.0
        [ToggleOff(_SPECULARHIGHLIGHTS_OFF)]
        _SpecularHighlights             ("Enable Specular Highlights", Float) = 1.0
        [Enum(Off,0,On,1)] _Coverage    ("Alpha To Coverage", Float) = 0

        [Toggle(_NORMALINDEPTHNORMALPASS)]
        _ApplyNormalDepthNormal         ("Enable Normal in Depth Normal Pass", Float) = 1.0

        [Space(8)]
        [KeywordEnum(Standard, Transmission)]
        _GbufferLighting                ("Gbuffer Lighting", Float) = 0
        [Toggle(_SAMPLE_LIGHT_COOKIES)]
        _ApplyCookiesForTransmission    ("     Enable Cookies for Transmission", Float) = 0.0

        [Header(Surface Inputs)]
        [Space(8)]
        _HueVariation                   ("Color Variation", Color) = (0.9,0.5,0.0,0.1)

        [NoScaleOffset] _BaseMap        ("Albedo (RGB) Smoothness (A)", 2D) = "white" {}
        _Cutoff                         ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        _AlphaLeak                      ("Alpha Leak Suppression", Range(0.5,1.0)) = 0.6
        
        _Smoothness                     ("Smoothness", Range(0.0, 1.0)) = 1.0
        _SpecColor                      ("Specular", Color) = (0.2, 0.2, 0.2)
        _OcclusionStrength              ("Occlusion Strength", Range(0,1)) = 1

        [Space(8)]
        [Toggle(_NORMALMAP)]
        _ApplyNormal                    ("Enable Normal Map", Float) = 1.0
        [NoScaleOffset]
        _BumpSpecMap                    ("     Normal (AG) Translucency(R) Smoothness(B)", 2D) = "white" {}
        _BumpScale                      ("     Normal Scale", Float) = 1.0

        [Header(Wrapped Diffuse Lighting)]
        [Space(8)]
        _Wrap                           ("Wrap", Range(0.0, 1.0)) = 0.5

        [Header(Transmission)]
        [Space(8)]
        [CTI_URPTransDrawer]
        _Translucency                   ("Strength (X) Power (Y)", Vector) = (1, 8, 0, 0)

        [Header(Wind)]
        [Space(8)]
        _WindStrength                   ("Wind Strength", Float) = 1.0 
        
        [Header(Ambient)]
        [Space(8)]
        _AmbientReflection              ("Ambient Reflection", Range(0, 1)) = 1

        [Header(Legacy)]
        [Space(8)]
        _BillboardScale                 ("Billboard Scale", Float) = 2

    }

    SubShader
    {
        Tags
        {
            "Queue"="Geometry"
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "DisableBatching" = "LODFading"
            "IgnoreProjector" = "True"
            "ShaderModel"="4.5"
        }
        LOD 300


//  Base -----------------------------------------------------
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            ZWrite On
        //  URP billboardNormal orientation is flipped?
            Cull Off
            AlphaToMask [_Coverage]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF

            #define CTIBILLBOARD
            #define _SPECULAR_SETUP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
//#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
//#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING


            // -------------------------------------
            // Unity defined keywords
//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
//#pragma multi_compile _ LIGHTMAP_ON
//#pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer

            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Lighting.hlsl"

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Includes/CTI URP Billboard ForwardLit Pass.hlsl"

            ENDHLSL
        }

//  Shadows -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull Off
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1

            #define CTIBILLBOARD

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define SHADOWCASTERPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Billboard ShadowCaster Pass.hlsl"

            ENDHLSL
        }

//  GBuffer -----------------------------------------------------
        Pass
        {
            Name "GBuffer"
            Tags{"LightMode" = "UniversalGBuffer"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1

            #pragma shader_feature_local _NORMALMAP

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #define _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            #pragma shader_feature_local_fragment _ _GBUFFERLIGHTING_TRANSMISSION
        //  Needed in case Transmission is used
        //  Built in keyword might fail once cookies were activated...
            #pragma shader_feature_local_fragment _SAMPLE_LIGHT_COOKIES


            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
//#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            // -------------------------------------
            // Unity defined keywords
//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
//#pragma multi_compile _ LIGHTMAP_ON
//#pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer
            //#pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define CTIBILLBOARD

            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Billboard GBuffer Pass.hlsl"

            ENDHLSL
        }        

//  Depth -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1

            #define CTIBILLBOARD

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #include "Includes/CTI URP Billboard DepthOnly Pass.hlsl"

            ENDHLSL
        }

//  Depth Normal -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _NORMALINDEPTHNORMALPASS

            #define CTIBILLBOARD

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define DEPTHNORMALPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #include "Includes/CTI URP Billboard DepthNormal Pass.hlsl"

            ENDHLSL
        }


//  Meta -----------------------------------------------------
    }


// -----------------------------------------------------------------------------

    SubShader
    {
        Tags
        {
            "Queue"="Geometry"
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "DisableBatching" = "LODFading"
            "IgnoreProjector" = "True"
            "ShaderModel"="2.0"
        }
        LOD 300


//  Base -----------------------------------------------------
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            ZWrite On
        //  URP billboardNormal orientation is flipped?
            Cull Off
            AlphaToMask [_Coverage]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF

            #define CTIBILLBOARD
            #define _SPECULAR_SETUP

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
//#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
//#pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING


            // -------------------------------------
            // Unity defined keywords
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog
            #pragma multi_compile_fragment _ DEBUG_DISPLAY

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer

            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Lighting.hlsl"

			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment

            #include "Includes/CTI URP Billboard ForwardLit Pass.hlsl"

            ENDHLSL
        }

//  Shadows -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull Off
            ColorMask 0

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1

            #define CTIBILLBOARD

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define SHADOWCASTERPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Billboard ShadowCaster Pass.hlsl"

            ENDHLSL
        }

//  Depth -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Off

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1

            #define CTIBILLBOARD

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #include "Includes/CTI URP Billboard DepthOnly Pass.hlsl"

            ENDHLSL
        }

//  Depth Normal -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull Off

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _NORMALINDEPTHNORMALPASS

            #define CTIBILLBOARD

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE

            #define DEPTHNORMALPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            #include "Includes/CTI URP Billboard DepthNormal Pass.hlsl"

            ENDHLSL
        }


//  Meta -----------------------------------------------------
    }

    FallBack "Hidden/InternalErrorShader"
}
