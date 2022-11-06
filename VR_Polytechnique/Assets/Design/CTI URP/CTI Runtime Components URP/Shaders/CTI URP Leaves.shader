Shader "CTI/URP LOD Leaves"
{
    Properties
    {

        [Header(Surface Options)]
        [Space(8)]

        [Enum(UnityEngine.Rendering.CullMode)]
        _Cull                           ("Culling", Float) = 0
        [ToggleOff(_RECEIVE_SHADOWS_OFF)]
        _ReceiveShadows                 ("Receive Shadows", Float) = 1.0
        [ToggleOff(_SPECULARHIGHLIGHTS_OFF)]
        _SpecularHighlights             ("Enable Specular Highlights", Float) = 1.0
        [Enum(Off,0,On,1)] _Coverage    ("Alpha To Coverage*", Float) = 0
        [Space(4)]
        [CTIURPHelpDrawer]
        _HelpA ("* Will most likely break if any Depth Prepass is active.", Float) = 0.0

        [Space(8)]
        [Toggle(_NORMALINDEPTHNORMALPASS)]
        _ApplyNormalDepthNormal         ("Enable Normal in Depth Normal Pass", Float) = 1.0
        [Toggle(_RECEIVEDECALS)]
        _ReceiveDecals                  ("Receive Decals", Float) = 0.0

        [Space(8)]
        [KeywordEnum(Standard, Simple, VsNormals, Transmission)]
        _GbufferLighting ("Gbuffer Lighting", Float) = 1
        [Toggle(_SAMPLE_LIGHT_COOKIES)]
        _ApplyCookiesForTransmission    ("     Enable Cookies for Transmission", Float) = 0.0
        
        [Header(Surface Inputs)]
        [Space(8)]
        _HueVariation                   ("Color Variation", Color) = (0.9,0.5,0.0,0.1)
        [Space(8)]
        [NoScaleOffset]
        [MainTexture]
        _BaseMap                        ("Albedo (RGB) Alpha (A)", 2D) = "white" {}
        _Cutoff                         ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
        [Space(8)]
        [Toggle(_NORMALMAP)]
        _ApplyNormal                    ("Enable Normal (AG) Smoothness (B) Trans (R) Map", Float) = 1.0
        [NoScaleOffset]
        _BumpSpecMap                    ("     Normal (AG) Smoothness (B) Trans (R)", 2D) = "white" {}
        _Smoothness                     ("Smoothness", Range(0.0, 1.0)) = 0.5
        _BackfaceSmoothness             ("     Backface Smoothness", Range(0.0, 1.0)) = 1
        _SpecColor                      ("Specular", Color) = (0.2, 0.2, 0.2)


        [Header(Wrapped Diffuse Lighting)]
        [Space(8)]
        _Wrap                           ("Wrap*", Range(0.0, 1.0)) = 0.5
        [Space(4)]
        [CTIURPHelpDrawer]
        _HelpA ("* Only used in forward rendering.", Float) = 0.0

        [Header(Transmission)]
        [Space(8)]
        [CTI_URPTransDrawer]
        _Translucency                   ("Strength (X) Power (Y) Shadow Strength (Z) Distortion (W)", Vector) = (1, 4, 1.0, 0.01)
        
        
        [Header(Wind)]
        [Space(8)]
        [CTI_URPWindDrawer]
        _BaseWindMultipliers            ("Main (X) Branch (Y) Flutter (Z)", Vector) = (1,1,1,0)
        [Space(8)]
        _WindVariation                  ("Wind Variation", Range(0.0, 0.05)) = 0.0

        [Header(Advanced Wind)]
        [Space(8)]
        [Toggle(_LEAFTUMBLING)]
        _EnableLeafTumbling             ("Enable Leaf Tumbling", Float) = 1.0
        _TumbleStrength                 ("     Tumble Strength", Range(-1,1)) = 0
        _TumbleFrequency                ("     Tumble Frequency", Range(0,4)) = 1

        [Toggle(_LEAFTURBULENCE)]
        _EnableLeafTurbulence           ("Enable Leaf Turbulence", Float) = 0.0
        _LeafTurbulence                 ("     Leaf Turbulence", Range(0,4)) = 0.2
        _EdgeFlutterInfluence           ("     Edge Flutter Influence", Range(0,1)) = 0.25

        [Space(8)]
        [Toggle(_NORMALROTATION)]
        _EnableNormalRotation           ("Enable Normal Rotation", Float) = 0.0

        
        [Header(Ambient)]
        [Space(8)]
        _AmbientReflection              ("Ambient Reflection", Range(0, 1)) = 1

        
        [Header(Shadows)]
        [Space(8)]
        [Enum(UnityEngine.Rendering.CullMode)]
        _ShadowCulling                  ("Shadow Caster Culling", Float) = 0
        //_ShadowOffsetBias             ("ShadowOffsetBias", Float) = 1

        
    //  Needed by VegetationStudio's Billboard Rendertex Shaders
        [HideInInspector] _IsBark("Is Bark", Float) = 0

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
            "Queue" = "AlphaTest" // Light Mapper!
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
            Cull [_Cull]
            AlphaToMask [_Coverage]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #define _SPECULAR_SETUP

            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE
            #pragma shader_feature_local _NORMALMAP

            #pragma shader_feature_local_fragment _RECEIVEDECALS

            #pragma shader_feature_local_vertex _NORMALROTATION
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF

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
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            #pragma instancing_options renderinglayer

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Lighting.hlsl"
            #include "Includes/CTI URP Leaves ForwardLit Pass.hlsl"

            ENDHLSL
        }

//  Shadows -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull [_ShadowCulling]
            ColorMask 0

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            // -------------------------------------
            // Universal Pipeline keywords
            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define SHADOWSONLYPASS

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves ShadowCaster Pass.hlsl"

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

            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE
            #pragma shader_feature_local _NORMALMAP

            #pragma shader_feature_local_vertex _NORMALROTATION

            #pragma shader_feature_local_fragment _RECEIVEDECALS

            #pragma shader_feature_local_fragment _ _GBUFFERLIGHTING_SIMPLE _GBUFFERLIGHTING_VSNORMALS _GBUFFERLIGHTING_TRANSMISSION
        //  Needed in case Transmission is used
        //  Built in keyword might fail once cookies were activated...
            #pragma shader_feature_local_fragment _SAMPLE_LIGHT_COOKIES

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

            #define CTILEAVES

            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves GBuffer Pass.hlsl"

            ENDHLSL
        }

