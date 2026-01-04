<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Report;
use App\Http\Traits\ApiResponseTrait;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    use ApiResponseTrait;

    /**
     * Display a listing of reports for the admin's workshop
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        // 1. Try to get workshop from employment (Staff/Admin)
        $workshopUuid = $user->employment?->workshop_uuid;

        // 2. Fallback: If user has direct workshop relation (e.g. Owner login as Admin role)
        if (!$workshopUuid) {
            $workshopUuid = $user->workshops?->first()?->id;
        }

        if (!$workshopUuid) {
            \Illuminate\Support\Facades\Log::info("Admin Report Index: User {$user->id} ({$user->name}) has no workshop. Returning empty list.");
            return $this->successResponse('No workshop associated', []);
        }

        $perPage = $request->input('per_page', 10);

        $reports = Report::where('workshop_uuid', $workshopUuid)
            ->orderBy('created_at', 'desc')
            ->paginate($perPage);

        return $this->successResponse('Reports retrieved successfully', $reports);
    }

    /**
     * Store a newly created report by admin
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        // 1. Try to get workshop from employment (Staff/Admin)
        $workshopUuid = $user->employment?->workshop_uuid;

        // 2. Fallback: If user has direct workshop relation
        if (!$workshopUuid) {
            $workshopUuid = $user->workshops?->first()?->id;
        }

        if (!$workshopUuid) {
            return $this->errorResponse('No workshop associated [ADMIN_V2]', 404);
        }

        // Validation
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'report_type' => 'required|string|in:Bug,Keluhan,Saran,Ulasan',
            'report_data' => 'required|string|min:10',
            'photo' => 'nullable|string', // base64 or URL
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Validation failed [ADMIN_V2]', 422, $validator->errors()->toArray());
        }

        try {
            // Create report
            $report = Report::create([
                'workshop_uuid' => $workshopUuid,
                'report_type' => $request->report_type,
                'report_data' => $request->report_data,
                'photo' => $request->photo,
                'status' => 'baru', // New report status
            ]);

            return $this->successResponse(
                'Report submitted successfully',
                $report->load('workshop'),
                201
            );
        } catch (\Exception $e) {
            return $this->errorResponse('Failed to submit report: ' . $e->getMessage(), 500);
        }
    }
}
