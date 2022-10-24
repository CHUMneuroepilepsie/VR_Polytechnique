#if defined(UNITY_PASS_SHADOWCASTER)
	uniform float4 unity_BillboardCameraParams;
	#define unity_BillboardCameraPosition (unity_BillboardCameraParams.xyz)
#endif

	float3 unity_BillboardSize;
	float4 _CTI_SRP_Wind;
	float _CTI_SRP_Turbulence;

#if defined(_PARALLAXMAP)
	float2 _CTI_TransFade;
#endif

float4 SmoothCurve(float4 x) {
	return x * x * (3.0 - 2.0 * x);
}

float4 TriangleWave(float4 x) {
	return abs(frac(x + 0.5) * 2.0 - 1.0);
}

float4 CTISmoothTriangleWave(float4 x) {
	return (SmoothCurve(TriangleWave(x)) - 0.5) * 2.0;
}

// Billboard Vertex Function
void CTIBillboardVert (inout Attributes v, float3 lightDir, out half4 color) {

//	Init color
	color = 0;

	float4 position = v.positionOS;
	float3 worldPos = v.positionOS.xyz + UNITY_MATRIX_M._m03_m13_m23;
	float3 TreeWorldPos = abs(worldPos.xyz * 0.125f);

//	Store Color Variation
	#if !defined(SHADOWCASTERPASS)
		color.r = saturate((frac(TreeWorldPos.x + TreeWorldPos.y + TreeWorldPos.z) + frac((TreeWorldPos.x + TreeWorldPos.y + TreeWorldPos.z) * 3.3)) * 0.5);
	#endif

	// #if defined(_PARALLAXMAP)
	// 	float3 distVec = _WorldSpaceCameraPos - worldPos;
	// 	float distSq = dot(distVec, distVec);
	// 	color.b = saturate( (_CTI_TransFade.x - distSq) / _CTI_TransFade.y);
	// #endif

// 	////////////////////////////////////
//	Set vertex position
	#if defined(SHADOWCASTERPASS)
		float3 eyeVec = -lightDir;
	#else
		float3 eyeVec = normalize(_WorldSpaceCameraPos - worldPos);
	#endif

	float3 billboardTangent = normalize(float3(-eyeVec.z, 0, eyeVec.x));
	float3 billboardNormal = float3(billboardTangent.z, 0, -billboardTangent.x);
	float2 percent = v.texcoord.xy;
	float3 billboardPos = (percent.x - 0.5) * unity_BillboardSize.x * v.texcoord1.x * billboardTangent;

	// billboardPos.y += (percent.y * unity_BillboardSize.y * 2.0 + unity_BillboardSize.z) * v.texcoord1.y;
	// Nope: not y * 2 other wise billbords get culled too early: Double the height in the bb asset!
	billboardPos.y += (percent.y * unity_BillboardSize.y * _BillboardScale + unity_BillboardSize.z) * v.texcoord1.y;

	position.xyz += billboardPos;
	v.positionOS.xyz = position.xyz;
	v.positionOS.w = 1.0f;

//	Wind
	float sinuswave = _SinTime.z;
	float4 vOscillations = CTISmoothTriangleWave(float4(TreeWorldPos.x + sinuswave, TreeWorldPos.z + sinuswave * 0.8, 0.0, 0.0));
	float fOsc = vOscillations.x + (vOscillations.y * vOscillations.y);
	fOsc = 0.75 + (fOsc + 3.33) * 0.33;

//	Saturate added to stop warning on dx11...
	v.positionOS.xyz += _CTI_SRP_Wind.w * _CTI_SRP_Wind.xyz * _WindStrength * fOsc * pow(saturate(percent.y), 1.5);	// pow(y,1.5) matches the wind baked to the mesh trees

// 	////////////////////////////////////
//	Get billboard texture coords
	float angle = atan2(billboardNormal.z, billboardNormal.x);	// signed angle between billboardNormal to {0,0,1}
	angle += angle < 0 ? 2 * PI : 0;										

//	Set Rotation
	angle += v.texcoord1.z;
//	Write final billboard texture coords
	const float invDelta = 1.0 / (45.0 * ((PI * 2.0) / 360.0));
	float imageIndex = fmod(floor(angle * invDelta + 0.5f), 8);
	float2 column_row;
	column_row.x = imageIndex * 0.25; 							// we do not care about the horizontal coord that much as our billboard texture tiles
	column_row.y = saturate(4 - imageIndex) * 0.5;
	v.texcoord.xy = column_row + v.texcoord.xy * float2(0.25, 0.5);

// 	////////////////////////////////////
//	Set Normal and Tangent

	v.normalOS = billboardNormal.xyz;
	#if !defined(SHADOWCASTERPASS)
		v.tangentOS = float4(billboardTangent.xyz, -1.0);
	#endif
}