//  Depth -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull [_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

        //  Needed because of deferred which may otherwise get some z fighting issues
            #pragma shader_feature_local_vertex _NORMALROTATION

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves DepthOnly Pass.hlsl"

            ENDHLSL
        }


//  Depth Normal -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull [_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

        //  Crazy: This was missing first and the GBuffer pass never rendered correct
        //  as some frags were occluded by the DepthNormal pass (Decals on)
        //  Some strange refactoring by the shader compiler?
            #pragma shader_feature_local_vertex _NORMALROTATION

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _NORMALINDEPTHNORMALPASS

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define DEPTHNORMALPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves DepthNormal Pass.hlsl"

            ENDHLSL
        }

//  Broken in URP 12 (currently)

// --> https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl


//  Selection -----------------------------------------------------
        Pass
        {
            Name "SceneSelectionPassXX"
            Tags{"LightMode" = "SceneSelectionPassXX"}

            ZWrite On
            ColorMask 0
            Cull [_Cull]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves DepthOnly Pass.hlsl"

            ENDHLSL
        }


//  Meta -----------------------------------------------------
        Pass
        {
            Tags {"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #define _SPECULAR_SETUP
            #define _ALPHATEST_ON 1

            #pragma shader_feature _SPECGLOSSMAP

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Meta.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }
    }


//  -----------------------------------------------------------------------------------------

    SubShader
    {
        Tags
        {
            "Queue" = "AlphaTest"
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
            Cull [_Cull]
            AlphaToMask [_Coverage]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #define _SPECULAR_SETUP

            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE
            #pragma shader_feature_local _NORMALMAP

            #pragma shader_feature_local_fragment _RECEIVEDECALS

            #pragma shader_feature_local_vertex _NORMALROTATION
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF

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
            
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            #pragma instancing_options renderinglayer

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Lighting.hlsl"
            #include "Includes/CTI URP Leaves ForwardLit Pass.hlsl"

            ENDHLSL
        }

//  Shadows -----------------------------------------------------
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            Cull [_ShadowCulling]
            ColorMask 0

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define SHADOWSONLYPASS

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves ShadowCaster Pass.hlsl"

            ENDHLSL
        }

//  Depth -----------------------------------------------------
        Pass
        {
            Name "DepthOnly"
            Tags {"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull [_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves DepthOnly Pass.hlsl"

            ENDHLSL
        }


//  Depth Normal -----------------------------------------------------
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull [_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _NORMALINDEPTHNORMALPASS

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define DEPTHNORMALPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves DepthNormal Pass.hlsl"


            ENDHLSL
        }

//  Broken in URP 12 (currently)
//  Selection -----------------------------------------------------
        Pass
        {
            Name "SceneSelectionPassXX"
            Tags{"LightMode" = "SceneSelectionPassXX"}

            ZWrite On
            ColorMask 0
            Cull [_Cull]

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #define _ALPHATEST_ON 1
            #pragma shader_feature_local_vertex _LEAFTUMBLING
            #pragma shader_feature_local_vertex _LEAFTURBULENCE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling maxcount:50
            
            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile_vertex LOD_FADE_PERCENTAGE

            #define CTILEAVES
            #define DEPTHONLYPASS

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Leaves DepthOnly Pass.hlsl"

            ENDHLSL
        }


//  Meta -----------------------------------------------------
        Pass
        {
            Tags {"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #define _SPECULAR_SETUP
            #define _ALPHATEST_ON 1

            #pragma shader_feature _SPECGLOSSMAP

            #include "Includes/CTI URP Inputs.hlsl"
            #include "Includes/CTI URP Meta.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditor "CTI_URP_ShaderGUI"
    FallBack "Hidden/InternalErrorShader"
}