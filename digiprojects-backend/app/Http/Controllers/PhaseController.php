<?php

namespace App\Http\Controllers;

use App\Models\Phase;
use App\Models\Project;
use Illuminate\Http\Request;

class PhaseController extends Controller
{
    public function index()
    {
        return Phase::with('project')->orderBy('project_id')->orderBy('order')->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'project_id' => 'required|exists:projects,id',
            'order' => 'nullable|integer|min:1',
            'is_active' => 'boolean',
        ]);

        $phase = Phase::create($validated);
        return response()->json($phase->load('project'), 201);
    }

    public function show(Phase $phase)
    {
        return $phase->load('project');
    }

    public function update(Request $request, Phase $phase)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'project_id' => 'sometimes|required|exists:projects,id',
            'order' => 'nullable|integer|min:1',
            'is_active' => 'boolean',
        ]);

        $phase->update($validated);
        return response()->json($phase->load('project'));
    }

    public function destroy(Phase $phase)
    {
        $phase->delete();
        return response()->json(['message' => 'Phase deleted successfully']);
    }

    public function byProject(Project $project)
    {
        return $project->phases()->where('is_active', true)->orderBy('order')->get();
    }
}
