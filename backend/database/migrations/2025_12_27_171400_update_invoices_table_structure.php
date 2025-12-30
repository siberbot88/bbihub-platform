<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Update invoices table structure
        Schema::table('invoices', function (Blueprint $table) {
            $table->renameColumn('code', 'invoice_code');

            $table->dropForeign(['transaction_uuid']);
            $table->dropColumn(['transaction_uuid', 'amount', 'due_date']);

            $table->foreignUuid('service_uuid')->after('invoice_code')->constrained('services');
            $table->foreignUuid('workshop_uuid')->after('service_uuid')->constrained('workshops');
            $table->foreignUuid('customer_uuid')->after('workshop_uuid')->constrained('customers');
            $table->foreignUuid('created_by')->nullable()->after('customer_uuid')->constrained('users');

            $table->decimal('subtotal', 12, 2)->default(0)->after('created_by');
            $table->decimal('tax', 12, 2)->default(0)->nullable()->after('subtotal');
            $table->decimal('discount', 12, 2)->default(0)->after('tax');
            $table->decimal('total', 12, 2)->default(0)->after('discount');

            $table->dropColumn('paid_at');
            $table->enum('status', ['draft', 'sent', 'paid', 'cancelled'])->default('draft')->after('total');
            $table->timestamp('sent_at')->nullable()->after('status');

            $table->text('notes')->nullable()->after('sent_at');
            $table->softDeletes()->after('updated_at');
        });

        Schema::table('invoices', function (Blueprint $table) {
            $table->unique('invoice_code');
        });
    }

    public function down(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            $table->dropUnique(['invoice_code']);
            $table->dropSoftDeletes();
            $table->dropColumn([
                'service_uuid',
                'workshop_uuid',
                'customer_uuid',
                'created_by',
                'subtotal',
                'tax',
                'discount',
                'total',
                'status',
                'sent_at',
                'notes'
            ]);

            $table->renameColumn('invoice_code', 'code');
            $table->foreignUuid('transaction_uuid')->constrained('transactions');
            $table->decimal('amount', 10, 2);
            $table->dateTime('due_date');
            $table->dateTime('paid_at')->nullable();
        });
    }
};
