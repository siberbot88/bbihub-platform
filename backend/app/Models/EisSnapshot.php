<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EisSnapshot extends Model
{
    use HasFactory;

    protected $fillable = [
        'year',
        'month',
        'type',
        'data',
        'description',
        'snapshotted_at'
    ];

    protected $casts = [
        'data' => 'array',
        'snapshotted_at' => 'datetime',
    ];
}
