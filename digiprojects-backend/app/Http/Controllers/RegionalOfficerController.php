<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Region;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class RegionalOfficerController extends Controller
{
    public function index()
    {
        // Return only Regional Officers
        return User::where('role', 'REGIONAL_OFFICER')
            ->with('region')
            ->latest()
            ->get();
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'region_id' => 'required|exists:regions,id',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'region_id' => $validated['region_id'],
            'role' => 'REGIONAL_OFFICER',
        ]);

        return response()->json($user->load('region'), 201);
    }

    public function show(User $user)
    {
        if ($user->role !== 'REGIONAL_OFFICER') {
            return response()->json(['message' => 'User is not a regional officer'], 404);
        }
        return $user->load('region');
    }

    public function update(Request $request, User $user)
    {
        if ($user->role !== 'REGIONAL_OFFICER') {
            return response()->json(['message' => 'User is not a regional officer'], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($user->id)],
            'password' => 'sometimes|nullable|string|min:6',
            'region_id' => 'sometimes|required|exists:regions,id',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json($user->load('region'));
    }

    public function destroy(User $user)
    {
        if ($user->role !== 'REGIONAL_OFFICER') {
            return response()->json(['message' => 'User is not a regional officer'], 404);
        }

        $user->delete();

        return response()->json(['message' => 'Regional officer deleted successfully']);
    }
}
