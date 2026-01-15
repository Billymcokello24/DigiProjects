<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function index()
    {
        /** @var \App\Models\User $user */
        $user = \Illuminate\Support\Facades\Auth::user();
        
        $query = User::where('role', 'COUNTY_OFFICER')->with('county');
        
        // If regional officer, only show officers from their region's counties
        if ($user && $user->role === 'REGIONAL_OFFICER' && $user->region_id) {
            $query->whereHas('county', function($q) use ($user) {
                $q->where('region_id', $user->region_id);
            });
        }
        
        return $query->latest()->get();
    }

    public function store(Request $request)
    {
        /** @var \App\Models\User $authUser */
        $authUser = \Illuminate\Support\Facades\Auth::user();
        
        // Only admins or regional officers can create county officers
        if (!$authUser || !in_array($authUser->role, ['ADMIN', 'REGIONAL_OFFICER'])) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
            'county_id' => 'required|exists:counties,id',
        ]);

        // If regional officer, ensure they can only create officers in their region's counties
        if ($authUser->role === 'REGIONAL_OFFICER' && $authUser->region_id) {
            $county = \App\Models\County::find($validated['county_id']);
            if (!$county || $county->region_id !== $authUser->region_id) {
                return response()->json(['message' => 'Unauthorized: County is not in your region'], 403);
            }
        }

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'county_id' => $validated['county_id'],
            'role' => 'COUNTY_OFFICER',
        ]);

        return response()->json($user->load('county'), 201);
    }

    public function show(User $user)
    {
        /** @var \App\Models\User $authUser */
        $authUser = \Illuminate\Support\Facades\Auth::user();
        
        // If regional officer, ensure they can only view officers from their region
        if ($authUser && $authUser->role === 'REGIONAL_OFFICER' && $authUser->region_id) {
            // Check if the user's county belongs to the regional officer's region
            if (!$user->county || $user->county->region_id !== $authUser->region_id) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }
        }
        
        return $user->load('county');
    }

    public function update(Request $request, User $user)
    {
        /** @var \App\Models\User $authUser */
        $authUser = \Illuminate\Support\Facades\Auth::user();
        
        // If regional officer, ensure they can only update officers from their region
        if ($authUser && $authUser->role === 'REGIONAL_OFFICER' && $authUser->region_id) {
            // Check if the user's county belongs to the regional officer's region
            if (!$user->county || $user->county->region_id !== $authUser->region_id) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }
        }
        
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => ['sometimes', 'required', 'email', Rule::unique('users')->ignore($user->id)],
            'password' => 'sometimes|nullable|string|min:6',
            'county_id' => 'sometimes|required|exists:counties,id',
        ]);

        if (isset($validated['password'])) {
            $validated['password'] = Hash::make($validated['password']);
        }

        $user->update($validated);

        return response()->json($user->load('county'));
    }

    public function destroy(User $user)
    {
        /** @var \App\Models\User $authUser */
        $authUser = \Illuminate\Support\Facades\Auth::user();
        
        // If regional officer, ensure they can only delete officers from their region
        if ($authUser && $authUser->role === 'REGIONAL_OFFICER' && $authUser->region_id) {
            // Check if the user's county belongs to the regional officer's region
            if (!$user->county || $user->county->region_id !== $authUser->region_id) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }
        }
        
        // Prevent deleting admin users
        if ($user->role === 'ADMIN') {
            return response()->json(['message' => 'Cannot delete admin users'], 403);
        }

        $user->delete();

        return response()->json(['message' => 'User deleted successfully']);
    }
}
