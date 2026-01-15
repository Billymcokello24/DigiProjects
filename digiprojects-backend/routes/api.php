<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    $user = $request->user();
    if ($user) {
        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'county_id' => $user->county_id,
            'county' => $user->county?->name,
            'region_id' => $user->region_id,
            'region' => $user->region?->name,
        ]);
    }
    return response()->json(null, 401);
})->middleware('api_auth:sanctum');

Route::get('/sanctum/csrf-cookie', function (Request $request) {
    // Sanctum automatically sets the XSRF-TOKEN cookie when this route is accessed
    // This endpoint is called by frontend before login to get the CSRF token
    return response()->json(['message' => 'CSRF cookie set']);
});

// Public routes - no authentication required
Route::middleware([])->group(function () {
    Route::post('/login', [App\Http\Controllers\AuthController::class, 'login']);
    Route::post('/logout', [App\Http\Controllers\AuthController::class, 'logout']);
    Route::post('/auth/reset-password', [App\Http\Controllers\AuthController::class, 'resetPassword']);
    Route::get('/regions', [App\Http\Controllers\RegionController::class, 'index']);
    Route::get('/public/counties-summary', [App\Http\Controllers\CountyController::class, 'publicSummary']);
});

// Protected routes - require Sanctum authentication
Route::middleware('api_auth:sanctum')->group(function () {
    // Projects & Phases - accessible to all authenticated users for dropdowns
    Route::get('/projects', [App\Http\Controllers\ProjectController::class, 'index']);
    Route::get('/phases', [App\Http\Controllers\PhaseController::class, 'index']);    
    // County Officer Management (Admin only)
    Route::apiResource('users', App\Http\Controllers\UserController::class);

    // Regional Officer Management (Admin only)
    Route::apiResource('regional-officers', App\Http\Controllers\RegionalOfficerController::class);

    // County Management (Admin only)
    Route::apiResource('counties', App\Http\Controllers\CountyController::class);

    // Project Management (Admin only)
    Route::apiResource('projects', App\Http\Controllers\ProjectController::class);
    Route::apiResource('phases', App\Http\Controllers\PhaseController::class);
    Route::get('/projects/{project}/phases', [App\Http\Controllers\PhaseController::class, 'byProject']);

    // Submissions
    Route::get('/submissions/national-stats', [App\Http\Controllers\SubmissionController::class, 'nationalStats']);
    Route::get('/submissions/county-reports', [App\Http\Controllers\SubmissionController::class, 'countyReports']);
    Route::get('/submissions/regional-stats', [App\Http\Controllers\SubmissionController::class, 'regionalStats']);
    Route::get('/submissions/stats', [App\Http\Controllers\SubmissionController::class, 'stats']);
    Route::get('/submissions', [App\Http\Controllers\SubmissionController::class, 'index']);
    Route::post('/submissions', [App\Http\Controllers\SubmissionController::class, 'store']);
    Route::get('/submissions/{submission}', [App\Http\Controllers\SubmissionController::class, 'show']);
    Route::put('/submissions/{submission}', [App\Http\Controllers\SubmissionController::class, 'update']);
    Route::delete('/submissions/{submission}', [App\Http\Controllers\SubmissionController::class, 'destroy']);
});