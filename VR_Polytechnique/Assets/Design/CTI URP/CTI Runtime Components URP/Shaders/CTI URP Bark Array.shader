Shader "CTI/URP LOD Bark Array"
{
    Properties
    {
        [Header(Surface Options)]
        [Space(8)]
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows                 ("Receive Shadows", Float) = 1.0
        [ToggleOff(_SPECULARHIGHLIGHTS_OFF)]
        _SpecularHighlights             ("Enable Specular Highlights", Float) = 1.0

        [Space(8)]
        [Toggle(_NORMALINDEPTHNORMALPASS)]
        _ApplyNormalDepthNormal         ("Enable Normal in Depth Normal Pass", Float) = 1.0
        [Toggle(_RECEIVEDECALS)]
        _ReceiveDecals                  ("Receive Decals", Float) = 0.0

        [Header(Surface Inputs)]
        [Space(8)]
        _HueVariation                   ("Color Variation", Color) = (0.9,0.5,0.0,0.1)
    //  Renamed to _BaseMap because of _BaseMap_ST
        [Space(8)]
        [NoScaleOffset] _BaseMap        ("Albedo (RGB) Smoothness (A) Array", 2DArray) = "white" {}
        
        [Space(8)]
        [Toggle(_NORMALMAP)]
        _ApplyNormal                    ("Enable Normal (AG) Occlusion (B) Map", Float) = 1.0
        [NoScaleOffset]
        _BumpOcclusionMapArray          ("     Normal (AG) Occlusion (B) Array", 2DArray) = "white" {}

        _Smoothness                     ("Smoothness", Range(0.0, 1.0)) = 1.0
        _SpecColor                      ("Specular", Color) = (0.2, 0.2, 0.2)
        

        [Header(Wind)]
        [Space(8)]
        [CTI_URPWindDrawer]
        _BaseWindMultipliers            ("Main (X) Branch (Y) Flutter (Z)", Vector) = (1,1,1,0)
        [Space(8)]
        _WindVariation                  ("Wind Variation", Range(0.0, 0.05)) = 0.0

    //  ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        // Do NOT define this as otherwise baked shadows will fail
        // [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
 
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
            Tags {"LightMode" = "UniversalForward"}

            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _NORMALIZEBRANCH

            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF

            #pragma shader_feature_local_fragment _RECEIVEDECALS

            #define CTIBARK
            #define CTIBARKARRAY
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
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
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

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            #pragma instancing_options renderinglayer

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark ForwardLit Pass.hlsl"

            ENDHLSL
        }

//  Shadows -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALIZEBRANCH

            #define CTIBARK

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define SHADOWSONLYPASS

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark ShadowCaster Pass.hlsl"

            ENDHLSL
        }

//  GBuffer -----------------------------------------------------
        Pass
        {
            Name "GBuffer"
            Tags{"LightMode" = "UniversalGBuffer"}

            ZWrite On
            ZTest LEqual
            Cull Back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1

            #pragma shader_feature_local _NORMALMAP

            #pragma shader_feature_local_fragment _RECEIVEDECALS

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #define _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
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
            #pragma instancing_options assumeuniformscaling maxcount:50
            #pragma instancing_options renderinglayer
            //#pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define CTIBARKARRAY

            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark GBuffer Pass.hlsl"

            ENDHLSL
        }

//  Depth -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALIZEBRANCH

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark DepthOnly Pass.hlsl"

            ENDHLSL
        }

//  Depth Normal -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALIZEBRANCH
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _NORMALINDEPTHNORMALPASS

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define CTIBARKARRAY
            #define DEPTHNORMALPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark DepthNormal Pass.hlsl"

            ENDHLSL
        }

//  Meta -----------------------------------------------------
        Pass
        {
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #define _SPECULAR_SETUP
            #define CTIBARK
            #define BARKMETA

            #pragma shader_feature _SPECGLOSSMAP

            #include "Includes/CTI URP Inputs.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
            #include "Includes/CTI URP Bark SurfaceData.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }
    }

//  ---------------------------------------------------------

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
            Tags {"LightMode" = "UniversalForward"}

            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local _NORMALIZEBRANCH

            #pragma shader_feature_local_fragment _RECEIVEDECALS

            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF

            #define CTIBARK
            #define CTIBARKARRAY
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
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
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

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            #pragma instancing_options renderinglayer

			#pragma vertex LitPassVertex
			#pragma fragment LitPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark ForwardLit Pass.hlsl"

            ENDHLSL
        }

//  Shadows -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALIZEBRANCH

            #define CTIBARK

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define SHADOWSONLYPASS

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark ShadowCaster Pass.hlsl"

            ENDHLSL
        }

//  Depth -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull Back

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALIZEBRANCH

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark DepthOnly Pass.hlsl"

            ENDHLSL
        }

//  Depth Normal -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALIZEBRANCH
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _NORMALINDEPTHNORMALPASS

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTIBARK
            #define CTIBARKARRAY
            #define DEPTHNORMALPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark DepthNormal Pass.hlsl"

            ENDHLSL
        }

//  Meta -----------------------------------------------------
        Pass
        {
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #define _SPECULAR_SETUP
            #define CTIBARK
            #define BARKMETA

            #pragma shader_feature _SPECGLOSSMAP

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Bark SurfaceData.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }
    }

    CustomEditor "CTI_URP_ShaderGUI"
    FallBack "Hidden/InternalErrorShader"
}