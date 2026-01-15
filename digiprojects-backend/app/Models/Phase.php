<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Phase extends Model
{
    protected $fillable = ['name', 'description', 'project_id', 'order', 'is_active'];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function submissions()
    {
        return $this->hasMany(Submission::class);
    }
}
