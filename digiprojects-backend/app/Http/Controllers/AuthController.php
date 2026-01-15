<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt($credentials)) {
            // Regenerate session for web guard
            if ($request->hasSession()) {
                $request->session()->regenerate();
            }
            
            /** @var \App\Models\User $user */
            $user = Auth::user();

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

        return response()->json([
            'errors' => [
                'email' => ['The provided credentials do not match our records.'],
            ]
        ], 422);
    }

    public function logout(Request $request)
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json(['message' => 'Logged out successfully']);
    }

    public function resetPassword(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|string|min:6|confirmed',
        ]);

        try {
            $user = User::where('email', $validated['email'])->first();
            
            if (!$user) {
                return response()->json([
                    'message' => 'No user found with that email address.',
                ], 404);
            }

            // Update the password for any user type (ADMIN, REGIONAL_OFFICER, COUNTY_OFFICER)
            $user->update([
                'password' => Hash::make($validated['password']),
            ]);

            return response()->json([
                'message' => 'Password has been reset successfully. You can now login with your new password.',
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'An error occurred while resetting the password.',
            ], 500);
        }
    }
}
