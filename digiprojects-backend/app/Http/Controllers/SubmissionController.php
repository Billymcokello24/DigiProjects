<?php

namespace App\Http\Controllers;

use App\Models\Submission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SubmissionController extends Controller
{
    public function nationalStats()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        if (!$user || $user->role !== 'ADMIN') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $all = \App\Models\Submission::all();
        $totalProjects = $all->unique('site')->count();
        $totalSubmissions = $all->count();
        $totalCounties = \App\Models\County::count();
        
        return response()->json([
            'total_projects' => $totalProjects,
            'total_submissions' => $totalSubmissions,
            'total_counties' => $totalCounties,
            'system_health' => 'Stable'
        ]);
    }

    public function countyReports()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        if (!$user || ($user->role !== 'ADMIN' && $user->role !== 'REGIONAL_OFFICER')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $query = \App\Models\County::with(['region', 'users', 'submissions' => function($query) {
            $query->with('user');
        }]);
        
        // If regional officer, only show counties from their region
        if ($user->role === 'REGIONAL_OFFICER' && $user->region_id) {
            $query->where('region_id', $user->region_id);
        }
        
        $counties = $query->get();
        
        $countiesReports = $counties->map(function ($county) {
            $submissions = $county->submissions()->with('user')->get();
            
            return [
                'county' => [
                    'id' => $county->id,
                    'name' => $county->name,
                    'region' => $county->region->name ?? null,
                    'is_active' => $county->is_active,
                    'officers_count' => $county->users()->count(),
                ],
                'report' => [
                    'total_submissions' => $submissions->count(),
                    'total_projects' => $submissions->pluck('site')->unique()->count(),
                    'statuses' => $submissions->groupBy('status')->map(fn($items) => $items->count()),
                    'submissions' => $submissions->map(function($sub) {
                        return [
                            'id' => $sub->id,
                            'project_type' => $sub->project_type,
                            'phase' => $sub->phase,
                            'site' => $sub->site,
                            'status' => $sub->status,
                            'remarks' => $sub->remarks,
                            'officer_name' => $sub->user->name,
                            'created_at' => $sub->created_at,
                            'updated_at' => $sub->updated_at,
                        ];
                    })->values(),
                ],
            ];
        });

        return response()->json($countiesReports);
    }

    public function stats()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user() ?: \App\Models\User::first();
        
        if (!$user) return response()->json([
            'total_projects' => 0,
            'monthly_submissions' => 0,
            'action_required' => 0,
        ]);

        $all = $user->submissions;

        return response()->json([
            'total_projects' => $all->unique('site')->count(),
            'monthly_submissions' => $all->where('created_at', '>=', now()->startOfMonth())->count(),
            'action_required' => $all->where('status', 'DOWN')->count(),
        ]);
    }

    public function index()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user() ?: \App\Models\User::first();
        
        if (!$user) return [];

        if ($user->role === 'ADMIN') {
            // Admin sees everything
            return Submission::with('user')->latest()->get();
        }

        // Return only submissions by this specific user
        return $user->submissions()->latest()->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'project_id' => 'nullable|exists:projects,id',
            'phase_id' => 'nullable|exists:phases,id',
            'project_type' => 'required|string',
            'phase' => 'required|string',
            'site' => 'required|string',
            'status' => 'required|string',
            'remarks' => 'nullable|string',
        ]);

        /** @var \App\Models\User $user */
        $user = Auth::user() ?: \App\Models\User::first();

        if (!$user) {
            return response()->json(['message' => 'No user found'], 500);
        }

        $submission = $user->submissions()->create($validated);

        return response()->json($submission, 201);
    }

    public function show(Submission $submission)
    {
        return $submission;
    }

    public function update(Request $request, Submission $submission)
    {
        $validated = $request->validate([
            'project_id' => 'nullable|exists:projects,id',
            'phase_id' => 'nullable|exists:phases,id',
            'project_type' => 'required|string',
            'phase' => 'required|string',
            'site' => 'required|string',
            'status' => 'required|string',
            'remarks' => 'nullable|string',
        ]);

        $submission->update($validated);

        return response()->json($submission);
    }

    public function destroy(Submission $submission)
    {
        $submission->delete();

        return response()->json(['message' => 'Deleted successfully']);
    }

    public function regionalStats()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        if (!$user || ($user->role !== 'REGIONAL_OFFICER' && $user->role !== 'ADMIN')) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Get counties in the user's region
        $counties = \App\Models\County::where('region_id', $user->region_id)->get();
        $countyIds = $counties->pluck('id');

        // Get submissions for these counties
        $submissions = \App\Models\Submission::whereIn('user_id', function($query) use ($countyIds) {
            $query->select('id')->from('users')->whereIn('county_id', $countyIds);
        })->with(['user', 'project', 'phase'])->get();

        // Get officers in these counties
        $officers = \App\Models\User::where('role', 'COUNTY_OFFICER')
            ->whereIn('county_id', $countyIds)
            ->count();

        // Calculate status counts
        $statusCounts = $submissions->groupBy('status')->map->count();

        // Get recent submissions
        $recentSubmissions = $submissions->sortByDesc('created_at')->take(10);

        // Build counties array with counts
        $countiesData = $counties->map(function($c) use ($submissions) {
            $countySubmissions = $submissions->filter(fn($s) => $s->user->county_id === $c->id);
            $countyOfficers = \App\Models\User::where('role', 'COUNTY_OFFICER')
                ->where('county_id', $c->id)
                ->count();
            
            return [
                'id' => $c->id,
                'name' => $c->name,
                'region' => $c->region->name,
                'region_id' => $c->region_id,
                'is_active' => $c->is_active,
                'officers_count' => $countyOfficers,
                'submissions_count' => $countySubmissions->count(),
            ];
        });

        return response()->json([
            'total_counties' => $counties->count(),
            'total_submissions' => $submissions->count(),
            'total_officers' => $officers,
            'active_projects' => \App\Models\Project::where('is_active', true)->count(),
            'submissions_status' => $statusCounts,
            'counties' => $countiesData,
            'recent_submissions' => $recentSubmissions->map(fn($s) => [
                'id' => $s->id,
                'site' => $s->site,
                'project_type' => $s->project_type,
                'phase' => $s->phase,
                'status' => $s->status,
                'remarks' => $s->remarks,
                'created_at' => $s->created_at,
                'user' => [
                    'id' => $s->user->id,
                    'name' => $s->user->name,
                    'county_id' => $s->user->county_id,
                ],
                'project' => (is_object($s->project) && $s->project) ? ['id' => $s->project->id, 'name' => $s->project->name] : null,
                'phase_obj' => (is_object($s->phase) && $s->phase) ? ['id' => $s->phase->id, 'name' => $s->phase->name] : null,
            ]),
        ]);
    }
}
