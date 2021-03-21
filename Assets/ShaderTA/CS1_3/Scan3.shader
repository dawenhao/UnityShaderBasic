// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "wenhao/Scan3"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
    }
        SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldView : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldView = UnityWorldSpaceViewDir(o.worldPos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normWorldView = normalize(i.worldView);
                float3 normWorldNormal = normalize(i.worldNormal);
                fixed3 color = saturate(1- dot(normWorldView, i.worldNormal));
                return float4(color,1);
            }
            ENDCG
        }
    }
}
