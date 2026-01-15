<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $fillable = ['name', 'description', 'is_active'];

    public function phases()
    {
        return $this->hasMany(Phase::class);
    }

    public function submissions()
    {
        return $this->hasMany(Submission::class);
    }
}
