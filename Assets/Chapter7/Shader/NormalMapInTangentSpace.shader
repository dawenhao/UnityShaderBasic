Shader "Wenhao/NormalMapInTangentSpace"
{
   Properties
   {
       _Color ("Color", Color) = (1, 1, 1, 1)
       _MainTex ("MainTex", 2D) = "white" {}
       _BumpMap ("BumpMap", 2D) = "bump" {}
       _BumpScale ("BumpScle", Float) = 1.0
       _Specular ("Specular", Color) = (1, 1, 1, 1)
       _Gloss ("Gloss", Range(8, 255)) = 20
   }

   SubShader
   {
       Pass
       {
           Tags {"LightMode" = "ForwardBase"}

           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           #include "Lighting.cginc"
 
           fixed4 _Color;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           sampler2D _BumpMap;
           float4 _BumpMap_ST;
           float _BumpScale;
           fixed3 _Specular;
           float _Gloss;

           struct a2v
           {
               float4 vertex : POSITION;
               float3 normal : NORMAL;
               float4 tangent : TANGENT;
               float4 texcoord : TEXCOORD0;
           };

           struct v2f
           {
               float4 pos : SV_POSITION;
               float4 uv : TEXCOORD0;
               float3 lightDir : TEXCOORD1;
               float3 viewDir : TEXCOORD2;
           };

           v2f vert (a2v i)
           {
               v2f o;
               o.pos = UnityObjectToClipPos(i.vertex);
               o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
               o.uv.zw = i.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

               float3 binormal = cross(normalize(i.normal), normalize(i.tangent.xyz)) * i.tangent.w;
               float3x3 rotation = float3x3(i.tangent.xyz, binormal, i.normal);

               o.lightDir = mul(rotation, ObjSpaceLightDir(i.vertex)).xyz;
               o .viewDir = mul(rotation, ObjSpaceViewDir(i.vertex)).xyz;
               return o;
           }

           fixed4 frag (v2f i) : SV_Target
           {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

                fixed3 tangentNormal = UnpackNormal(packedNormal);

                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT * albedo;
                fixed3 diffuse = _LightColor0.xyz * albedo * max (0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1);
           }

           ENDCG
       }
      
   }
    Fallback "Specular"
}
