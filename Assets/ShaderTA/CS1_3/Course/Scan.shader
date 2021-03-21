// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Scan"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_RimMin("RimMin", Range( -1 , 1)) = 0
		_RimMax("RimMax", Range( 0 , 2)) = 0
		_InnerColor("InnerColor", Color) = (0,0,0,0)
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RimIntensity("RimIntensity", Float) = 0
		_FloatEmiss("FloatEmiss", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_FlowIntensity("FlowIntensity", Float) = 0.5
		_TexPower("TexPower", Float) = 0
		_InnerAlpha("InnerAlpha", Float) = 0
		_FlowTilling("FlowTilling", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
			float3 worldPos;
		};

		uniform float4 _InnerColor;
		uniform float4 _RimColor;
		uniform float _RimIntensity;
		uniform sampler2D _MainTex;
		SamplerState sampler_MainTex;
		uniform float4 _MainTex_ST;
		uniform float _TexPower;
		uniform float _RimMin;
		uniform float _RimMax;
		uniform float _FlowIntensity;
		uniform sampler2D _FloatEmiss;
		uniform float2 _FlowTilling;
		uniform float2 _Speed;
		SamplerState sampler_FloatEmiss;
		uniform float _InnerAlpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float dotResult19 = dot( ase_worldNormal , i.viewDir );
			float clampResult21 = clamp( dotResult19 , 0.0 , 1.0 );
			float smoothstepResult32 = smoothstep( _RimMin , _RimMax , ( 1.0 - clampResult21 ));
			float clampResult70 = clamp( ( pow( tex2D( _MainTex, uv_MainTex ).r , _TexPower ) + smoothstepResult32 ) , 0.0 , 1.0 );
			float4 lerpResult39 = lerp( _InnerColor , ( _RimColor * _RimIntensity ) , clampResult70);
			float4 FinalRimColor81 = lerpResult39;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult50 = (float2(ase_worldPos.x , ase_worldPos.y));
			float3 objToWorld51 = mul( unity_ObjectToWorld, float4( float3( float2( 0,0 ) ,  0.0 ), 1 ) ).xyz;
			float2 appendResult55 = (float2(objToWorld51.x , objToWorld51.y));
			float4 tex2DNode42 = tex2D( _FloatEmiss, ( ( ( appendResult50 - appendResult55 ) * _FlowTilling ) + ( _Speed * _Time.y ) ) );
			float4 FloatColor75 = ( _FlowIntensity * tex2DNode42 );
			o.Emission = ( FinalRimColor81 + FloatColor75 ).rgb;
			float FinalRimAlphag84 = clampResult70;
			float FloatAlpha77 = ( _FlowIntensity * tex2DNode42.a );
			float clampResult58 = clamp( ( FinalRimAlphag84 + FloatAlpha77 + _InnerAlpha ) , 0.0 , 1.0 );
			o.Alpha = clampResult58;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
0;436;1961;933;4309.716;990.7263;1.6;True;True
Node;AmplifyShaderEditor.CommentaryNode;79;-2997.478,620.6248;Inherit;False;2329.037;634.5643;流光;18;77;75;65;60;61;42;45;72;46;44;54;48;74;50;55;51;49;53;流光;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;86;-2938.893,-714.0823;Inherit;False;2363.478;1097.711;边缘光;20;16;17;19;21;5;67;34;22;33;32;66;38;41;68;70;40;37;84;39;81;边缘光;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;53;-2947.478,848.8144;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;49;-2732.629,670.6248;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;51;-2774.842,818.2206;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-2761.2,107.7236;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;16;-2786.936,-101.409;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;55;-2476.477,814.8144;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;50;-2475.629,673.6248;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;19;-2515.41,25.95678;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-2295.477,725.8146;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;48;-2703.684,1148.735;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;21;-2375.926,25.11694;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;44;-2704.377,981.3918;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;74;-2306.262,895.5131;Inherit;False;Property;_FlowTilling;FlowTilling;12;0;Create;True;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;5;-2533.693,-467.2822;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;33;-2274.072,167.9318;Inherit;False;Property;_RimMin;RimMin;2;0;Create;True;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;-2169.131,40.11694;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2134.9,837.6186;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-2277.253,267.6283;Inherit;False;Property;_RimMax;RimMax;3;0;Create;True;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2428.377,1025.392;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-2471.405,-192.4085;Inherit;False;Property;_TexPower;TexPower;10;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;66;-2048.845,-225.7851;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;32;-1880.341,105.2254;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1953.698,910.1293;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1642.934,-74.82189;Inherit;False;Property;_RimIntensity;RimIntensity;6;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-1666.281,87.26862;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-1654.659,-282.3625;Inherit;False;Property;_RimColor;RimColor;5;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;42;-1760.266,850.08;Inherit;True;Property;_FloatEmiss;FloatEmiss;7;0;Create;True;0;0;False;0;False;-1;adc10745c1b069148b3531cbd4dcab6a;adc10745c1b069148b3531cbd4dcab6a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;61;-1503.135,726.9835;Inherit;False;Property;_FlowIntensity;FlowIntensity;9;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-1655.817,-465.204;Inherit;False;Property;_InnerColor;InnerColor;4;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1379.934,-144.8219;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;70;-1517.935,74.28891;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-1154.989,893.2631;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-921.5452,883.8725;Inherit;False;FloatAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;84;-1189.313,80.86736;Inherit;False;FinalRimAlphag;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1150.465,767.2655;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;39;-992.8883,-249.9618;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-518.3159,533.252;Inherit;False;77;FloatAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-510.0089,459.5106;Inherit;False;84;FinalRimAlphag;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-499.4233,613.0634;Inherit;False;Property;_InnerAlpha;InnerAlpha;11;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;75;-908.0098,773.0587;Inherit;False;FloatColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;81;-799.415,-239.3833;Inherit;False;FinalRimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-264.1933,496.9404;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;76;-354.9166,325.4988;Inherit;False;75;FloatColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-353.4034,204.4658;Inherit;False;81;FinalRimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;6;207.7696,199.2312;Inherit;False;305;497;Comment;1;4;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;58;-81.38669,490.7782;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-79.56582,275.4145;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;4;257.7697,249.2312;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;53;0
WireConnection;55;0;51;1
WireConnection;55;1;51;2
WireConnection;50;0;49;1
WireConnection;50;1;49;2
WireConnection;19;0;16;0
WireConnection;19;1;17;0
WireConnection;54;0;50;0
WireConnection;54;1;55;0
WireConnection;21;0;19;0
WireConnection;22;0;21;0
WireConnection;72;0;54;0
WireConnection;72;1;74;0
WireConnection;46;0;44;0
WireConnection;46;1;48;0
WireConnection;66;0;5;1
WireConnection;66;1;67;0
WireConnection;32;0;22;0
WireConnection;32;1;33;0
WireConnection;32;2;34;0
WireConnection;45;0;72;0
WireConnection;45;1;46;0
WireConnection;68;0;66;0
WireConnection;68;1;32;0
WireConnection;42;1;45;0
WireConnection;40;0;38;0
WireConnection;40;1;41;0
WireConnection;70;0;68;0
WireConnection;65;0;61;0
WireConnection;65;1;42;4
WireConnection;77;0;65;0
WireConnection;84;0;70;0
WireConnection;60;0;61;0
WireConnection;60;1;42;0
WireConnection;39;0;37;0
WireConnection;39;1;40;0
WireConnection;39;2;70;0
WireConnection;75;0;60;0
WireConnection;81;0;39;0
WireConnection;57;0;85;0
WireConnection;57;1;78;0
WireConnection;57;2;71;0
WireConnection;58;0;57;0
WireConnection;56;0;83;0
WireConnection;56;1;76;0
WireConnection;4;2;56;0
WireConnection;4;9;58;0
ASEEND*/
//CHKSM=AA34FDF2AB6B8BD1CC656103FC72D0274A34307B