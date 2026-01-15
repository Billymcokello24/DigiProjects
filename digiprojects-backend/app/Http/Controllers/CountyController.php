<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class CountyController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = \Illuminate\Support\Facades\Auth::user();
        
        $query = \App\Models\County::query()->with('region', 'users', 'submissions');
        
        // If regional officer, only show counties from their region
        if ($user && $user->role === 'REGIONAL_OFFICER' && $user->region_id) {
            $query->where('region_id', $user->region_id);
        } elseif ($request->has('region_id')) {
            $query->where('region_id', $request->region_id);
        }
        
        $counties = $query->get();
        
        // Add counts as attributes
        return $counties->map(function ($county) {
            return [
                'id' => $county->id,
                'name' => $county->name,
                'region_id' => $county->region_id,
                'region' => $county->region->name,
                'is_active' => $county->is_active,
                'officers_count' => $county->users()->where('role', 'COUNTY_OFFICER')->count(),
                'submissions_count' => $county->submissions()->count(),
            ];
        });
    }

    public function store(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = \Illuminate\Support\Facades\Auth::user();
        
        // Regional officers cannot create counties
        if ($user && $user->role === 'REGIONAL_OFFICER') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        $validated = $request->validate([
            'name' => 'required|string|max:255|unique:counties,name',
            'region_id' => 'required|exists:regions,id',
            'is_active' => 'sometimes|boolean',
        ]);

        $county = \App\Models\County::create($validated);

        return response()->json($county->load('region'), 201);
    }

    public function show($id)
    {
        /** @var \App\Models\User $user */
        $user = \Illuminate\Support\Facades\Auth::user();
        
        $county = \App\Models\County::with('region', 'users')->findOrFail($id);
        
        // If regional officer, ensure they can only view counties from their region
        if ($user && $user->role === 'REGIONAL_OFFICER' && $user->region_id && $county->region_id !== $user->region_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        return response()->json($county);
    }

    public function update(Request $request, $id)
    {
        /** @var \App\Models\User $user */
        $user = \Illuminate\Support\Facades\Auth::user();
        
        $county = \App\Models\County::findOrFail($id);
        
        // If regional officer, ensure they can only update counties from their region
        if ($user && $user->role === 'REGIONAL_OFFICER' && $user->region_id && $county->region_id !== $user->region_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255|unique:counties,name,' . $id,
            'region_id' => 'sometimes|required|exists:regions,id',
            'is_active' => 'sometimes|boolean',
        ]);

        $county->update($validated);

        return response()->json($county->load('region'));
    }

    public function destroy($id)
    {
        /** @var \App\Models\User $user */
        $user = \Illuminate\Support\Facades\Auth::user();
        
        $county = \App\Models\County::findOrFail($id);
        
        // If regional officer, ensure they can only delete counties from their region
        if ($user && $user->role === 'REGIONAL_OFFICER' && $user->region_id && $county->region_id !== $user->region_id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        // Check if county has users
        if ($county->users()->count() > 0) {
            return response()->json([
                'message' => 'Cannot delete county with assigned officers'
            ], 422);
        }

        $county->delete();

        return response()->json(['message' => 'County deleted successfully']);
    }

    public function publicSummary()
    {
        $counties = \App\Models\County::with('region', 'submissions')->get();
        
        $summary = $counties->map(function ($county) {
            $submissions = $county->submissions()->with('user')->get();
            $statusCounts = $submissions->groupBy('status')->map(fn($items) => $items->count())->toArray();
            
            return [
                'id' => $county->id,
                'name' => $county->name,
                'region' => $county->region->name,
                'region_id' => $county->region_id,
                'is_active' => $county->is_active,
                'stats' => [
                    'total_submissions' => $submissions->count(),
                    'total_projects' => $submissions->pluck('site')->unique()->count(),
                    'completed' => $statusCounts['COMPLETED'] ?? 0,
                    'ongoing' => $statusCounts['ONGOING'] ?? 0,
                    'delayed' => $statusCounts['DELAYED'] ?? 0,
                    'pending' => $statusCounts['PENDING'] ?? 0,
                ],
                'submissions' => $submissions->map(function($sub) {
                    return [
                        'id' => $sub->id,
                        'project_type' => $sub->project_type,
                        'phase' => $sub->phase,
                        'site' => $sub->site,
                        'status' => $sub->status,
                        'remarks' => $sub->remarks,
                        'officer_name' => $sub->user?->name ?? 'Unknown',
                        'created_at' => $sub->created_at,
                        'updated_at' => $sub->updated_at,
                    ];
                })->values()
            ];
        })->values();
        
        // Also return national totals
        $allSubmissions = \App\Models\Submission::with('user')->get();
        $allStatusCounts = $allSubmissions->groupBy('status')->map(fn($items) => $items->count())->toArray();
        
        // Get recent updates (last 8 submissions)
        $recentUpdates = $allSubmissions->sortByDesc('updated_at')->take(8)->map(function($sub) {
            return [
                'county' => $sub->user?->county?->name ?? 'Unknown',
                'officer' => $sub->user?->name ?? 'Unknown',
                'title' => $sub->site . ' - ' . $sub->project_type,
                'desc' => 'Phase: ' . $sub->phase . ' | Status: ' . $sub->status . ' | ' . ($sub->remarks ?? 'No remarks'),
                'date' => $sub->updated_at->format('M d, Y'),
                'updated_at' => $sub->updated_at
            ];
        })->values();
        
        $nationalStats = [
            'total_counties' => $counties->count(),
            'total_projects' => $allSubmissions->pluck('site')->unique()->count(),
            'total_regions' => \App\Models\Region::count(),
            'total_phases' => \App\Models\Submission::distinct('phase')->count(),
            'total_submissions' => $allSubmissions->count(),
            'completed' => $allStatusCounts['COMPLETED'] ?? 0,
            'ongoing' => $allStatusCounts['ONGOING'] ?? 0,
            'delayed' => $allStatusCounts['DELAYED'] ?? 0,
            'pending' => $allStatusCounts['PENDING'] ?? 0,
            'completion_rate' => $allSubmissions->count() > 0 ? round(($allStatusCounts['COMPLETED'] ?? 0) / $allSubmissions->count() * 100, 1) : 0
        ];
        
        return response()->json([
            'national_stats' => $nationalStats,
            'counties' => $summary,
            'recent_updates' => $recentUpdates,
            'regions' => \App\Models\Region::all()->map(fn($r) => ['id' => $r->id, 'name' => $r->name])->values(),
            'phases' => \App\Models\Submission::distinct('phase')->pluck('phase')->values(),
            'projects_phases' => \App\Models\Submission::select('site', 'phase')
                ->distinct()
                ->orderBy('site')
                ->get()
                ->map(fn($s) => ['site' => $s->site, 'phase' => $s->phase])
                ->values()
        ]);
    }
}
