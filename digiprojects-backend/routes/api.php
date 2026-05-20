<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

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
})->middleware('auth:sanctum');

// Use Sanctum's CsrfCookieController so the XSRF-TOKEN cookie is set
Route::get('/sanctum/csrf-cookie', [\Laravel\Sanctum\Http\Controllers\CsrfCookieController::class, 'show']);

// Quick DB status endpoint to verify connection and row counts (publicly accessible for now)
Route::get('/db-status', function () {
    $driver = config('database.default');
    $counts = [];
    try {
        $counts['users'] = DB::connection('mysql')->table('users')->count();
        $counts['counties'] = DB::connection('mysql')->table('counties')->count();
        $counts['submissions'] = DB::connection('mysql')->table('submissions')->count();
    } catch (\Exception $e) {
        return response()->json(['driver' => $driver, 'error' => $e->getMessage()], 500);
    }

    return response()->json(['driver' => $driver, 'counts' => $counts]);
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
Route::middleware('auth:sanctum')->group(function () {
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

Route::get('/debug/session', function (Request $request) {
    $cookies = $request->cookies->all();
    $headers = [];
    foreach (['cookie', 'x-xsrf-token', 'x-csrf-token'] as $h) {
        $headers[$h] = $request->header($h);
    }

    return response()->json([
        'cookies' => $cookies,
        'headers' => $headers,
        'session_id' => $request->session()->getId(),
        'session_driver' => config('session.driver'),
        'is_authenticated' => (bool) $request->user(),
    ]);
});
