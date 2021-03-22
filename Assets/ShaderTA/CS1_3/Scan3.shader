Shader "wenhao/Scan3"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _FPower("FPower", float) = 0.5
        _FScale("FScale", float) = 0.5
        _FBias("FBias", float) = 0.5
        _Color0("Color0", Color) = (1, 1, 1, 1)
        _Color1("Color1", Color) = (1, 1, 1, 1)
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
            float _FPower;
            float _FScale;
            float _FBias;
            float4 _Color0;
            float4 _Color1;

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

                float alpha = saturate(pow((1 - dot(normWorldView, i.worldNormal)), _FPower) * _FScale + _FBias);
                fixed4 color = lerp(_Color0, _Color1, alpha);
                return color;
            }
            ENDCG
        }
    }
}
