<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkshopStatistic extends Model
{
    use HasUuids;

    protected $fillable = [
        'workshop_uuid',
        'period_type', // monthly, yearly
        'period_date',
        'revenue',
        'jobs_count',
        'active_employees_count',
        'metadata',
    ];

    protected $casts = [
        'period_date' => 'date',
        'revenue' => 'decimal:2',
        'jobs_count' => 'integer',
        'active_employees_count' => 'integer',
        'metadata' => 'json',
    ];

    public function workshop(): BelongsTo
    {
        return $this->belongsTo(Workshop::class, 'workshop_uuid');
    }
}
