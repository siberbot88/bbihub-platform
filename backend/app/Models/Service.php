<?php

namespace App\Models;

use Database\Factories\ServiceFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Service extends Model implements HasMedia
{
    /** @use HasFactory<ServiceFactory> */
    use HasFactory, HasUuids, InteractsWithMedia;

    protected $primaryKey = 'id';
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'code',
        'workshop_uuid',
        'name',
        'description',
        'category_service',
        'price',
        'scheduled_date',
        'estimated_time',
        'status',
        'acceptance_status',
        'customer_uuid',
        'vehicle_uuid',
        'mechanic_uuid',
        'reason',
        'reason_description',
        'feedback_mechanic',
        'accepted_at',
        'accepted_at',
        'completed_at',
        'assigned_to_user_id',
        'technician_name',
        'type',
        'image_path',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'scheduled_date' => 'datetime',
        'estimated_time' => 'datetime',
        'accepted_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    /* =========================================================
       🔹 RELATIONSHIPS
    ========================================================== */

    public function workshop(): BelongsTo
    {
        return $this->belongsTo(Workshop::class, 'workshop_uuid');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class, 'customer_uuid');
    }

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class, 'vehicle_uuid');
    }

    public function mechanic(): BelongsTo
    {
        return $this->belongsTo(Employment::class, 'mechanic_uuid')
            ->with('user'); // biar langsung dapat user mekaniknya
    }

    /**
     * Service hanya punya 1 transaksi
     * Transaction punya banyak items
     */
    public function transaction(): HasOne
    {
        return $this->hasOne(Transaction::class, 'service_uuid', 'id');
    }

    public function invoice(): HasOne
    {
        return $this->hasOne(Invoice::class, 'service_uuid', 'id');
    }

    /**
     * Service hanya punya 1 log
     */
    public function log(): HasOne
    {
        return $this->hasOne(ServiceLog::class, 'service_uuid', 'id');
    }

    /**
     * Service hanya punya 1 task untuk notifikasi
     */
    public function task(): HasOne
    {
        return $this->hasOne(Task::class, 'transaction_uuid', 'id');
    }

    /**
     * (Opsional) dummy relasi backward compatibility (selalu kosong)
     * Hapus kalau tidak dipakai di mobile
     */
    public function extras()
    {
        return $this->hasMany(ServiceLog::class, 'service_uuid', 'id')
            ->whereRaw('1 = 0');
    }
    protected $appends = [
        'image_url',
    ];

    /**
     * Get image URL.
     */
    public function getImageUrlAttribute(): ?string
    {
        $mediaUrl = $this->getFirstMediaUrl('service_image');
        if ($mediaUrl) {
            return $mediaUrl;
        }

        if ($this->image_path) {
            // Check if it's already a full URL (legacy/external)
            if (str_starts_with($this->image_path, 'http')) {
                return $this->image_path;
            }
            // Return storage URL
            return asset('storage/' . $this->image_path);
        }
        return null; // Or return default placeholder
    }

    public function registerMediaCollections(): void
    {
        $this->addMediaCollection('service_image')
            ->singleFile();
    }
}
