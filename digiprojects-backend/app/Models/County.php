<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class County extends Model
{
    protected $fillable = ['name', 'region_id', 'is_active'];

    public function region()
    {
        return $this->belongsTo(Region::class);
    }

    public function users()
    {
        return $this->hasMany(User::class);
    }

    public function submissions()
    {
        return $this->hasManyThrough(Submission::class, User::class);
    }
}
